package main

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"os/signal"
	"strconv"
	"syscall"
	"time"

	mysqlstore "github.com/Derek0120/eighty-point-huai-an/server/internal/persistence/mysql"
	mysqlDriver "github.com/go-sql-driver/mysql"
)

func main() {
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()
	if err := run(ctx, os.Args[1:]); err != nil {
		log.Print(err)
		os.Exit(1)
	}
}

func run(ctx context.Context, args []string) error {
	if len(args) == 0 || (len(args) == 1 && args[0] == "serve") {
		return runServer(ctx, os.Getenv("HTTP_ADDR"))
	}
	if len(args) == 1 && args[0] == "migrate" {
		return runMigrations(ctx)
	}
	if len(args) == 1 && args[0] == "healthcheck" {
		return checkHealth(ctx, os.Getenv("HEALTHCHECK_URL"))
	}
	return errors.New("usage: server [serve|migrate|healthcheck]")
}

func runServer(ctx context.Context, address string) error {
	if address == "" {
		address = ":8080"
	}
	server := &http.Server{
		Addr:              address,
		Handler:           healthHandler(),
		ReadHeaderTimeout: 5 * time.Second,
	}
	serveErr := make(chan error, 1)
	go func() {
		serveErr <- server.ListenAndServe()
	}()

	select {
	case err := <-serveErr:
		if errors.Is(err, http.ErrServerClosed) {
			return nil
		}
		return err
	case <-ctx.Done():
		shutdownCtx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		if err := server.Shutdown(shutdownCtx); err != nil {
			_ = server.Close()
			return err
		}
		err := <-serveErr
		if errors.Is(err, http.ErrServerClosed) {
			return nil
		}
		return err
	}
}

func healthHandler() http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			w.WriteHeader(http.StatusMethodNotAllowed)
			return
		}
		w.WriteHeader(http.StatusNoContent)
	})
	return mux
}

func checkHealth(ctx context.Context, endpoint string) error {
	if endpoint == "" {
		endpoint = "http://127.0.0.1:8080/healthz"
	}
	request, err := http.NewRequestWithContext(ctx, http.MethodGet, endpoint, nil)
	if err != nil {
		return fmt.Errorf("create health check request: %w", err)
	}
	client := http.Client{Timeout: 2 * time.Second}
	response, err := client.Do(request)
	if err != nil {
		return fmt.Errorf("server health check failed: %w", err)
	}
	defer response.Body.Close()
	if response.StatusCode != http.StatusNoContent {
		return fmt.Errorf("server health check returned HTTP %d", response.StatusCode)
	}
	return nil
}

func runMigrations(ctx context.Context) error {
	config, err := databaseConfig()
	if err != nil {
		return err
	}
	db, err := sql.Open("mysql", config.FormatDSN())
	if err != nil {
		return fmt.Errorf("open MySQL connection: %w", err)
	}
	defer db.Close()

	pingCtx, cancel := context.WithTimeout(ctx, 30*time.Second)
	defer cancel()
	if err := db.PingContext(pingCtx); err != nil {
		return fmt.Errorf("connect to MySQL: %w", err)
	}
	if err := mysqlstore.ApplyMigrations(ctx, db); err != nil {
		return fmt.Errorf("apply MySQL migrations: %w", err)
	}
	return nil
}

func databaseConfig() (*mysqlDriver.Config, error) {
	host := os.Getenv("DB_HOST")
	port := os.Getenv("DB_PORT")
	name := os.Getenv("DB_NAME")
	user := os.Getenv("DB_USER")
	password := os.Getenv("DB_PASSWORD")
	if host == "" || name == "" || user == "" || password == "" {
		return nil, errors.New("DB_HOST, DB_NAME, DB_USER, and DB_PASSWORD are required")
	}
	if port == "" {
		port = "3306"
	}
	portNumber, err := strconv.Atoi(port)
	if err != nil || portNumber < 1 || portNumber > 65535 {
		return nil, errors.New("DB_PORT must be between 1 and 65535")
	}
	return &mysqlDriver.Config{
		User:      user,
		Passwd:    password,
		Net:       "tcp",
		Addr:      net.JoinHostPort(host, port),
		DBName:    name,
		ParseTime: true,
		Loc:       time.UTC,
	}, nil
}
