package grpc

import (
	"context"
	"strings"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
)

type AccessAuthenticator interface {
	AuthenticateAccess(ctx context.Context, token string) (string, error)
}

type userIDContextKey struct{}

func AuthUnaryServerInterceptor(authenticator AccessAuthenticator) grpc.UnaryServerInterceptor {
	return func(ctx context.Context, request any, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (any, error) {
		if isPublicMethod(info.FullMethod) {
			return handler(ctx, request)
		}
		if authenticator == nil {
			return nil, status.Error(codes.Unauthenticated, "authentication required")
		}
		values := metadata.ValueFromIncomingContext(ctx, "authorization")
		if len(values) != 1 {
			return nil, status.Error(codes.Unauthenticated, "authentication required")
		}
		scheme, token, found := strings.Cut(values[0], " ")
		if !found || !strings.EqualFold(scheme, "Bearer") || token == "" || strings.ContainsAny(token, " \t\r\n") {
			return nil, status.Error(codes.Unauthenticated, "invalid authorization metadata")
		}
		userID, err := authenticator.AuthenticateAccess(ctx, token)
		if err != nil || userID == "" {
			return nil, status.Error(codes.Unauthenticated, "invalid or expired access token")
		}
		return handler(context.WithValue(ctx, userIDContextKey{}, userID), request)
	}
}

func UserIDFromContext(ctx context.Context) (string, bool) {
	userID, ok := ctx.Value(userIDContextKey{}).(string)
	return userID, ok && userID != ""
}

func RequireUser(ctx context.Context, requestedUserID string) error {
	userID, ok := UserIDFromContext(ctx)
	if !ok {
		return status.Error(codes.Unauthenticated, "authentication required")
	}
	if requestedUserID == "" || requestedUserID != userID {
		return status.Error(codes.PermissionDenied, "permission denied")
	}
	return nil
}

func isPublicMethod(fullMethod string) bool {
	switch fullMethod {
	case "/huai.v1.AuthService/Register",
		"/huai.v1.AuthService/Login",
		"/huai.v1.AuthService/RefreshSession",
		"/huai.v1.AuthService/Logout",
		"/huai.v1.ConfigService/GetPublicConfig":
		return true
	default:
		return false
	}
}
