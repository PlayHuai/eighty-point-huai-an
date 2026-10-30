package main

import (
	"context"
	"database/sql"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestHealthHandler(t *testing.T) {
	handler := healthHandler()
	tests := []struct {
		name       string
		path       string
		method     string
		statusCode int
	}{
		{name: "health", path: "/healthz", method: http.MethodGet, statusCode: http.StatusNoContent},
		{name: "unknown path", path: "/", method: http.MethodGet, statusCode: http.StatusNotFound},
		{name: "unsupported method", path: "/healthz", method: http.MethodPost, statusCode: http.StatusMethodNotAllowed},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			response := httptest.NewRecorder()
			handler.ServeHTTP(response, httptest.NewRequest(test.method, test.path, nil))
			if response.Code != test.statusCode {
				t.Fatalf("status = %d, want %d", response.Code, test.statusCode)
			}
		})
	}
}

func TestCheckHealth(t *testing.T) {
	server := httptest.NewServer(healthHandler())
	defer server.Close()
	if err := checkHealth(context.Background(), server.URL+"/healthz"); err != nil {
		t.Fatalf("checkHealth() error = %v", err)
	}
	if err := checkHealth(context.Background(), server.URL+"/missing"); err == nil {
		t.Fatal("checkHealth() succeeded for an unhealthy endpoint")
	}
}

func TestDatabaseConfigRequiresCredentials(t *testing.T) {
	for _, key := range []string{"DB_HOST", "DB_PORT", "DB_NAME", "DB_USER", "DB_PASSWORD"} {
		t.Setenv(key, "")
	}
	if _, err := databaseConfig(); err == nil {
		t.Fatal("databaseConfig() succeeded without required credentials")
	}
}

func TestDatabaseConfig(t *testing.T) {
	t.Setenv("DB_HOST", "mysql")
	t.Setenv("DB_PORT", "3307")
	t.Setenv("DB_NAME", "game")
	t.Setenv("DB_USER", "service")
	t.Setenv("DB_PASSWORD", "secret")

	config, err := databaseConfig()
	if err != nil {
		t.Fatalf("databaseConfig() error = %v", err)
	}

	if config.Addr != "mysql:3307" || config.DBName != "game" || config.User != "service" {
		t.Fatalf("unexpected database config: %+v", config)
	}

	t.Setenv("DB_PORT", "invalid")
	if _, err := databaseConfig(); err == nil {
		t.Fatal("databaseConfig() accepted an invalid port")
	}
}

func TestNewApplicationRegistersChatAndRealtimeEndpoints(t *testing.T) {
	db, err := sql.Open("mysql", "")
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()

	app, err := newApplication(db, []string{"https://client.example"})
	if err != nil {
		t.Fatalf("newApplication() error = %v", err)
	}
	services := app.grpcServer.GetServiceInfo()
	if _, ok := services["huai.v1.ChatService"]; !ok {
		t.Fatal("ChatService was not registered")
	}
	if _, ok := services["huai.v1.FriendService"]; !ok {
		t.Fatal("FriendService was not registered")
	}
	server := httptest.NewServer(app.httpHandler)
	defer server.Close()
	response, err := http.Get(server.URL + "/healthz")
	if err != nil {
		t.Fatal(err)
	}
	response.Body.Close()
	if response.StatusCode != http.StatusNoContent {
		t.Fatalf("health status = %d, want %d", response.StatusCode, http.StatusNoContent)
	}
	response, err = http.Get(server.URL + "/events?access_token=secret")
	if err != nil {
		t.Fatal(err)
	}
	response.Body.Close()
	if response.StatusCode != http.StatusBadRequest {
		t.Fatalf("WebSocket auth query returned %d", response.StatusCode)
	}
}
