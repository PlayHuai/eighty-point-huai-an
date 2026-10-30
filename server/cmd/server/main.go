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
	"strings"
	"syscall"
	"time"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/auth"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/chat"
	mysqlstore "github.com/Derek0120/eighty-point-huai-an/server/internal/persistence/mysql"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/player"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/room"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/social"
	grpctransport "github.com/Derek0120/eighty-point-huai-an/server/internal/transport/grpc"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/transport/websocket"
	mysqlDriver "github.com/go-sql-driver/mysql"
	grpcgo "google.golang.org/grpc"
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
	config, err := databaseConfig()
	if err != nil {
		return err
	}
	db, err := sql.Open("mysql", config.FormatDSN())
	if err != nil {
		return fmt.Errorf("open MySQL connection: %w", err)
	}
	defer db.Close()
	pingCtx, cancelPing := context.WithTimeout(ctx, 10*time.Second)
	if err := db.PingContext(pingCtx); err != nil {
		cancelPing()
		return fmt.Errorf("connect to MySQL: %w", err)
	}
	cancelPing()

	app, err := newApplication(db, allowedWebSocketOrigins())
	if err != nil {
		return err
	}
	go app.purgeExpiredMessages(ctx)
	grpcAddress := os.Getenv("GRPC_ADDR")
	if grpcAddress == "" {
		grpcAddress = ":8081"
	}
	grpcListener, err := net.Listen("tcp", grpcAddress)
	if err != nil {
		return fmt.Errorf("listen for gRPC: %w", err)
	}
	server := &http.Server{
		Addr:              address,
		Handler:           app.httpHandler,
		ReadHeaderTimeout: 5 * time.Second,
	}
	serveErr := make(chan error, 2)
	go func() {
		serveErr <- server.ListenAndServe()
	}()
	go func() {
		serveErr <- app.grpcServer.Serve(grpcListener)
	}()

	select {
	case err := <-serveErr:
		_ = grpcListener.Close()
		app.grpcServer.Stop()
		shutdownCtx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		if shutdownErr := server.Shutdown(shutdownCtx); shutdownErr != nil {
			_ = server.Close()
			return shutdownErr
		}
		if errors.Is(err, http.ErrServerClosed) || errors.Is(err, grpcgo.ErrServerStopped) {
			return nil
		}
		return err
	case <-ctx.Done():
		shutdownCtx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		if err := server.Shutdown(shutdownCtx); err != nil {
			_ = server.Close()
			app.grpcServer.Stop()
			_ = grpcListener.Close()
			return err
		}
		app.grpcServer.Stop()
		_ = grpcListener.Close()
		return nil
	}
}

type application struct {
	grpcServer    *grpcgo.Server
	httpHandler   http.Handler
	messagePurger expiredChatMessagePurger
}

type expiredChatMessagePurger interface {
	PurgeExpiredChatMessages(context.Context, uint32) (int64, error)
}

func newApplication(db *sql.DB, allowedOrigins []string) (*application, error) {
	rooms := room.NewManager()
	store, err := mysqlstore.NewWithRoomManager(db, rooms)
	if err != nil {
		return nil, err
	}
	authService, err := auth.NewService(store)
	if err != nil {
		return nil, fmt.Errorf("create auth service: %w", err)
	}
	socialService, err := social.NewService(store)
	if err != nil {
		return nil, err
	}
	playerService, err := player.NewPublicProfileService(store)
	if err != nil {
		return nil, err
	}
	hub := websocket.NewHub()
	hub.ObserveRooms(rooms)
	chatService, err := chat.NewServiceWithRoomAccess(store, hub, rooms)
	if err != nil {
		return nil, err
	}
	grpcServer := grpcgo.NewServer(grpcgo.UnaryInterceptor(
		grpctransport.AuthUnaryServerInterceptor(authService),
	))
	registrations := []func() error{
		func() error { return grpctransport.RegisterAuthService(grpcServer, authService) },
		func() error { return grpctransport.RegisterPlayerService(grpcServer, playerService) },
		func() error { return grpctransport.RegisterFriendService(grpcServer, socialService, hub) },
		func() error { return grpctransport.RegisterLobbyService(grpcServer, rooms, store) },
		func() error { return grpctransport.RegisterRoomService(grpcServer, rooms) },
		func() error { return grpctransport.RegisterChatService(grpcServer, chatService) },
	}
	for _, register := range registrations {
		if err := register(); err != nil {
			return nil, fmt.Errorf("register gRPC service: %w", err)
		}
	}
	eventHandler, err := websocket.NewHandler(hub, authService, allowedOrigins, store)
	if err != nil {
		return nil, fmt.Errorf("create WebSocket handler: %w", err)
	}
	mux := http.NewServeMux()
	mux.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			w.WriteHeader(http.StatusMethodNotAllowed)
			return
		}
		w.WriteHeader(http.StatusNoContent)
	})
	mux.Handle("/events", eventHandler)
	return &application{
		grpcServer: grpcServer, httpHandler: mux, messagePurger: store,
	}, nil
}

func allowedWebSocketOrigins() []string {
	values := os.Getenv("WEBSOCKET_ALLOWED_ORIGINS")
	if values == "" {
		values = "http://localhost:3000,http://localhost:8080,https://localhost:8443"
	}
	origins := strings.Split(values, ",")
	for index := range origins {
		origins[index] = strings.TrimSpace(origins[index])
	}
	return origins
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

func (app *application) purgeExpiredMessages(ctx context.Context) {
	ticker := time.NewTicker(time.Hour)
	defer ticker.Stop()
	for {
		for ctx.Err() == nil {
			deleted, err := app.messagePurger.PurgeExpiredChatMessages(ctx, 1000)
			if err != nil {
				log.Printf("purge expired chat messages: %v", err)
				break
			}
			if deleted < 1000 {
				break
			}
		}
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
		}
	}
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
