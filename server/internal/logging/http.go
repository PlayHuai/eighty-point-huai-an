package logging

import (
	"net/http"
	"time"
)

type responseWriter struct {
	http.ResponseWriter
	status int
}

func (w *responseWriter) WriteHeader(status int) {
	if w.status != 0 {
		return
	}
	w.status = status
	w.ResponseWriter.WriteHeader(status)
}

func (w *responseWriter) Write(data []byte) (int, error) {
	if w.status == 0 {
		w.WriteHeader(http.StatusOK)
	}
	return w.ResponseWriter.Write(data)
}

func HTTP(next http.Handler) http.Handler {
	return http.HandlerFunc(func(writer http.ResponseWriter, request *http.Request) {
		// The WebSocket handler logs its own upgrade and connection lifecycle.
		if request.URL.Path == "/events" {
			next.ServeHTTP(writer, request)
			return
		}
		start := time.Now()
		w := &responseWriter{ResponseWriter: writer}
		defer func() {
			if value := recover(); value != nil {
				Error("http.panic method=%q path=%q panic_type=%T", request.Method, request.URL.Path, value)
				panic(http.ErrAbortHandler)
			}
			code := w.status
			if code == 0 {
				code = http.StatusOK
			}
			if request.URL.Path == "/healthz" && code < 400 {
				return
			}
			log := Info
			if code >= 400 {
				log = Warn
			}
			if code >= 500 {
				log = Error
			}
			log("http.complete method=%q path=%q status=%d elapsed_ms=%d", request.Method, request.URL.Path, code, time.Since(start).Milliseconds())
		}()
		next.ServeHTTP(w, request)
	})
}
