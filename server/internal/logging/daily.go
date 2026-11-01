package logging

import (
	"context"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"sync"
	"time"
)

type DailyWriter struct {
	mu        sync.Mutex
	directory string
	file      *os.File
	day       string
	now       func() time.Time
}

func NewDailyWriter(directory string) (*DailyWriter, error) {
	if err := os.MkdirAll(directory, 0700); err != nil {
		return nil, fmt.Errorf("create log directory: %w", err)
	}
	writer := &DailyWriter{directory: directory, now: time.Now}
	if err := writer.rotate(); err != nil {
		writer.Close()
		return nil, err
	}
	return writer, nil
}

// Maintain rotates even on days without incoming requests.
func (w *DailyWriter) Maintain(ctx context.Context) {
	ticker := time.NewTicker(time.Minute)
	defer ticker.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			w.mu.Lock()
			err := w.rotate()
			w.mu.Unlock()
			if err != nil {
				Error("logging.rotate error=%q", err)
			}
		}
	}
}

func (w *DailyWriter) rotate() error {
	now := w.now().UTC()
	day := now.Format(time.DateOnly)
	if w.day == day {
		return nil
	}
	file, err := os.OpenFile(filepath.Join(w.directory, "huaian-80-"+day+".log"), os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0600)
	if err != nil {
		return fmt.Errorf("open daily log: %w", err)
	}
	if w.file != nil {
		if err := w.file.Close(); err != nil {
			file.Close()
			return fmt.Errorf("close daily log: %w", err)
		}
	}
	w.file = file
	entries, err := os.ReadDir(w.directory)
	if err != nil {
		return fmt.Errorf("list daily logs: %w", err)
	}
	cutoff := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, time.UTC).AddDate(0, 0, -9)
	for _, entry := range entries {
		if entry.IsDir() {
			continue
		}
		date, err := time.Parse("huaian-80-2006-01-02.log", entry.Name())
		if err == nil && date.Before(cutoff) {
			if err := os.Remove(filepath.Join(w.directory, entry.Name())); err != nil && !errors.Is(err, os.ErrNotExist) {
				return fmt.Errorf("remove expired log: %w", err)
			}
		}
	}
	w.day = day
	return nil
}

func (w *DailyWriter) Write(data []byte) (int, error) {
	w.mu.Lock()
	defer w.mu.Unlock()
	if err := w.rotate(); err != nil {
		return 0, err
	}
	return w.file.Write(data)
}

func (w *DailyWriter) Close() error {
	w.mu.Lock()
	defer w.mu.Unlock()
	if w.file == nil {
		return nil
	}
	err := w.file.Close()
	w.file = nil
	w.day = ""
	return err
}
