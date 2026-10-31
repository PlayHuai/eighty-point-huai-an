package grpc

import (
	"context"
	"errors"
	"net"
	"testing"
	"time"

	huaiv1 "github.com/Derek0120/eighty-point-huai-an/server/gen/huai/v1"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/buildinfo"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/feedback"
	grpcgo "google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
	"google.golang.org/grpc/test/bufconn"
)

type feedbackRepositoryStub struct {
	userID, kind, body string
	err                error
}

func (r *feedbackRepositoryStub) SaveFeedback(_ context.Context, userID, _, kind, body string) error {
	r.userID, r.kind, r.body = userID, kind, body
	return r.err
}

func TestSupportRPCs(t *testing.T) {
	repo := &feedbackRepositoryStub{}
	service, _ := feedback.NewService(repo)
	server := &supportServer{feedback: service, info: buildinfo.Info{
		CommitID: "abc123", Version: "1.2.3", Changelist: "更新记录",
	}}
	request := &huaiv1.SubmitFeedbackRequest{
		Kind: huaiv1.FeedbackKind_FEEDBACK_KIND_BUG, Body: " Bug ",
		RequestId: "00000000-0000-4000-8000-000000000001",
	}

	if _, err := server.SubmitFeedback(context.Background(), request); status.Code(err) != codes.Unauthenticated {
		t.Fatalf("unauthenticated submit: %v", err)
	}
	if _, err := server.GetServerInfo(context.Background(), &huaiv1.Empty{}); status.Code(err) != codes.Unauthenticated {
		t.Fatalf("unauthenticated info: %v", err)
	}
	ctx := context.WithValue(context.Background(), userIDContextKey{}, "authenticated-player")
	if _, err := server.SubmitFeedback(ctx, request); err != nil {
		t.Fatal(err)
	}
	if repo.userID != "authenticated-player" || repo.kind != "bug" || repo.body != "Bug" {
		t.Fatalf("unexpected stored feedback: %+v", repo)
	}
	info, err := server.GetServerInfo(ctx, &huaiv1.Empty{})
	if err != nil || info.GetCommitId() != "abc123" || info.GetVersion() != "1.2.3" || info.GetChangelist() != "更新记录" {
		t.Fatalf("unexpected info: %+v, %v", info, err)
	}
	for _, test := range []struct {
		err  error
		code codes.Code
	}{
		{feedback.ErrRequestConflict, codes.AlreadyExists},
		{errors.New("database unavailable"), codes.Internal},
	} {
		repo.err = test.err
		if _, err := server.SubmitFeedback(ctx, request); status.Code(err) != test.code {
			t.Fatalf("expected %v, got %v", test.code, err)
		}
	}
	repo.err = nil
	request.Kind = huaiv1.FeedbackKind_FEEDBACK_KIND_UNSPECIFIED
	if _, err := server.SubmitFeedback(ctx, request); status.Code(err) != codes.InvalidArgument {
		t.Fatalf("invalid kind: %v", err)
	}
	if err := RegisterSupportService(nil, service); err == nil {
		t.Fatal("nil registrar accepted")
	}
}

func TestSupportGRPCRegistrationAndAuthentication(t *testing.T) {
	listener := bufconn.Listen(1024 * 1024)
	authenticator := &testAuthenticator{userID: "authenticated-player"}
	server := grpcgo.NewServer(grpcgo.UnaryInterceptor(AuthUnaryServerInterceptor(authenticator)))
	repo := &feedbackRepositoryStub{}
	service, _ := feedback.NewService(repo)
	if err := RegisterSupportService(server, service); err != nil {
		t.Fatal(err)
	}
	serveError := make(chan error, 1)
	go func() { serveError <- server.Serve(listener) }()
	t.Cleanup(func() {
		server.Stop()
		if err := <-serveError; err != nil && !errors.Is(err, grpcgo.ErrServerStopped) {
			t.Errorf("serve test gRPC: %v", err)
		}
	})
	conn, err := grpcgo.NewClient("passthrough:///bufnet",
		grpcgo.WithTransportCredentials(insecure.NewCredentials()),
		grpcgo.WithContextDialer(func(ctx context.Context, _ string) (net.Conn, error) {
			return listener.DialContext(ctx)
		}))
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { conn.Close() })
	client := huaiv1.NewSupportServiceClient(conn)
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if _, err := client.GetServerInfo(ctx, &huaiv1.Empty{}); status.Code(err) != codes.Unauthenticated {
		t.Fatalf("unauthenticated wire request: %v", err)
	}
	ctx = metadata.NewOutgoingContext(ctx, metadata.Pairs("authorization", "Bearer test-token"))
	info, err := client.GetServerInfo(ctx, &huaiv1.Empty{})
	if err != nil || info.GetVersion() != buildinfo.Version || info.GetCommitId() != buildinfo.Commit {
		t.Fatalf("unexpected packaged info over gRPC: %v, %v", info, err)
	}
	if _, err := client.SubmitFeedback(ctx, &huaiv1.SubmitFeedbackRequest{
		Kind: huaiv1.FeedbackKind_FEEDBACK_KIND_SUGGESTION,
		Body: "改进大厅", RequestId: "00000000-0000-4000-8000-000000000001",
	}); err != nil {
		t.Fatal(err)
	}
	if repo.userID != "authenticated-player" || repo.kind != "suggestion" || repo.body != "改进大厅" {
		t.Fatalf("wrong feedback identity/payload over gRPC: %+v", repo)
	}
}
