package grpc

import (
	"bytes"
	"context"
	"os"
	"strings"
	"testing"

	huaiv1 "github.com/Derek0120/eighty-point-huai-an/server/gen/huai/v1"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/logging"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/proto"
)

func TestLoggingInterceptorPreservesResultsAndRequest(t *testing.T) {
	var output bytes.Buffer
	logging.Configure(&output)
	t.Cleanup(func() { logging.Configure(os.Stderr) })
	request := &huaiv1.SubmitActionRequest{
		RequestId: "00000000-0000-4000-8000-000000000001", ExpectedVersion: 17,
		GameSessionId: "room-1", HandId: "private-hand",
	}
	before := proto.Clone(request)
	interceptor := LoggingUnaryServerInterceptor()
	info := &grpc.UnaryServerInfo{FullMethod: "/huai.v1.GameService/SubmitAction"}
	response := &huaiv1.Empty{}
	for _, failure := range []error{nil, status.Error(codes.Aborted, "secret-message"), status.Error(codes.Internal, "secret-message")} {
		result, err := interceptor(context.Background(), request, info, func(context.Context, any) (any, error) {
			return response, failure
		})
		if result != response || err != failure {
			t.Fatal("interceptor changed response or error")
		}
	}
	if !proto.Equal(request, before) {
		t.Fatal("interceptor mutated the request")
	}
	for _, text := range []string{"[INFO]", "[WARN]", "[ERROR]", "code=OK", "code=Aborted", "code=Internal", "expected_version=17", "request_id=", "game_session_id="} {
		if !strings.Contains(output.String(), text) {
			t.Errorf("missing %q: %s", text, &output)
		}
	}
	for _, text := range []string{"private-hand", "secret-message"} {
		if strings.Contains(output.String(), text) {
			t.Errorf("logged sensitive text %q", text)
		}
	}
}

func TestLoggingInterceptorIncludesAuthenticationFailures(t *testing.T) {
	var output bytes.Buffer
	logging.Configure(&output)
	t.Cleanup(func() { logging.Configure(os.Stderr) })
	info := &grpc.UnaryServerInfo{FullMethod: "/huai.v1.RoomService/GetRoom"}
	_, err := LoggingUnaryServerInterceptor()(context.Background(), &huaiv1.RoomRequest{}, info,
		func(ctx context.Context, request any) (any, error) {
			return AuthUnaryServerInterceptor(nil)(ctx, request, info, func(context.Context, any) (any, error) {
				t.Fatal("unauthenticated request reached service")
				return nil, nil
			})
		})
	if status.Code(err) != codes.Unauthenticated || !strings.Contains(output.String(), "code=Unauthenticated") {
		t.Fatalf("authentication failure not preserved/logged: %v %s", err, &output)
	}
}
