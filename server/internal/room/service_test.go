package room

import (
	"errors"
	"sync"
	"testing"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/lobby"
)

func TestRoomAdmissionSeatingAndStart(t *testing.T) {
	manager := NewManager()
	created, err := manager.CreateRoom(lobby.HallOrdinary, "owner", 9000, Settings{
		Name: "private table", MinimumPoints: 8000, Password: "correct horse",
	})
	if err != nil {
		t.Fatal(err)
	}
	if created.Room.OccupiedSeats != 0 || len(created.Members) != 0 {
		t.Fatalf("new room is not empty: %+v", created)
	}

	if _, err := manager.JoinRoom(created.Room.ID, "below-room-gate", 7999, "correct horse", created.Version); !errors.Is(err, ErrAdmissionDenied) {
		t.Fatalf("JoinRoom below room gate: got %v, want ErrAdmissionDenied", err)
	}
	if _, err := manager.JoinRoom(created.Room.ID, "underqualified", -1, "correct horse", created.Version); !errors.Is(err, ErrInvalidInput) {
		t.Fatalf("JoinRoom with invalid points: got %v, want ErrInvalidInput", err)
	}
	if _, err := manager.JoinRoom(created.Room.ID, "wrong-password", 9000, "wrong", created.Version); !errors.Is(err, ErrInvalidPassword) {
		t.Fatalf("JoinRoom with wrong password: got %v, want ErrInvalidPassword", err)
	}

	current := created
	for _, userID := range []string{"owner", "player-2", "player-3", "player-4"} {
		current, err = manager.JoinRoom(created.Room.ID, userID, 9000, "correct horse", current.Version)
		if err != nil {
			t.Fatalf("JoinRoom(%q): %v", userID, err)
		}
	}
	if current.Room.OccupiedSeats != 4 {
		t.Fatalf("occupied seats = %d, want 4", current.Room.OccupiedSeats)
	}
	for seat, member := range current.Members {
		if member.Role != RolePlayer || member.Seat != uint32(seat+1) {
			t.Fatalf("members are not seated in order: %+v", current.Members)
		}
	}

	started, err := manager.Start(created.Room.ID, "player-2", current.Version)
	if !errors.Is(err, ErrOwnerRequired) {
		t.Fatalf("Start by non-owner: got %v, want ErrOwnerRequired", err)
	}
	started, err = manager.Start(created.Room.ID, "owner", current.Version)
	if err != nil {
		t.Fatal(err)
	}
	if started.Room.Status != StatusPlaying {
		t.Fatalf("room status = %q, want %q", started.Room.Status, StatusPlaying)
	}
	if _, err := manager.ChangeSeat(created.Room.ID, "owner", 2, started.Version); !errors.Is(err, ErrRoomStarted) {
		t.Fatalf("ChangeSeat after start: got %v, want ErrRoomStarted", err)
	}
	if _, err := manager.LeaveRoom(created.Room.ID, "owner", started.Version); !errors.Is(err, ErrRoomStarted) {
		t.Fatalf("LeaveRoom after start: got %v, want ErrRoomStarted", err)
	}
}

func TestRoomSpectatingAndHallIsolation(t *testing.T) {
	manager := NewManager()
	ordinary, err := manager.CreateRoom(lobby.HallOrdinary, "ordinary-owner", 9000, Settings{
		Name: "ordinary", MinimumPoints: 8000, AllowSpectators: true, Password: "secret",
	})
	if err != nil {
		t.Fatal(err)
	}
	advanced, err := manager.CreateRoom(lobby.HallAdvanced, "advanced-owner", 10000, Settings{
		Name: "advanced", AllowSpectators: true,
	})
	if err != nil {
		t.Fatal(err)
	}

	rooms, err := manager.ListRooms(lobby.HallOrdinary, 0)
	if err != nil {
		t.Fatal(err)
	}
	if len(rooms) != 1 || rooms[0].ID != ordinary.Room.ID {
		t.Fatalf("ordinary room list leaked another hall: %+v", rooms)
	}
	if _, err := manager.ListRooms(lobby.HallAdvanced, 9999); !errors.Is(err, ErrAdmissionDenied) {
		t.Fatalf("ListRooms for an ineligible hall: got %v, want ErrAdmissionDenied", err)
	}
	if _, err := manager.JoinSpectator(advanced.Room.ID, "spectator", 9999, "", 1, advanced.Version); !errors.Is(err, ErrAdmissionDenied) {
		t.Fatalf("cross-hall spectating: got %v, want ErrAdmissionDenied", err)
	}

	if rooms[0].Version != ordinary.Version {
		t.Fatalf("listed room version = %d, want %d", rooms[0].Version, ordinary.Version)
	}
	if _, err := manager.JoinSpectator(ordinary.Room.ID, "spectator", 0, "", 2, ordinary.Version); !errors.Is(err, ErrInvalidPassword) {
		t.Fatalf("JoinSpectator without password: got %v, want ErrInvalidPassword", err)
	}
	if _, err := manager.SitDown(ordinary.Room.ID, "spectator", 2, 9000, ordinary.Version); !errors.Is(err, ErrNotMember) {
		t.Fatalf("SitDown after failed spectator admission: got %v, want ErrNotMember", err)
	}
	details, err := manager.JoinSpectator(ordinary.Room.ID, "spectator", 0, "secret", 2, ordinary.Version)
	if err != nil {
		t.Fatal(err)
	}
	rooms, err = manager.ListRooms(lobby.HallOrdinary, 0)
	if err != nil {
		t.Fatal(err)
	}
	if rooms[0].Version != details.Version {
		t.Fatalf("listed room version = %d, want current version %d", rooms[0].Version, details.Version)
	}
	spectator := memberFor(t, details, "spectator")
	if spectator.Role != RoleSpectator || spectator.ViewSeat != 2 || spectator.Seat != 0 {
		t.Fatalf("unexpected spectator state: %+v", spectator)
	}
	if _, err := manager.SetHandVisibility(ordinary.Room.ID, "spectator", true, details.Version); !errors.Is(err, ErrNotMember) {
		t.Fatalf("spectator changed a player's hand visibility: got %v, want ErrNotMember", err)
	}
}

func TestFriendRoomBypassesRankedAdmissionOnlyForInvitedFriends(t *testing.T) {
	manager := NewManager()
	created, err := manager.CreateRoom(lobby.HallFriend, "owner", 0, Settings{Name: "friends"})
	if err != nil {
		t.Fatal(err)
	}
	owner, err := manager.JoinRoom(created.Room.ID, "owner", 0, "", created.Version)
	if err != nil {
		t.Fatalf("friend-room owner could not join at zero points: %v", err)
	}
	if _, err := manager.ListRooms(lobby.HallFriend, 100000); !errors.Is(err, ErrInvitationRequired) {
		t.Fatalf("friend room appeared in public listing: %v", err)
	}
	if _, err := manager.JoinRoom(created.Room.ID, "stranger", 100000, "", owner.Version); !errors.Is(err, ErrInvitationRequired) {
		t.Fatalf("non-invitee joined friend room: %v", err)
	}
	if err := manager.InviteFriend(created.Room.ID, "owner", "friend"); err != nil {
		t.Fatalf("InviteFriend() error = %v", err)
	}
	if _, err := manager.JoinInvitedFriendRoom(created.Room.ID, "stranger", "", "request-stranger", owner.Version); !errors.Is(err, ErrInvitationRequired) {
		t.Fatalf("uninvited user bypassed admission: %v", err)
	}
	friend, err := manager.JoinInvitedFriendRoom(created.Room.ID, "friend", "", "request-friend", owner.Version)
	if err != nil {
		t.Fatalf("invited zero-point friend could not join: %v", err)
	}
	if friend.Room.OccupiedSeats != 2 {
		t.Fatalf("occupied seats = %d, want 2", friend.Room.OccupiedSeats)
	}
	if _, err := manager.JoinInvitedFriendRoom(created.Room.ID, "friend", "", "request-friend", 0); err != nil {
		t.Fatalf("retrying a consumed invitation was not idempotent: %v", err)
	}
	if _, err := manager.JoinInvitedFriendRoom(created.Room.ID, "stranger", "", "request-friend", 0); !errors.Is(err, ErrInvitationRequestConflict) {
		t.Fatalf("reused invitation request ID error = %v, want ErrInvitationRequestConflict", err)
	}
	_, err = manager.LeaveRoom(created.Room.ID, "friend", friend.Version)
	if err != nil {
		t.Fatal(err)
	}
	if _, err := manager.JoinInvitedFriendRoom(created.Room.ID, "friend", "", "request-rejoin", 0); !errors.Is(err, ErrInvitationRequired) {
		t.Fatalf("a consumed invitation allowed rejoining after leave: %v", err)
	}
	if _, err := manager.JoinInvitedFriendRoom(created.Room.ID, "friend", "", "request-friend", 0); !errors.Is(err, ErrNotMember) {
		t.Fatalf("replayed invitation exposed a former member's room: %v", err)
	}
	if _, err := manager.CreateRoom(lobby.HallOrdinary, "low-point-owner", 0, Settings{Name: "ranked"}); err != nil {
		t.Fatalf("ordinary hall admission changed: %v", err)
	}
	if _, err := manager.CreateRoom(lobby.HallFriend, "owner", 0, Settings{Name: "invalid gate", MinimumPoints: 1}); !errors.Is(err, ErrAdmissionDenied) {
		t.Fatalf("friend room accepted a misleading minimum-points gate: %v", err)
	}
}

func TestRoomMutationsUseOptimisticVersioning(t *testing.T) {
	manager := NewManager()
	created, err := manager.CreateRoom(lobby.HallOrdinary, "owner", 0, Settings{Name: "table"})
	if err != nil {
		t.Fatal(err)
	}

	var wg sync.WaitGroup
	errs := make(chan error, 2)
	for _, userID := range []string{"player-a", "player-b"} {
		wg.Add(1)
		go func(userID string) {
			defer wg.Done()
			_, err := manager.JoinRoom(created.Room.ID, userID, 0, "", created.Version)
			errs <- err
		}(userID)
	}
	wg.Wait()
	close(errs)

	successes, conflicts := 0, 0
	for err := range errs {
		switch {
		case err == nil:
			successes++
		case errors.Is(err, ErrVersionConflict):
			conflicts++
		default:
			t.Fatalf("unexpected concurrent join error: %v", err)
		}
	}
	if successes != 1 || conflicts != 1 {
		t.Fatalf("concurrent joins: successes=%d conflicts=%d, want 1 each", successes, conflicts)
	}

	second, err := manager.CreateRoom(lobby.HallOrdinary, "second-owner", 0, Settings{Name: "other table"})
	if err != nil {
		t.Fatal(err)
	}
	if _, err := manager.JoinRoom(second.Room.ID, "isolated-player", 0, "", second.Version); err != nil {
		t.Fatalf("mutation in another room was affected: %v", err)
	}
}

func TestFriendInvitationReservationPublishesOnlyAfterCommit(t *testing.T) {
	manager := NewManager()
	created, err := manager.CreateRoom(lobby.HallFriend, "owner", 0, Settings{Name: "table"})
	if err != nil {
		t.Fatal(err)
	}
	reservation, err := manager.ReserveFriendInvitation(created.Room.ID, "owner", "friend")
	if err != nil {
		t.Fatal(err)
	}
	if _, err := manager.JoinInvitedFriendRoom(created.Room.ID, "friend", "", "pending", 0); !errors.Is(err, ErrInvitationRequired) {
		t.Fatalf("uncommitted invitation was consumable: %v", err)
	}
	manager.CommitFriendInvitation(created.Room.ID, reservation)
	resend, err := manager.ReserveFriendInvitation(created.Room.ID, "owner", "friend")
	if err != nil {
		t.Fatal(err)
	}
	manager.CancelFriendInvitation(created.Room.ID, resend)
	joined, err := manager.JoinInvitedFriendRoom(created.Room.ID, "friend", "", "committed", 0)
	if err != nil {
		t.Fatalf("canceling a resend revoked the prior committed invite: %v", err)
	}
	standing, err := manager.StandUp(created.Room.ID, "friend", joined.Version)
	if err != nil {
		t.Fatal(err)
	}
	seated, err := manager.SitDown(created.Room.ID, "friend", 2, 0, standing.Version)
	if err != nil {
		t.Fatalf("authorized friend could not sit down again: %v", err)
	}
	if memberFor(t, seated, "friend").Seat != 2 {
		t.Fatalf("friend seat = %d, want 2", memberFor(t, seated, "friend").Seat)
	}
}

func TestRoomSupportsSpectatorConversionAndPreGameSeatChanges(t *testing.T) {
	manager := NewManager()
	created, err := manager.CreateRoom(lobby.HallOrdinary, "owner", 0, Settings{
		Name: "table", AllowSpectators: true, Password: "secret",
	})
	if err != nil {
		t.Fatal(err)
	}
	if _, err := manager.JoinSpectator(created.Room.ID, "guest", 0, "", 4, created.Version); !errors.Is(err, ErrInvalidPassword) {
		t.Fatalf("JoinSpectator without password: got %v, want ErrInvalidPassword", err)
	}
	spectator, err := manager.JoinSpectator(created.Room.ID, "guest", 0, "secret", 4, created.Version)
	if err != nil {
		t.Fatal(err)
	}
	sat, err := manager.SitDown(created.Room.ID, "guest", 2, 0, spectator.Version)
	if err != nil {
		t.Fatal(err)
	}
	if got := memberFor(t, sat, "guest"); got.Role != RolePlayer || got.Seat != 2 || got.ViewSeat != 0 {
		t.Fatalf("unexpected seated member: %+v", got)
	}
	moved, err := manager.ChangeSeat(created.Room.ID, "guest", 3, sat.Version)
	if err != nil {
		t.Fatal(err)
	}
	if got := memberFor(t, moved, "guest").Seat; got != 3 {
		t.Fatalf("seat after change = %d, want 3", got)
	}
}

func TestRoomSupportsStandingUpAndSittingDownAgain(t *testing.T) {
	manager := NewManager()
	created, err := manager.CreateRoom(lobby.HallOrdinary, "owner", 0, Settings{Name: "table"})
	if err != nil {
		t.Fatal(err)
	}
	seated, err := manager.JoinRoom(created.Room.ID, "owner", 0, "", created.Version)
	if err != nil {
		t.Fatal(err)
	}
	if _, err := manager.StandUp(created.Room.ID, "owner", created.Version); !errors.Is(err, ErrVersionConflict) {
		t.Fatalf("StandUp with stale version: got %v, want ErrVersionConflict", err)
	}
	standing, err := manager.StandUp(created.Room.ID, "owner", seated.Version)
	if err != nil {
		t.Fatal(err)
	}
	if standing.Room.OccupiedSeats != 0 || memberFor(t, standing, "owner").Seat != 0 {
		t.Fatalf("standing player still occupies a seat: %+v", standing)
	}
	if _, err := manager.Start(created.Room.ID, "owner", standing.Version); !errors.Is(err, ErrRoomNotReady) {
		t.Fatalf("Start after owner stood up: got %v, want ErrRoomNotReady", err)
	}
	resat, err := manager.SitDown(created.Room.ID, "owner", 2, 0, standing.Version)
	if err != nil {
		t.Fatal(err)
	}
	if got := memberFor(t, resat, "owner").Seat; got != 2 {
		t.Fatalf("seat after sitting down again = %d, want 2", got)
	}
}

func TestStandingPlayerCanLeaveDuringPlay(t *testing.T) {
	manager := NewManager()
	created, err := manager.CreateRoom(lobby.HallOrdinary, "owner", 0, Settings{Name: "table"})
	if err != nil {
		t.Fatal(err)
	}

	current := created
	for _, userID := range []string{"owner", "player-2", "player-3", "player-4"} {
		current, err = manager.JoinRoom(created.Room.ID, userID, 0, "", current.Version)
		if err != nil {
			t.Fatalf("JoinRoom(%q): %v", userID, err)
		}
	}
	current, err = manager.StandUp(created.Room.ID, "owner", current.Version)
	if err != nil {
		t.Fatal(err)
	}
	current, err = manager.JoinRoom(created.Room.ID, "replacement", 0, "", current.Version)
	if err != nil {
		t.Fatal(err)
	}
	current, err = manager.Start(created.Room.ID, "owner", current.Version)
	if err != nil {
		t.Fatal(err)
	}
	if _, err := manager.LeaveRoom(created.Room.ID, "owner", current.Version); err != nil {
		t.Fatalf("LeaveRoom for standing player during play: %v", err)
	}
}

func TestMembersCanLeaveClosedRoomsAndClosedRoomsAreEvicted(t *testing.T) {
	manager := NewManager()
	created, err := manager.CreateRoom(lobby.HallOrdinary, "owner", 0, Settings{Name: "table"})
	if err != nil {
		t.Fatal(err)
	}
	joined, err := manager.JoinRoom(created.Room.ID, "owner", 0, "", created.Version)
	if err != nil {
		t.Fatal(err)
	}
	joined, err = manager.JoinRoom(created.Room.ID, "player", 0, "", joined.Version)
	if err != nil {
		t.Fatal(err)
	}
	closed, err := manager.Close(created.Room.ID, "owner", joined.Version)
	if err != nil {
		t.Fatal(err)
	}
	playerLeft, err := manager.LeaveRoom(created.Room.ID, "player", closed.Version)
	if err != nil {
		t.Fatalf("player leaving closed room: %v", err)
	}
	ownerLeft, err := manager.LeaveRoom(created.Room.ID, "owner", playerLeft.Version)
	if err != nil {
		t.Fatalf("owner leaving closed room: %v", err)
	}
	if len(ownerLeft.Members) != 0 {
		t.Fatalf("closed room retained members: %+v", ownerLeft.Members)
	}
	if _, err := manager.GetRoom(created.Room.ID, "owner"); !errors.Is(err, ErrRoomNotFound) {
		t.Fatalf("GetRoom after last member left: got %v, want ErrRoomNotFound", err)
	}
	rooms, err := manager.ListRooms(lobby.HallOrdinary, 0)
	if err != nil {
		t.Fatal(err)
	}
	if len(rooms) != 0 {
		t.Fatalf("closed room remains listed: %+v", rooms)
	}
}

func TestOwnerDepartureClosesAndEvictsRoomAfterMembersLeave(t *testing.T) {
	manager := NewManager()
	created, err := manager.CreateRoom(lobby.HallOrdinary, "owner", 0, Settings{Name: "table"})
	if err != nil {
		t.Fatal(err)
	}
	joined, err := manager.JoinRoom(created.Room.ID, "owner", 0, "", created.Version)
	if err != nil {
		t.Fatal(err)
	}
	joined, err = manager.JoinRoom(created.Room.ID, "player", 0, "", joined.Version)
	if err != nil {
		t.Fatal(err)
	}
	ownerLeft, err := manager.LeaveRoom(created.Room.ID, "owner", joined.Version)
	if err != nil {
		t.Fatal(err)
	}
	if ownerLeft.Room.Status != StatusClosed {
		t.Fatalf("room status after owner departure = %q, want %q", ownerLeft.Room.Status, StatusClosed)
	}
	if _, err := manager.LeaveRoom(created.Room.ID, "player", ownerLeft.Version); err != nil {
		t.Fatalf("player leaving after owner departure: %v", err)
	}
	if _, err := manager.GetRoom(created.Room.ID, "player"); !errors.Is(err, ErrRoomNotFound) {
		t.Fatalf("GetRoom after last member left: got %v, want ErrRoomNotFound", err)
	}
}

func TestClosedRoomEvictionIsSafeWithConcurrentLookups(t *testing.T) {
	manager := NewManager()
	created, err := manager.CreateRoom(lobby.HallOrdinary, "owner", 0, Settings{Name: "table"})
	if err != nil {
		t.Fatal(err)
	}
	start := make(chan struct{})
	errs := make(chan error, 16)
	var wg sync.WaitGroup
	for i := 0; i < cap(errs); i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			<-start
			_, err := manager.GetRoom(created.Room.ID, "nonmember")
			errs <- err
		}()
	}
	close(start)
	_, closeErr := manager.Close(created.Room.ID, "owner", created.Version)
	if closeErr != nil {
		t.Fatal(closeErr)
	}
	wg.Wait()
	close(errs)
	for err := range errs {
		if !errors.Is(err, ErrRoomNotFound) && !errors.Is(err, ErrNotMember) {
			t.Fatalf("concurrent GetRoom: got %v, want ErrRoomNotFound or ErrNotMember", err)
		}
	}
}

func TestCanInviteAllowsRoomOwnerAndSeatedPlayers(t *testing.T) {
	manager := NewManager()
	created, err := manager.CreateRoom(lobby.HallOrdinary, "owner", 9000, Settings{Name: "table"})
	if err != nil {
		t.Fatal(err)
	}
	if !manager.CanInvite(created.Room.ID, "owner") {
		t.Fatal("unseated owner cannot invite")
	}
	if manager.CanInvite(created.Room.ID, "outsider") {
		t.Fatal("non-member can invite")
	}
	joined, err := manager.JoinRoom(created.Room.ID, "player", 9000, "", created.Version)
	if err != nil {
		t.Fatal(err)
	}
	standing, err := manager.StandUp(created.Room.ID, "player", joined.Version)
	if err != nil {
		t.Fatal(err)
	}
	if manager.CanInvite(created.Room.ID, "player") {
		t.Fatal("unseated player can invite")
	}
	seated, err := manager.SitDown(created.Room.ID, "player", 1, 9000, standing.Version)
	if err != nil {
		t.Fatal(err)
	}
	if !manager.CanInvite(created.Room.ID, "player") {
		t.Fatal("seated player cannot invite")
	}
	if _, err := manager.Close(created.Room.ID, "owner", seated.Version); err != nil {
		t.Fatal(err)
	}
	if manager.CanInvite(created.Room.ID, "owner") {
		t.Fatal("owner can invite to closed room")
	}
}

func memberFor(t *testing.T, details Details, userID string) Member {
	t.Helper()
	for _, member := range details.Members {
		if member.UserID == userID {
			return member
		}
	}
	t.Fatalf("user %q not in room details", userID)
	return Member{}
}
