package logging

import (
	"bytes"
	"errors"
	"fmt"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"testing"
	"time"
)

func TestFormat(t *testing.T) {
	var output bytes.Buffer
	writer := formattedWriter{&output}
	for _, level := range []string{"INFO", "WARN", "ERROR"} {
		input := []byte(level + " message\ninjected\r\n")
		n, err := writer.Write(input)
		if err != nil || n != len(input) {
			t.Fatalf("write = %d, %v", n, err)
		}
	}
	lines := strings.Split(strings.TrimSpace(output.String()), "\n")
	if len(lines) != 3 {
		t.Fatalf("unexpected physical lines: %q", output.String())
	}
	pattern := regexp.MustCompile(`^\[(INFO|WARN|ERROR)\] \[[^]]+Z\] \[message\\ninjected\\r\]$`)
	for _, line := range lines {
		if !pattern.MatchString(line) {
			t.Fatalf("invalid format: %q", line)
		}
	}
}

func TestUnexpectedLogsCallSiteWithoutErrorValues(t *testing.T) {
	var output bytes.Buffer
	Configure(&output)
	t.Cleanup(func() { Configure(os.Stderr) })
	Unexpected("database.query", fmt.Errorf("credential-url: %w", errors.New("private-sql-value")))
	for _, text := range []string{"database.query", "causes=", "stack=", "TestUnexpectedLogsCallSite"} {
		if !strings.Contains(output.String(), text) {
			t.Errorf("missing diagnostic %q: %s", text, &output)
		}
	}
	for _, text := range []string{"credential-url", "private-sql-value"} {
		if strings.Contains(output.String(), text) {
			t.Errorf("logged sensitive text %q", text)
		}
	}
}

func TestDailyRotationAndRetention(t *testing.T) {
	directory := t.TempDir()
	now := time.Date(2026, 11, 1, 23, 59, 59, 0, time.UTC)
	for offset := -15; offset <= 0; offset++ {
		name := "huaian-80-" + now.AddDate(0, 0, offset).Format(time.DateOnly) + ".log"
		if err := os.WriteFile(filepath.Join(directory, name), []byte("old\n"), 0600); err != nil {
			t.Fatal(err)
		}
	}
	unrelated := filepath.Join(directory, "unrelated.log")
	if err := os.WriteFile(unrelated, []byte("keep"), 0600); err != nil {
		t.Fatal(err)
	}
	writer := &DailyWriter{directory: directory, now: func() time.Time { return now }}
	t.Cleanup(func() { writer.Close() })
	if _, err := writer.Write([]byte("before midnight\n")); err != nil {
		t.Fatal(err)
	}
	entries, err := os.ReadDir(directory)
	if err != nil || len(entries) != 11 {
		t.Fatalf("retention entries=%d err=%v, want 10 days + unrelated file", len(entries), err)
	}
	now = now.Add(2 * time.Second)
	if _, err := writer.Write([]byte("after midnight\n")); err != nil {
		t.Fatal(err)
	}
	data, err := os.ReadFile(filepath.Join(directory, "huaian-80-2026-11-02.log"))
	if err != nil || string(data) != "after midnight\n" {
		t.Fatalf("new day = %q, %v", data, err)
	}
	data, err = os.ReadFile(filepath.Join(directory, "huaian-80-2026-11-01.log"))
	if err != nil || string(data) != "old\nbefore midnight\n" {
		t.Fatalf("old day = %q, %v", data, err)
	}
	if _, err := os.Stat(filepath.Join(directory, "huaian-80-2026-10-23.log")); !errors.Is(err, os.ErrNotExist) {
		t.Fatalf("expired boundary log not deleted: %v", err)
	}
	if _, err := os.Stat(filepath.Join(directory, "huaian-80-2026-10-24.log")); err != nil {
		t.Fatalf("oldest retained day deleted: %v", err)
	}
	if _, err := os.Stat(unrelated); err != nil {
		t.Fatal(err)
	}
}

func TestDailyInitializationFailure(t *testing.T) {
	path := filepath.Join(t.TempDir(), "not-a-directory")
	if err := os.WriteFile(path, nil, 0600); err != nil {
		t.Fatal(err)
	}
	if _, err := NewDailyWriter(path); err == nil {
		t.Fatal("expected initialization failure")
	}
}

func TestHTTPLogsSuccessAndFailureWithoutQueryOrBody(t *testing.T) {
	var output bytes.Buffer
	Configure(&output)
	t.Cleanup(func() { Configure(os.Stderr) })
	handler := HTTP(http.HandlerFunc(func(writer http.ResponseWriter, request *http.Request) {
		if request.Method == http.MethodPost {
			writer.WriteHeader(http.StatusBadRequest)
			return
		}
		writer.Write([]byte("private-response"))
	}))
	handler.ServeHTTP(httptest.NewRecorder(), httptest.NewRequest(http.MethodGet, "/api/test?token=secret", nil))
	handler.ServeHTTP(httptest.NewRecorder(), httptest.NewRequest(http.MethodPost, "/api/test", strings.NewReader("private-body")))
	for _, text := range []string{"[INFO]", "[WARN]", "status=200", "status=400", "elapsed_ms="} {
		if !strings.Contains(output.String(), text) {
			t.Errorf("missing %q: %s", text, &output)
		}
	}

	for _, text := range []string{"secret", "private-body", "private-response"} {
		if strings.Contains(output.String(), text) {
			t.Errorf("logged sensitive text %q", text)
		}
	}
}

func TestHTTPPanicAbortsWithoutLoggingPanicValue(t *testing.T) {
	var output bytes.Buffer
	Configure(&output)
	t.Cleanup(func() { Configure(os.Stderr) })
	handler := HTTP(http.HandlerFunc(func(http.ResponseWriter, *http.Request) {
		panic("private credential")
	}))

	var recovered any
	func() {
		defer func() { recovered = recover() }()
		handler.ServeHTTP(httptest.NewRecorder(), httptest.NewRequest(http.MethodGet, "/api/test", nil))
	}()
	if recovered != http.ErrAbortHandler {
		t.Fatalf("recovered panic = %#v, want http.ErrAbortHandler", recovered)
	}
	if !strings.Contains(output.String(), "panic_type=string") {
		t.Fatalf("missing sanitized panic diagnostic: %s", &output)
	}
	if strings.Contains(output.String(), "private credential") {
		t.Fatalf("logged panic value: %s", &output)
	}
}
