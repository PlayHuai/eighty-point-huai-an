package grpc

import (
	"context"
	"errors"
	"log"

	huaiv1 "github.com/Derek0120/eighty-point-huai-an/server/gen/huai/v1"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/buildinfo"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/feedback"
	grpcgo "google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type supportServer struct {
	huaiv1.UnimplementedSupportServiceServer
	feedback *feedback.Service
	info     buildinfo.Info
}

func RegisterSupportService(server grpcgo.ServiceRegistrar, service *feedback.Service) error {
	if server == nil || service == nil {
		return errors.New("gRPC registrar and feedback service are required")
	}
	info, err := buildinfo.Current()
	if err != nil {
		return err
	}
	huaiv1.RegisterSupportServiceServer(server, &supportServer{feedback: service, info: info})
	return nil
}

func (s *supportServer) SubmitFeedback(ctx context.Context, request *huaiv1.SubmitFeedbackRequest) (*huaiv1.Empty, error) {
	userID, err := authenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	kind := ""
	switch request.GetKind() {
	case huaiv1.FeedbackKind_FEEDBACK_KIND_BUG:
		kind = "bug"
	case huaiv1.FeedbackKind_FEEDBACK_KIND_SUGGESTION:
		kind = "suggestion"
	}
	if err := s.feedback.Submit(ctx, userID, request.GetRequestId(), kind, request.GetBody()); err != nil {
		switch {
		case errors.Is(err, feedback.ErrInvalidInput):
			return nil, status.Error(codes.InvalidArgument, "feedback requires a UUID, bug/suggestion type and 1-2000 characters")
		case errors.Is(err, feedback.ErrRequestConflict):
			return nil, status.Error(codes.AlreadyExists, "feedback request ID already used with different content")
		default:
			log.Printf("submit feedback failed: %v", err)
			return nil, status.Error(codes.Internal, "could not save feedback")
		}
	}
	return &huaiv1.Empty{}, nil
}

func (s *supportServer) GetServerInfo(ctx context.Context, _ *huaiv1.Empty) (*huaiv1.ServerInfo, error) {
	if _, err := authenticatedUserID(ctx); err != nil {
		return nil, err
	}
	return &huaiv1.ServerInfo{
		CommitId:   s.info.CommitID,
		Version:    s.info.Version,
		Changelist: s.info.Changelist,
	}, nil
}
