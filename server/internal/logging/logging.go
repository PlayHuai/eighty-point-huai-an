package logging

import (
	"errors"
	"fmt"
	"io"
	"log"
	"os"
	"runtime/debug"
	"strings"
	"time"
)

func init() {
	log.SetFlags(0)
	log.SetOutput(formattedWriter{os.Stderr})
}

// Configure also formats messages emitted by the standard library logger.
func Configure(writer io.Writer) {
	log.SetFlags(0)
	log.SetOutput(formattedWriter{writer})
}

type formattedWriter struct{ output io.Writer }

func (w formattedWriter) Write(data []byte) (int, error) {
	message := strings.TrimSuffix(string(data), "\n")
	level := "INFO"
	for _, candidate := range []string{"INFO", "WARN", "ERROR"} {
		if strings.HasPrefix(message, candidate+" ") {
			level, message = candidate, strings.TrimPrefix(message, candidate+" ")
			break
		}
	}
	message = strings.NewReplacer("\r", `\r`, "\n", `\n`).Replace(message)
	line := fmt.Sprintf("[%s] [%s] [%s]\n", level, time.Now().UTC().Format(time.RFC3339Nano), message)
	if _, err := io.WriteString(w.output, line); err != nil {
		// Do not recurse through the configured logger when the log disk fails.
		fmt.Fprintf(os.Stderr, "[ERROR] [%s] [logging.write error=%q]\n", time.Now().UTC().Format(time.RFC3339Nano), err)
		return 0, err
	}
	return len(data), nil
}

func Info(format string, args ...any)  { log.Printf("INFO "+format, args...) }
func Warn(format string, args ...any)  { log.Printf("WARN "+format, args...) }
func Error(format string, args ...any) { log.Printf("ERROR "+format, args...) }

// Unexpected keeps call-site and cause information without error strings, which
// may contain SQL values, remote response bodies, or credential-bearing URLs.
func Unexpected(operation string, err error) {
	causes := make([]string, 0, 4)
	for cause := err; cause != nil && len(causes) < 8; cause = errors.Unwrap(cause) {
		causes = append(causes, fmt.Sprintf("%T", cause))
	}
	Error("%s causes=%q stack=%q", operation, causes, debug.Stack())
}
