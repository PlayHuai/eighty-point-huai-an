package social

import (
	"context"
	"errors"
	"reflect"
	"testing"
)

type repositoryStub struct {
	players        []Player
	friends        []Friend
	requests       []PendingFriendRequest
	invitations    []RoomInvitation
	query          string
	excludedUserID string
	offset         uint32
	limit          uint32
	userID         string
	targetUserID   string
	requesterID    string
	recipientID    string
	accepted       bool
	roomID         string
	err            error
}

func (r *repositoryStub) SearchPlayers(_ context.Context, query, excludedUserID string, offset, limit uint32) ([]Player, error) {
	r.query, r.excludedUserID, r.offset, r.limit = query, excludedUserID, offset, limit
	if r.err != nil {
		return nil, r.err
	}
	end := min(uint64(offset)+uint64(limit), uint64(len(r.players)))
	if uint64(offset) > uint64(len(r.players)) {
		return nil, nil
	}
	return r.players[offset:uint32(end)], nil
}

func (r *repositoryStub) SendFriendRequest(_ context.Context, userID, targetUserID string) error {
	r.userID, r.targetUserID = userID, targetUserID
	return r.err
}

func (r *repositoryStub) RespondFriendRequest(_ context.Context, requesterID, recipientID string, accept bool) error {
	r.requesterID, r.recipientID, r.accepted = requesterID, recipientID, accept
	return r.err
}

func (r *repositoryStub) ListFriendRequests(_ context.Context, userID string, offset, limit uint32) ([]PendingFriendRequest, error) {
	r.userID, r.offset, r.limit = userID, offset, limit
	if r.err != nil {
		return nil, r.err
	}
	end := min(uint64(offset)+uint64(limit), uint64(len(r.requests)))
	if uint64(offset) > uint64(len(r.requests)) {
		return nil, nil
	}
	return r.requests[offset:uint32(end)], nil
}

func (r *repositoryStub) ListFriends(_ context.Context, userID string, offset, limit uint32) ([]Friend, error) {
	r.userID, r.offset, r.limit = userID, offset, limit
	if r.err != nil {
		return nil, r.err
	}
	end := min(uint64(offset)+uint64(limit), uint64(len(r.friends)))
	if uint64(offset) > uint64(len(r.friends)) {
		return nil, nil
	}
	return r.friends[offset:uint32(end)], nil
}

func (r *repositoryStub) RemoveFriend(_ context.Context, userID, friendID string) error {
	r.userID, r.targetUserID = userID, friendID
	return r.err
}

func (r *repositoryStub) CreateRoomInvite(_ context.Context, userID, roomID, friendID string) error {
	r.userID, r.roomID, r.targetUserID = userID, roomID, friendID
	return r.err
}

func (r *repositoryStub) ListRoomInvitations(_ context.Context, userID string, offset, limit uint32) ([]RoomInvitation, error) {
	r.userID, r.offset, r.limit = userID, offset, limit
	if r.err != nil {
		return nil, r.err
	}
	end := min(uint64(offset)+uint64(limit), uint64(len(r.invitations)))
	if uint64(offset) > uint64(len(r.invitations)) {
		return nil, nil
	}
	return r.invitations[offset:uint32(end)], nil
}

func TestServiceSearchAndListFriendsUseOpaqueOffsets(t *testing.T) {
	repository := &repositoryStub{
		players: []Player{
			{UserID: "p1"}, {UserID: "p2"}, {UserID: "p3"},
		},
		friends: []Friend{
			{Player: Player{UserID: "f1"}}, {Player: Player{UserID: "f2"}}, {Player: Player{UserID: "f3"}},
		},
	}
	service, err := NewService(repository)
	if err != nil {
		t.Fatal(err)
	}

	result, err := service.SearchPlayers(context.Background(), "viewer", "  Alice  ", "", 2)
	if err != nil || !reflect.DeepEqual(result.Items, repository.players[:2]) ||
		result.NextPageToken != "2" || repository.query != "Alice" ||
		repository.excludedUserID != "viewer" || repository.limit != 3 {
		t.Fatalf("SearchPlayers() = %+v, %v; repository = %+v", result, err, repository)
	}
	friendPage, err := service.ListFriends(context.Background(), "viewer", result.NextPageToken, 2)
	if err != nil || !reflect.DeepEqual(friendPage.Items, repository.friends[2:]) ||
		friendPage.NextPageToken != "" || repository.offset != 2 {
		t.Fatalf("ListFriends() = %+v, %v; repository = %+v", friendPage, err, repository)
	}
}

func TestServiceListsIncomingRequestsAndInvitationsWithOpaqueOffsets(t *testing.T) {
	repository := &repositoryStub{
		requests: []PendingFriendRequest{{Player: Player{UserID: "requester-1"}}, {Player: Player{UserID: "requester-2"}}},
		invitations: []RoomInvitation{
			{Inviter: Player{UserID: "inviter-1"}, RoomID: "room-1"},
			{Inviter: Player{UserID: "inviter-2"}, RoomID: "room-2"},
		},
	}
	service, err := NewService(repository)
	if err != nil {
		t.Fatal(err)
	}
	ctx := context.Background()

	requests, err := service.ListFriendRequests(ctx, "recipient", "", 1)
	if err != nil || len(requests.Items) != 1 || requests.Items[0].UserID != "requester-1" ||
		requests.NextPageToken != "1" || repository.userID != "recipient" || repository.limit != 2 {
		t.Fatalf("ListFriendRequests() = %+v, %v; repository = %+v", requests, err, repository)
	}
	invitations, err := service.ListRoomInvitations(ctx, "recipient", "1", 1)
	if err != nil || len(invitations.Items) != 1 || invitations.Items[0].RoomID != "room-2" ||
		invitations.NextPageToken != "" || repository.userID != "recipient" || repository.offset != 1 {
		t.Fatalf("ListRoomInvitations() = %+v, %v; repository = %+v", invitations, err, repository)
	}
}

func TestServiceMutationsAlwaysUseAuthenticatedUser(t *testing.T) {
	repository := &repositoryStub{}
	service, err := NewService(repository)
	if err != nil {
		t.Fatal(err)
	}
	ctx := context.Background()

	if err := service.SendFriendRequest(ctx, "caller", "target"); err != nil ||
		repository.userID != "caller" || repository.targetUserID != "target" {
		t.Fatalf("SendFriendRequest() error = %v; repository = %+v", err, repository)
	}
	if err := service.RespondFriendRequest(ctx, "recipient", "requester", true); err != nil ||
		repository.requesterID != "requester" || repository.recipientID != "recipient" || !repository.accepted {
		t.Fatalf("RespondFriendRequest() error = %v; repository = %+v", err, repository)
	}
	if err := service.RemoveFriend(ctx, "caller", "friend"); err != nil ||
		repository.userID != "caller" || repository.targetUserID != "friend" {
		t.Fatalf("RemoveFriend() error = %v; repository = %+v", err, repository)
	}
	if err := service.SendRoomInvite(ctx, "caller", "room", "friend"); err != nil ||
		repository.userID != "caller" || repository.roomID != "room" || repository.targetUserID != "friend" {
		t.Fatalf("SendRoomInvite() error = %v; repository = %+v", err, repository)
	}
}

type friendPair struct {
	owner string
	peer  string
}

type friendLifecycleRepository struct {
	repositoryStub
	pending map[friendPair]struct{}
	friends map[friendPair]struct{}
}

func newFriendLifecycleRepository() *friendLifecycleRepository {
	return &friendLifecycleRepository{
		pending: make(map[friendPair]struct{}),
		friends: make(map[friendPair]struct{}),
	}
}

func (r *friendLifecycleRepository) SendFriendRequest(_ context.Context, userID, targetUserID string) error {
	pair := friendPair{owner: userID, peer: targetUserID}
	if _, ok := r.friends[pair]; ok {
		return ErrAlreadyFriends
	}
	if _, ok := r.pending[pair]; ok {
		return ErrFriendRequestExists
	}
	if _, ok := r.pending[friendPair{owner: targetUserID, peer: userID}]; ok {
		return ErrFriendRequestExists
	}
	r.pending[pair] = struct{}{}
	return nil
}

func (r *friendLifecycleRepository) RespondFriendRequest(_ context.Context, requesterID, recipientID string, accept bool) error {
	pair := friendPair{owner: requesterID, peer: recipientID}
	if _, ok := r.pending[pair]; !ok {
		return ErrFriendRequestMissing
	}
	delete(r.pending, pair)
	if accept {
		r.friends[pair] = struct{}{}
		r.friends[friendPair{owner: recipientID, peer: requesterID}] = struct{}{}
	}
	return nil
}

func (r *friendLifecycleRepository) ListFriendRequests(_ context.Context, userID string, _, _ uint32) ([]PendingFriendRequest, error) {
	requests := make([]PendingFriendRequest, 0)
	for pair := range r.pending {
		if pair.peer == userID {
			requests = append(requests, PendingFriendRequest{Player: Player{UserID: pair.owner}})
		}
	}
	return requests, nil
}

func (r *friendLifecycleRepository) ListFriends(_ context.Context, userID string, _, _ uint32) ([]Friend, error) {
	friends := make([]Friend, 0)
	for pair := range r.friends {
		if pair.owner == userID {
			friends = append(friends, Friend{Player: Player{UserID: pair.peer}})
		}
	}
	return friends, nil
}

func (r *friendLifecycleRepository) RemoveFriend(_ context.Context, userID, friendID string) error {
	pair := friendPair{owner: userID, peer: friendID}
	if _, ok := r.friends[pair]; !ok {
		return ErrNotFriends
	}
	delete(r.friends, pair)
	delete(r.friends, friendPair{owner: friendID, peer: userID})
	return nil
}

func TestFriendRequestLifecycle(t *testing.T) {
	repository := newFriendLifecycleRepository()
	service, err := NewService(repository)
	if err != nil {
		t.Fatal(err)
	}
	ctx := context.Background()

	if err := service.SendFriendRequest(ctx, "alice", "bob"); err != nil {
		t.Fatal(err)
	}
	requests, err := service.ListFriendRequests(ctx, "bob", "", 0)
	if err != nil || len(requests.Items) != 1 || requests.Items[0].UserID != "alice" {
		t.Fatalf("ListFriendRequests() = %+v, %v; want Alice's request", requests, err)
	}
	friends, err := service.ListFriends(ctx, "alice", "", 0)
	if err != nil || len(friends.Items) != 0 {
		t.Fatalf("ListFriends() before acceptance = %+v, %v; want no friends", friends, err)
	}

	if err := service.RespondFriendRequest(ctx, "bob", "alice", true); err != nil {
		t.Fatal(err)
	}
	requests, err = service.ListFriendRequests(ctx, "bob", "", 0)
	if err != nil || len(requests.Items) != 0 {
		t.Fatalf("ListFriendRequests() after acceptance = %+v, %v; want no requests", requests, err)
	}
	for _, owner := range []string{"alice", "bob"} {
		peer := "alice"
		if owner == "alice" {
			peer = "bob"
		}
		friends, err = service.ListFriends(ctx, owner, "", 0)
		if err != nil || len(friends.Items) != 1 || friends.Items[0].UserID != peer {
			t.Fatalf("ListFriends(%q) = %+v, %v; want %q", owner, friends, err, peer)
		}
	}

	if err := service.RemoveFriend(ctx, "alice", "bob"); err != nil {
		t.Fatal(err)
	}
	for _, owner := range []string{"alice", "bob"} {
		friends, err = service.ListFriends(ctx, owner, "", 0)
		if err != nil || len(friends.Items) != 0 {
			t.Fatalf("ListFriends(%q) after removal = %+v, %v; want no friends", owner, friends, err)
		}
	}
	if err := service.RespondFriendRequest(ctx, "bob", "alice", true); !errors.Is(err, ErrFriendRequestMissing) {
		t.Fatalf("RespondFriendRequest() after resolution error = %v, want ErrFriendRequestMissing", err)
	}
}

func TestServiceRejectsInvalidRequestsAndPropagatesRepositoryErrors(t *testing.T) {
	repository := &repositoryStub{}
	service, err := NewService(repository)
	if err != nil {
		t.Fatal(err)
	}
	ctx := context.Background()
	if _, err := service.SearchPlayers(ctx, "viewer", " ", "", 10); !errors.Is(err, ErrInvalidInput) {
		t.Fatalf("empty player search error = %v", err)
	}
	if _, err := service.SearchPlayers(ctx, "viewer", "name", "bad", 10); !errors.Is(err, ErrInvalidInput) {
		t.Fatalf("invalid page token error = %v", err)
	}
	if err := service.SendFriendRequest(ctx, "same", "same"); !errors.Is(err, ErrInvalidInput) {
		t.Fatalf("self friend request error = %v", err)
	}
	if err := service.RespondFriendRequest(ctx, "same", "same", true); !errors.Is(err, ErrInvalidInput) {
		t.Fatalf("self response error = %v", err)
	}
	if err := service.RemoveFriend(ctx, "same", "same"); !errors.Is(err, ErrInvalidInput) {
		t.Fatalf("self removal error = %v", err)
	}
	if err := service.SendRoomInvite(ctx, "same", "room", "same"); !errors.Is(err, ErrInvalidInput) {
		t.Fatalf("self invitation error = %v", err)
	}

	repository.err = ErrAlreadyFriends
	if err := service.SendFriendRequest(ctx, "caller", "friend"); !errors.Is(err, ErrAlreadyFriends) {
		t.Fatalf("repository error = %v, want ErrAlreadyFriends", err)
	}
}

func TestPageWindowBounds(t *testing.T) {
	for _, token := range []string{"-1", "4294967296"} {
		if _, _, err := pageWindow(token, 10); !errors.Is(err, ErrInvalidInput) {
			t.Errorf("pageWindow(%q) error = %v, want ErrInvalidInput", token, err)
		}
	}
	if _, _, err := pageWindow("1000001", 10); !errors.Is(err, ErrInvalidInput) {
		t.Fatalf("excessive page offset error = %v, want ErrInvalidInput", err)
	}
	if _, _, err := pageWindow("", maxPageSize+1); !errors.Is(err, ErrInvalidInput) {
		t.Fatalf("oversized page error = %v, want ErrInvalidInput", err)
	}
}
