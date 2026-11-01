package grpc

import (
	"context"
	"fmt"
	"runtime/debug"
	"time"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/logging"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func LoggingUnaryServerInterceptor() grpc.UnaryServerInterceptor {
	return func(ctx context.Context, request any, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (response any, err error) {
		start := time.Now()
		fields := requestLogContext(request)
		logging.Info("rpc.start method=%q%s", info.FullMethod, fields)
		defer func() {
			if value := recover(); value != nil {
				// Panic values may contain request bodies or credentials.
				logging.Error("rpc.panic method=%q%s panic_type=%T", info.FullMethod, fields, value)
				logging.Error("rpc.panic.stack stack=%q", debug.Stack())
				panic(value)
			}
			code := status.Code(err)
			log := logging.Info
			if code != codes.OK {
				log = logging.Warn
			}
			if code == codes.Internal || code == codes.Unknown || code == codes.DataLoss {
				log = logging.Error
			}
			log("rpc.complete method=%q%s code=%s elapsed_ms=%d", info.FullMethod, fields, code, time.Since(start).Milliseconds())
		}()
		return handler(ctx, request)
	}
}

func requestLogContext(request any) string {
	fields := ""
	if value, ok := request.(interface{ GetRequestId() string }); ok {
		fields += fmt.Sprintf(" request_id=%.128q", value.GetRequestId())
	}
	if value, ok := request.(interface{ GetExpectedVersion() uint64 }); ok {
		fields += fmt.Sprintf(" expected_version=%d", value.GetExpectedVersion())
	}
	if value, ok := request.(interface{ GetRoomId() string }); ok {
		fields += fmt.Sprintf(" room_id=%.128q", value.GetRoomId())
	}
	if value, ok := request.(interface{ GetGameSessionId() string }); ok {
		fields += fmt.Sprintf(" game_session_id=%.128q", value.GetGameSessionId())
	}
	if value, ok := request.(interface{ GetLastSeenSeq() uint64 }); ok {
		fields += fmt.Sprintf(" last_seen_seq=%d", value.GetLastSeenSeq())
	}
	return fields
}
