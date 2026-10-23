package grpc

import (
	"context"
	"errors"
	"testing"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
)

type testAuthenticator struct {
	userID string
	err    error
	token  string
}

func (a *testAuthenticator) AuthenticateAccess(_ context.Context, token string) (string, error) {
	a.token = token
	return a.userID, a.err
}

func TestAuthInterceptorEnforcesBearerIdentityAndPublicMethods(t *testing.T) {
	authenticator := &testAuthenticator{userID: "user-1"}
	interceptor := AuthUnaryServerInterceptor(authenticator)
	handler := func(ctx context.Context, _ any) (any, error) {
		userID, ok := UserIDFromContext(ctx)
		if !ok {
			return "", nil
		}
		return userID, nil
	}
	call := func(ctx context.Context, method string) (any, error) {
		return interceptor(ctx, nil, &grpc.UnaryServerInfo{FullMethod: method}, handler)
	}

	if _, err := call(context.Background(), "/huai.v1.PlayerService/GetProfile"); status.Code(err) != codes.Unauthenticated {
		t.Fatalf("unauthenticated protected RPC code = %v, want Unauthenticated", status.Code(err))
	}
	ctx := metadata.NewIncomingContext(context.Background(), metadata.Pairs("authorization", "Bearer opaque-token"))
	value, err := call(ctx, "/huai.v1.PlayerService/GetProfile")
	if err != nil || value != "user-1" || authenticator.token != "opaque-token" {
		t.Fatalf("authenticated RPC value/error/token = %v, %v, %q", value, err, authenticator.token)
	}
	if err := RequireUser(ctxWithUserID(context.Background(), "user-1"), "user-2"); status.Code(err) != codes.PermissionDenied {
		t.Fatalf("cross-user authorization error = %v, want PermissionDenied", err)
	}
	if err := RequireUser(ctxWithUserID(context.Background(), "user-1"), "user-1"); err != nil {
		t.Fatalf("owner authorization failed: %v", err)
	}
	if _, err := call(context.Background(), "/huai.v1.AuthService/Login"); err != nil {
		t.Fatalf("public login RPC was blocked: %v", err)
	}
}

func TestAuthInterceptorRejectsMalformedOrInvalidTokens(t *testing.T) {
	authenticator := &testAuthenticator{err: errors.New("expired")}
	interceptor := AuthUnaryServerInterceptor(authenticator)
	handler := func(context.Context, any) (any, error) { return nil, nil }
	info := &grpc.UnaryServerInfo{FullMethod: "/huai.v1.PlayerService/GetProfile"}
	for _, value := range []string{"opaque-token", "Basic opaque-token", "Bearer ", "Bearer opaque-token two"} {
		ctx := metadata.NewIncomingContext(context.Background(), metadata.Pairs("authorization", value))
		if _, err := interceptor(ctx, nil, info, handler); status.Code(err) != codes.Unauthenticated {
			t.Errorf("authorization %q error = %v, want Unauthenticated", value, err)
		}
	}
	ctx := metadata.NewIncomingContext(context.Background(), metadata.Pairs("authorization", "Bearer opaque-token"))
	if _, err := interceptor(ctx, nil, info, handler); status.Code(err) != codes.Unauthenticated {
		t.Fatalf("invalid token error = %v, want Unauthenticated", err)
	}
}

func ctxWithUserID(ctx context.Context, userID string) context.Context {
	return context.WithValue(ctx, userIDContextKey{}, userID)
}
