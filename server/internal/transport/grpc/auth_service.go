package grpc

import (
	"context"
	"errors"

	"github.com/Derek0120/eighty-point-huai-an/server/gen/huai/v1"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/auth"
	grpcgo "google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/timestamppb"
)

type authServer struct {
	huaiv1.UnimplementedAuthServiceServer
	service *auth.Service
}

func RegisterAuthService(server grpcgo.ServiceRegistrar, service *auth.Service) error {
	if server == nil || service == nil {
		return errors.New("gRPC registrar and auth service are required")
	}
	huaiv1.RegisterAuthServiceServer(server, &authServer{service: service})
	return nil
}

func (s *authServer) Register(ctx context.Context, request *huaiv1.RegisterRequest) (*huaiv1.AuthResponse, error) {
	result, err := s.service.Register(ctx, request.GetAccount(), request.GetPassword(), request.GetNickname())
	if err != nil {
		switch {
		case errors.Is(err, auth.ErrInvalidInput):
			return nil, status.Error(codes.InvalidArgument, "invalid registration details")
		case errors.Is(err, auth.ErrAccountExists):
			return nil, status.Error(codes.AlreadyExists, "account already exists")
		default:
			return nil, status.Error(codes.Internal, "registration failed")
		}
	}
	return authResponse(result), nil
}

func (s *authServer) Login(ctx context.Context, request *huaiv1.LoginRequest) (*huaiv1.AuthResponse, error) {
	result, err := s.service.Login(ctx, request.GetAccount(), request.GetPassword(), request.GetDeviceId())
	if err != nil {
		switch {
		case errors.Is(err, auth.ErrInvalidCredentials):
			return nil, status.Error(codes.Unauthenticated, "invalid account or password")
		case errors.Is(err, auth.ErrInvalidInput):
			return nil, status.Error(codes.InvalidArgument, "invalid login details")
		default:
			return nil, status.Error(codes.Internal, "login failed")
		}
	}
	return authResponse(result), nil
}

var _ huaiv1.AuthServiceServer = (*authServer)(nil)

func (s *authServer) RefreshSession(ctx context.Context, request *huaiv1.RefreshSessionRequest) (*huaiv1.AuthResponse, error) {
	result, err := s.service.Refresh(ctx, request.GetRefreshToken())
	if err != nil {
		if errors.Is(err, auth.ErrUnauthenticated) {
			return nil, status.Error(codes.Unauthenticated, "invalid refresh session")
		}
		return nil, status.Error(codes.Internal, "session refresh failed")
	}
	return authResponse(result), nil
}

func (s *authServer) Logout(ctx context.Context, request *huaiv1.LogoutRequest) (*huaiv1.Empty, error) {
	if err := s.service.Logout(ctx, request.GetRefreshToken()); err != nil {
		if errors.Is(err, auth.ErrUnauthenticated) {
			return nil, status.Error(codes.Unauthenticated, "refresh token is required")
		}
		return nil, status.Error(codes.Internal, "logout failed")
	}
	return &huaiv1.Empty{}, nil
}

func (s *authServer) ChangePassword(ctx context.Context, request *huaiv1.ChangePasswordRequest) (*huaiv1.Empty, error) {
	userID, ok := UserIDFromContext(ctx)
	if !ok {
		return nil, status.Error(codes.Unauthenticated, "authentication required")
	}
	if err := s.service.ChangePassword(ctx, userID, request.GetCurrentPassword(), request.GetNewPassword()); err != nil {
		switch {
		case errors.Is(err, auth.ErrInvalidInput):
			return nil, status.Error(codes.InvalidArgument, "invalid password")
		case errors.Is(err, auth.ErrInvalidCredentials):
			return nil, status.Error(codes.Unauthenticated, "current password is incorrect")
		default:
			return nil, status.Error(codes.Internal, "password change failed")
		}
	}
	return &huaiv1.Empty{}, nil
}

func authResponse(result auth.Result) *huaiv1.AuthResponse {
	return &huaiv1.AuthResponse{
		Tokens: &huaiv1.AuthTokens{
			AccessToken: result.AccessToken, RefreshToken: result.RefreshToken,
			AccessTokenExpiresAt: timestamppb.New(result.AccessTokenExpiresAt),
		},
		Profile: &huaiv1.UserProfile{
			UserId: result.Profile.UserID, Nickname: result.Profile.Nickname,
			CreatedAt: timestamppb.New(result.Profile.CreatedAt),
		},
	}
}
