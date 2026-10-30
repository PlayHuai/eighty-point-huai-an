package grpc

import (
	"context"
	"errors"

	"github.com/Derek0120/eighty-point-huai-an/server/gen/huai/v1"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/chat"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/room"
	grpcgo "google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/timestamppb"
)

type chatServer struct {
	huaiv1.UnimplementedChatServiceServer
	service *chat.Service
}

func RegisterChatService(server grpcgo.ServiceRegistrar, service *chat.Service) error {
	if server == nil || service == nil {
		return errors.New("gRPC registrar and chat service are required")
	}
	huaiv1.RegisterChatServiceServer(server, &chatServer{service: service})
	return nil
}

func (s *chatServer) SendPrivateMessage(
	ctx context.Context,
	request *huaiv1.SendPrivateMessageRequest,
) (*huaiv1.ChatMessage, error) {
	userID, err := authenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	message, err := s.service.SendPrivateMessage(
		ctx, userID, request.GetRecipientUserId(), request.GetRequestId(), request.GetBody(),
	)
	if err != nil {
		return nil, chatError(err)
	}
	return chatMessage(message), nil
}

func (s *chatServer) SendRoomMessage(
	ctx context.Context,
	request *huaiv1.SendRoomMessageRequest,
) (*huaiv1.ChatMessage, error) {
	userID, err := authenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	message, err := s.service.SendRoomMessage(
		ctx, userID, request.GetRoomId(), request.GetRequestId(), request.GetBody(),
	)
	if err != nil {
		return nil, chatError(err)
	}
	return chatMessage(message), nil
}

func (s *chatServer) ListRoomMessages(
	ctx context.Context,
	request *huaiv1.ListRoomMessagesRequest,
) (*huaiv1.ListMessagesResponse, error) {
	userID, err := authenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	if err := s.service.ListRoomMessages(ctx, userID, request.GetRoomId()); err != nil {
		return nil, chatError(err)
	}
	return &huaiv1.ListMessagesResponse{
		Messages: []*huaiv1.ChatMessage{},
		Page:     &huaiv1.PageInfo{},
	}, nil
}

func (s *chatServer) ListPrivateMessages(
	ctx context.Context,
	request *huaiv1.ListPrivateMessagesRequest,
) (*huaiv1.ListMessagesResponse, error) {
	userID, err := authenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	page, err := s.service.ListPrivateMessages(
		ctx, userID, request.GetPeerUserId(), request.GetPage().GetPageToken(), request.GetPage().GetPageSize(),
	)
	if err != nil {
		return nil, chatError(err)
	}
	response := &huaiv1.ListMessagesResponse{
		Page: &huaiv1.PageInfo{NextPageToken: page.NextPageToken},
	}
	for _, message := range page.Messages {
		response.Messages = append(response.Messages, chatMessage(message))
	}
	return response, nil
}

func (s *chatServer) HidePrivateMessage(
	ctx context.Context,
	request *huaiv1.HidePrivateMessageRequest,
) (*huaiv1.Empty, error) {
	userID, err := authenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	if err := s.service.HidePrivateMessage(ctx, userID, request.GetMessageId()); err != nil {
		return nil, chatError(err)
	}
	return &huaiv1.Empty{}, nil
}

func (s *chatServer) ReportPrivateMessage(
	ctx context.Context,
	request *huaiv1.ReportPrivateMessageRequest,
) (*huaiv1.Empty, error) {
	userID, err := authenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	if err := s.service.ReportPrivateMessage(
		ctx, userID, request.GetMessageId(), request.GetReason(),
	); err != nil {
		return nil, chatError(err)
	}
	return &huaiv1.Empty{}, nil
}

func chatMessage(message chat.Message) *huaiv1.ChatMessage {
	return &huaiv1.ChatMessage{
		MessageId:    message.ID,
		RoomId:       message.RoomID,
		SenderUserId: message.SenderID,
		Body:         message.Body,
		CreatedAt:    timestamppb.New(message.CreatedAt),
	}
}

func chatError(err error) error {
	switch {
	case errors.Is(err, chat.ErrInvalidInput):
		return status.Error(codes.InvalidArgument, "invalid private chat request")
	case errors.Is(err, chat.ErrNotFriends):
		return status.Error(codes.PermissionDenied, "private chat requires an accepted friendship")
	case errors.Is(err, chat.ErrNotRoomMember):
		return status.Error(codes.PermissionDenied, "room membership required")
	case errors.Is(err, room.ErrNotMember):
		return status.Error(codes.PermissionDenied, "room membership required")
	case errors.Is(err, chat.ErrMessageNotFound):
		return status.Error(codes.NotFound, "private chat message not found")
	case errors.Is(err, chat.ErrRequestConflict):
		return status.Error(codes.AlreadyExists, "request ID was already used")
	default:
		return status.Error(codes.Internal, "private chat operation failed")
	}
}

var _ huaiv1.ChatServiceServer = (*chatServer)(nil)
