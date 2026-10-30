package room

import (
	"context"
	"crypto/rand"
	"crypto/subtle"
	"encoding/hex"
	"errors"
	"sort"
	"strings"
	"sync"
	"unicode/utf8"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/lobby"
	"golang.org/x/crypto/argon2"
)

var (
	ErrInvalidInput              = errors.New("invalid room input")
	ErrRoomNotFound              = errors.New("room not found")
	ErrNotMember                 = errors.New("user is not a room member")
	ErrAlreadyMember             = errors.New("user is already a room member")
	ErrRoomFull                  = errors.New("room has no available seats")
	ErrSpectatorsDisabled        = errors.New("spectating is disabled")
	ErrInvalidPassword           = errors.New("invalid room password")
	ErrAdmissionDenied           = errors.New("hall or room admission denied")
	ErrSeatUnavailable           = errors.New("seat is unavailable")
	ErrRoomStarted               = errors.New("room is already playing")
	ErrRoomNotReady              = errors.New("room requires four seated players")
	ErrOwnerRequired             = errors.New("room owner permission required")
	ErrVersionConflict           = errors.New("room version conflict")
	ErrRoomClosed                = errors.New("room is closed")
	ErrInvitationRequired        = errors.New("friend room invitation required")
	ErrInvitationRequestConflict = errors.New("invitation request ID reused by another user")
)

type Status string

const (
	StatusWaiting Status = "WAITING"
	StatusPlaying Status = "PLAYING"
	StatusClosed  Status = "CLOSED"
)

type Role string

const (
	RolePlayer    Role = "PLAYER"
	RoleSpectator Role = "SPECTATOR"
)

type Settings struct {
	Name            string
	MinimumPoints   int64
	AllowSpectators bool
	Password        string
}

type Summary struct {
	ID              string
	HallID          string
	OwnerID         string
	Name            string
	Status          Status
	OccupiedSeats   uint32
	Capacity        uint32
	HasPassword     bool
	AllowSpectators bool
	MinimumPoints   int64
	Version         uint64
}

type Member struct {
	UserID   string
	Role     Role
	Seat     uint32
	ViewSeat uint32
	ShowHand bool
}

type Details struct {
	Room           Summary
	Members        []Member
	Version        uint64
	GameSessionID  string
}

type memberState struct {
	Member
}

type roomState struct {
	mu             sync.Mutex
	summary        Summary
	ownerID        string
	minimumPoints  int64
	passwordSalt   [16]byte
	passwordHash   []byte
	members        map[string]memberState
	invitees       map[string]struct{}
	joinedInvites  map[string]struct{}
	inviteRequests map[string]string
	pendingInvites map[string]string
	version        uint64
}

type Manager struct {
	mu          sync.RWMutex
	rooms       map[string]*roomState
	hallRoomIDs map[string][]string
	observerMu  sync.RWMutex
	observer    func(Details)
}

func (m *Manager) SetObserver(observer func(Details)) {
	m.observerMu.Lock()
	m.observer = observer
	m.observerMu.Unlock()
}

func (m *Manager) notifyRoom(details Details) {
	m.observerMu.RLock()
	observer := m.observer
	m.observerMu.RUnlock()
	if observer != nil {
		observer(details)
	}
}

func NewManager() *Manager {
	return &Manager{
		rooms:       make(map[string]*roomState),
		hallRoomIDs: make(map[string][]string),
	}
}

func (m *Manager) CreateRoom(hallID, ownerID string, ownerPoints int64, settings Settings) (Details, error) {
	hall, err := lobby.FindHall(hallID)
	if err != nil {
		return Details{}, lobby.ErrUnknownHall
	}
	if ownerID == "" || ownerPoints < 0 || settings.MinimumPoints < 0 || !validName(settings.Name) ||
		!utf8.ValidString(settings.Password) || len(settings.Password) > 128 {
		return Details{}, ErrInvalidInput
	}
	if hallID == lobby.HallFriend && (settings.MinimumPoints != 0 || settings.Password != "") ||
		hallID != lobby.HallFriend && (!lobby.CanEnter(ownerPoints, hallID) || settings.MinimumPoints > ownerPoints ||
			(hall.MaximumPoints != 0 && settings.MinimumPoints > hall.MaximumPoints)) {
		return Details{}, ErrAdmissionDenied
	}

	id, err := newRoomID()
	if err != nil {
		return Details{}, err
	}
	state := &roomState{
		summary: Summary{
			ID: id, HallID: hallID, OwnerID: ownerID, Name: strings.TrimSpace(settings.Name),
			Status: StatusWaiting, Capacity: 4,
			HasPassword: settings.Password != "", AllowSpectators: settings.AllowSpectators,
			MinimumPoints: settings.MinimumPoints,
		},
		ownerID: ownerID, minimumPoints: settings.MinimumPoints,
		members: make(map[string]memberState), invitees: make(map[string]struct{}),
		joinedInvites: make(map[string]struct{}), inviteRequests: make(map[string]string),
		pendingInvites: make(map[string]string),
		version:        1,
	}
	if settings.Password != "" {
		if _, err := rand.Read(state.passwordSalt[:]); err != nil {
			return Details{}, err
		}
		state.passwordHash = hashPassword(settings.Password, state.passwordSalt[:])
	}

	m.mu.Lock()
	m.rooms[id] = state
	m.insertRoomIDLocked(hallID, id)
	m.mu.Unlock()
	details := snapshot(state)
	m.notifyRoom(details)
	return details, nil
}

func (m *Manager) ListRooms(hallID string, userPoints int64) ([]Summary, error) {
	if err := validateRoomListing(hallID, userPoints); err != nil {
		return nil, err
	}
	m.mu.RLock()
	ids := append([]string(nil), m.hallRoomIDs[hallID]...)
	rooms := make([]*roomState, 0, len(ids))
	for _, id := range ids {
		if state := m.rooms[id]; state != nil {
			rooms = append(rooms, state)
		}
	}
	m.mu.RUnlock()

	result := make([]Summary, 0)
	for _, state := range rooms {
		state.mu.Lock()
		if state.summary.HallID == hallID && state.summary.Status != StatusClosed {
			summary := state.summary
			summary.Version = state.version
			result = append(result, summary)
		}
		state.mu.Unlock()
	}
	return result, nil
}

func (m *Manager) ListRoomsPage(
	hallID string,
	userPoints int64,
	afterRoomID string,
	pageSize uint32,
) ([]Summary, bool, error) {
	if err := validateRoomListing(hallID, userPoints); err != nil {
		return nil, false, err
	}
	if pageSize == 0 || pageSize > 100 {
		return nil, false, ErrInvalidInput
	}

	result := make([]Summary, 0, pageSize+1)
	scanAfter := afterRoomID
	for len(result) <= int(pageSize) {
		remaining := int(pageSize) + 1 - len(result)
		m.mu.RLock()
		ids := m.hallRoomIDs[hallID]
		start := sort.Search(len(ids), func(i int) bool { return ids[i] > scanAfter })
		end := min(start+remaining, len(ids))
		candidates := make([]*roomState, 0, end-start)
		candidateIDs := make([]string, 0, end-start)
		for _, id := range ids[start:end] {
			if state := m.rooms[id]; state != nil {
				candidates = append(candidates, state)
				candidateIDs = append(candidateIDs, id)
			}
		}
		m.mu.RUnlock()
		if len(candidateIDs) == 0 {
			break
		}

		for i, state := range candidates {
			scanAfter = candidateIDs[i]
			state.mu.Lock()
			if state.summary.HallID == hallID && state.summary.Status != StatusClosed {
				summary := state.summary
				summary.Version = state.version
				result = append(result, summary)
			}
			state.mu.Unlock()
			if len(result) > int(pageSize) {
				return result[:pageSize], true, nil
			}
		}
	}
	return result, false, nil
}

func validateRoomListing(hallID string, userPoints int64) error {
	if _, err := lobby.FindHall(hallID); err != nil {
		return lobby.ErrUnknownHall
	}
	if hallID == lobby.HallFriend {
		return ErrInvitationRequired
	}
	if userPoints < 0 || !lobby.CanEnter(userPoints, hallID) {
		return ErrAdmissionDenied
	}
	return nil
}

func (m *Manager) insertRoomIDLocked(hallID, roomID string) {
	ids := m.hallRoomIDs[hallID]
	index := sort.SearchStrings(ids, roomID)
	ids = append(ids, "")
	copy(ids[index+1:], ids[index:])
	ids[index] = roomID
	m.hallRoomIDs[hallID] = ids
}

func (m *Manager) removeRoomIDLocked(hallID, roomID string) {
	ids := m.hallRoomIDs[hallID]
	index := sort.SearchStrings(ids, roomID)
	if index == len(ids) || ids[index] != roomID {
		return
	}
	copy(ids[index:], ids[index+1:])
	m.hallRoomIDs[hallID] = ids[:len(ids)-1]
}

func (m *Manager) JoinRoom(roomID, userID string, points int64, password string, expectedVersion uint64) (Details, error) {
	state, err := m.lockRoom(roomID)
	if err != nil {
		return Details{}, err
	}
	defer state.mu.Unlock()
	if err := state.checkVersion(expectedVersion); err != nil {
		return Details{}, err
	}
	friendRoom := state.summary.HallID == lobby.HallFriend
	if friendRoom && userID != state.ownerID {
		return Details{}, ErrInvitationRequired
	}
	if friendRoom {
		if userID == "" || points < 0 {
			return Details{}, ErrInvalidInput
		}
	} else {
		if err := state.checkAdmission(userID, points); err != nil {
			return Details{}, err
		}
	}
	if state.summary.Status == StatusClosed {
		return Details{}, ErrRoomClosed
	}
	if _, exists := state.members[userID]; exists {
		return Details{}, ErrAlreadyMember
	}
	if state.summary.HasPassword && !verifyPassword(password, state.passwordSalt[:], state.passwordHash) {
		return Details{}, ErrInvalidPassword
	}
	seat := firstOpenSeat(state.members)
	if state.summary.Status == StatusPlaying || seat == 0 {
		if !state.summary.AllowSpectators {
			if state.summary.Status == StatusPlaying {
				return Details{}, ErrRoomStarted
			}
			return Details{}, ErrRoomFull
		}
		state.members[userID] = memberState{Member: Member{
			UserID: userID, Role: RoleSpectator, ViewSeat: 1,
		}}
	} else {
		state.members[userID] = memberState{Member: Member{UserID: userID, Role: RolePlayer, Seat: seat}}
		state.summary.OccupiedSeats++
	}
	state.version++
	details := snapshotLocked(state)
	m.notifyRoom(details)
	return details, nil
}

func (m *Manager) JoinSpectator(roomID, userID string, points int64, password string, viewSeat uint32, expectedVersion uint64) (Details, error) {
	state, err := m.lockRoom(roomID)
	if err != nil {
		return Details{}, err
	}
	defer state.mu.Unlock()
	if err := state.checkVersion(expectedVersion); err != nil {
		return Details{}, err
	}
	if state.summary.HallID == lobby.HallFriend {
		return Details{}, ErrInvitationRequired
	}
	if err := state.checkHallAdmission(userID, points); err != nil {
		return Details{}, err
	}
	if state.summary.Status == StatusClosed {
		return Details{}, ErrRoomClosed
	}
	if !state.summary.AllowSpectators {
		return Details{}, ErrSpectatorsDisabled
	}
	if viewSeat < 1 || viewSeat > 4 || userID == "" {
		return Details{}, ErrInvalidInput
	}
	if _, exists := state.members[userID]; exists {
		return Details{}, ErrAlreadyMember
	}
	if state.summary.HasPassword && !verifyPassword(password, state.passwordSalt[:], state.passwordHash) {
		return Details{}, ErrInvalidPassword
	}
	state.members[userID] = memberState{Member: Member{
		UserID: userID, Role: RoleSpectator, ViewSeat: viewSeat,
	}}
	state.version++
	details := snapshotLocked(state)
	m.notifyRoom(details)
	return details, nil
}

func (m *Manager) InviteFriend(roomID, inviterID, friendID string) error {
	if inviterID == "" || friendID == "" || inviterID == friendID {
		return ErrInvalidInput
	}
	state, err := m.lockRoom(roomID)
	if err != nil {
		return err
	}
	defer state.mu.Unlock()
	if err := validateFriendInvitation(state, inviterID, friendID); err != nil {
		return err
	}
	state.invitees[friendID] = struct{}{}
	delete(state.joinedInvites, friendID)
	return nil
}

func (m *Manager) ReserveFriendInvitation(roomID, inviterID, friendID string) (string, error) {
	if inviterID == "" || friendID == "" || inviterID == friendID {
		return "", ErrInvalidInput
	}
	state, err := m.lockRoom(roomID)
	if err != nil {
		return "", err
	}
	defer state.mu.Unlock()
	if err := validateFriendInvitation(state, inviterID, friendID); err != nil {
		return "", err
	}
	reservationID, err := newRoomID()
	if err != nil {
		return "", err
	}
	state.pendingInvites[reservationID] = friendID
	return reservationID, nil
}

func (m *Manager) CommitFriendInvitation(roomID, reservationID string) {
	state, err := m.lockRoom(roomID)
	if err != nil {
		return
	}
	defer state.mu.Unlock()
	friendID, exists := state.pendingInvites[reservationID]
	if !exists {
		return
	}
	delete(state.pendingInvites, reservationID)
	if state.summary.Status != StatusWaiting {
		return
	}
	if _, exists := state.members[friendID]; exists {
		return
	}
	state.invitees[friendID] = struct{}{}
	delete(state.joinedInvites, friendID)
}

func (m *Manager) CancelFriendInvitation(roomID, reservationID string) {
	state, err := m.lockRoom(roomID)
	if err != nil {
		return
	}
	defer state.mu.Unlock()
	delete(state.pendingInvites, reservationID)
}

func (m *Manager) RevokeFriendInvitation(roomID, friendID string) {
	state, err := m.lockRoom(roomID)
	if err != nil {
		return
	}
	defer state.mu.Unlock()
	delete(state.invitees, friendID)
}

func validateFriendInvitation(state *roomState, inviterID, friendID string) error {
	if state.summary.HallID != lobby.HallFriend || state.summary.Status != StatusWaiting {
		return ErrInvitationRequired
	}
	if _, exists := state.members[friendID]; exists {
		return ErrAlreadyMember
	}
	if inviterID != state.ownerID {
		member, exists := state.members[inviterID]
		if !exists || member.Role != RolePlayer || member.Seat == 0 {
			return ErrOwnerRequired
		}
	}
	return nil
}

func (m *Manager) JoinInvitedFriendRoom(roomID, userID, password, requestID string, expectedVersion uint64) (Details, error) {
	state, err := m.lockRoom(roomID)
	if err != nil {
		return Details{}, err
	}
	defer state.mu.Unlock()
	if expectedVersion != 0 {
		if err := state.checkVersion(expectedVersion); err != nil {
			return Details{}, err
		}
	}
	if requestID == "" || len(requestID) > 128 {
		return Details{}, ErrInvalidInput
	}
	if requesterID, exists := state.inviteRequests[requestID]; exists {
		if requesterID != userID {
			return Details{}, ErrInvitationRequestConflict
		}
		if _, isMember := state.members[userID]; !isMember {
			return Details{}, ErrNotMember
		}
		return snapshotLocked(state), nil
	}
	if state.summary.HallID != lobby.HallFriend {
		return Details{}, ErrInvitationRequired
	}
	if _, alreadyJoined := state.joinedInvites[userID]; alreadyJoined {
		state.inviteRequests[requestID] = userID
		return snapshotLocked(state), nil
	}
	if _, invited := state.invitees[userID]; !invited {
		return Details{}, ErrInvitationRequired
	}
	if state.summary.Status != StatusWaiting {
		return Details{}, ErrRoomStarted
	}
	if userID == "" {
		return Details{}, ErrInvalidInput
	}
	if _, exists := state.members[userID]; exists {
		return Details{}, ErrAlreadyMember
	}
	if state.summary.HasPassword && !verifyPassword(password, state.passwordSalt[:], state.passwordHash) {
		return Details{}, ErrInvalidPassword
	}
	seat := firstOpenSeat(state.members)
	if seat == 0 {
		return Details{}, ErrRoomFull
	}
	state.members[userID] = memberState{Member: Member{UserID: userID, Role: RolePlayer, Seat: seat}}
	delete(state.invitees, userID)
	state.joinedInvites[userID] = struct{}{}
	state.inviteRequests[requestID] = userID
	state.summary.OccupiedSeats++
	state.version++
	details := snapshotLocked(state)
	m.notifyRoom(details)
	return details, nil
}

func (m *Manager) SitDown(roomID, userID string, seat uint32, points int64, expectedVersion uint64) (Details, error) {
	state, err := m.lockRoom(roomID)
	if err != nil {
		return Details{}, err
	}
	defer state.mu.Unlock()
	if err := state.checkVersion(expectedVersion); err != nil {
		return Details{}, err
	}
	member, exists := state.members[userID]
	if !exists {
		return Details{}, ErrNotMember
	}
	if state.summary.HallID != lobby.HallFriend {
		if err := state.checkAdmission(userID, points); err != nil {
			return Details{}, err
		}
	}
	if state.summary.Status != StatusWaiting {
		return Details{}, ErrRoomStarted
	}
	if seat < 1 || seat > 4 {
		return Details{}, ErrInvalidInput
	}
	if member.Role == RolePlayer && member.Seat != 0 {
		return Details{}, ErrAlreadyMember
	}
	if seatTaken(state.members, seat) {
		return Details{}, ErrSeatUnavailable
	}
	member.Role, member.Seat, member.ViewSeat = RolePlayer, seat, 0
	state.members[userID] = member
	state.summary.OccupiedSeats++
	state.version++
	details := snapshotLocked(state)
	m.notifyRoom(details)
	return details, nil
}

func (m *Manager) StandUp(roomID, userID string, expectedVersion uint64) (Details, error) {
	state, err := m.lockRoom(roomID)
	if err != nil {
		return Details{}, err
	}
	defer state.mu.Unlock()
	if err := state.checkVersion(expectedVersion); err != nil {
		return Details{}, err
	}
	if state.summary.Status != StatusWaiting {
		return Details{}, ErrRoomStarted
	}
	member, exists := state.members[userID]
	if !exists || member.Role != RolePlayer || member.Seat == 0 {
		return Details{}, ErrNotMember
	}
	member.Seat = 0
	state.members[userID] = member
	state.summary.OccupiedSeats--
	state.version++
	details := snapshotLocked(state)
	m.notifyRoom(details)
	return details, nil
}

func (m *Manager) ChangeSeat(roomID, userID string, seat uint32, expectedVersion uint64) (Details, error) {
	state, err := m.lockRoom(roomID)
	if err != nil {
		return Details{}, err
	}
	defer state.mu.Unlock()
	if err := state.checkVersion(expectedVersion); err != nil {
		return Details{}, err
	}
	if state.summary.Status != StatusWaiting {
		return Details{}, ErrRoomStarted
	}
	if seat < 1 || seat > 4 {
		return Details{}, ErrInvalidInput
	}
	member, exists := state.members[userID]
	if !exists {
		return Details{}, ErrNotMember
	}
	if member.Role != RolePlayer || member.Seat == 0 {
		return Details{}, ErrNotMember
	}
	if seatTakenByOther(state.members, seat, userID) {
		return Details{}, ErrSeatUnavailable
	}
	member.Seat = seat
	state.members[userID] = member
	state.version++
	details := snapshotLocked(state)
	m.notifyRoom(details)
	return details, nil
}

func (m *Manager) LeaveRoom(roomID, userID string, expectedVersion uint64) (Details, error) {
	state, err := m.lockRoom(roomID)
	if err != nil {
		return Details{}, err
	}
	defer state.mu.Unlock()
	if err := state.checkVersion(expectedVersion); err != nil {
		return Details{}, err
	}
	member, exists := state.members[userID]
	if !exists {
		return Details{}, ErrNotMember
	}
	if member.Role == RolePlayer && member.Seat != 0 && state.summary.Status == StatusPlaying {
		return Details{}, ErrRoomStarted
	}
	delete(state.members, userID)
	delete(state.joinedInvites, userID)
	if member.Role == RolePlayer && member.Seat != 0 {
		state.summary.OccupiedSeats--
	}
	if userID == state.ownerID && state.summary.Status == StatusWaiting {
		state.summary.Status = StatusClosed
	}
	state.version++
	m.evictIfEmpty(state)
	details := snapshotLocked(state)
	m.notifyRoom(details)
	return details, nil
}

func (m *Manager) SetSpectatorView(roomID, userID string, viewSeat uint32, expectedVersion uint64) (Details, error) {
	state, err := m.lockRoom(roomID)
	if err != nil {
		return Details{}, err
	}
	defer state.mu.Unlock()
	if err := state.checkVersion(expectedVersion); err != nil {
		return Details{}, err
	}
	if viewSeat < 1 || viewSeat > 4 {
		return Details{}, ErrInvalidInput
	}
	member, exists := state.members[userID]
	if !exists || member.Role != RoleSpectator {
		return Details{}, ErrNotMember
	}
	member.ViewSeat = viewSeat
	state.members[userID] = member
	state.version++
	details := snapshotLocked(state)
	m.notifyRoom(details)
	return details, nil
}

func (m *Manager) SetHandVisibility(roomID, userID string, visible bool, expectedVersion uint64) (Details, error) {
	state, err := m.lockRoom(roomID)
	if err != nil {
		return Details{}, err
	}
	defer state.mu.Unlock()
	if err := state.checkVersion(expectedVersion); err != nil {
		return Details{}, err
	}
	member, exists := state.members[userID]
	if !exists || member.Role != RolePlayer {
		return Details{}, ErrNotMember
	}
	member.ShowHand = visible
	state.members[userID] = member
	state.version++
	details := snapshotLocked(state)
	m.notifyRoom(details)
	return details, nil
}

func (m *Manager) Start(roomID, userID string, expectedVersion uint64) (Details, error) {
	state, err := m.lockRoom(roomID)
	if err != nil {
		return Details{}, err
	}
	defer state.mu.Unlock()
	if err := state.checkVersion(expectedVersion); err != nil {
		return Details{}, err
	}
	if userID != state.ownerID {
		return Details{}, ErrOwnerRequired
	}
	if state.summary.Status != StatusWaiting {
		return Details{}, ErrRoomStarted
	}
	if state.summary.OccupiedSeats != 4 {
		return Details{}, ErrRoomNotReady
	}
	state.summary.Status = StatusPlaying
	state.version++
	details := snapshotLocked(state)
	m.notifyRoom(details)
	return details, nil
}

func (m *Manager) Close(roomID, userID string, expectedVersion uint64) (Details, error) {
	state, err := m.lockRoom(roomID)
	if err != nil {
		return Details{}, err
	}
	defer state.mu.Unlock()
	if err := state.checkVersion(expectedVersion); err != nil {
		return Details{}, err
	}
	if userID != state.ownerID {
		return Details{}, ErrOwnerRequired
	}
	if state.summary.Status == StatusPlaying {
		return Details{}, ErrRoomStarted
	}
	if state.summary.Status == StatusClosed {
		return Details{}, ErrRoomClosed
	}
	state.summary.Status = StatusClosed
	state.version++
	m.mu.Lock()
	m.removeRoomIDLocked(state.summary.HallID, state.summary.ID)
	m.mu.Unlock()
	m.evictIfEmpty(state)
	details := snapshotLocked(state)
	m.notifyRoom(details)
	return details, nil
}

func (m *Manager) GetRoom(roomID, userID string) (Details, error) {
	state, err := m.lockRoom(roomID)
	if err != nil {
		return Details{}, err
	}
	defer state.mu.Unlock()
	if _, exists := state.members[userID]; !exists {
		return Details{}, ErrNotMember
	}
	return snapshotLocked(state), nil
}

func (m *Manager) GetSummary(roomID string) (Summary, error) {
	state, err := m.lockRoom(roomID)
	if err != nil {
		return Summary{}, err
	}
	defer state.mu.Unlock()
	summary := state.summary
	summary.Version = state.version
	return summary, nil
}

func (m *Manager) MatchesRoomPassword(roomID, password string) bool {
	state, err := m.lockRoom(roomID)
	if err != nil {
		return false
	}
	defer state.mu.Unlock()
	if !state.summary.HasPassword {
		return password == ""
	}
	return verifyPassword(password, state.passwordSalt[:], state.passwordHash)
}

func (m *Manager) RoomMemberIDs(_ context.Context, roomID, userID string) ([]string, error) {
	details, err := m.GetRoom(roomID, userID)
	if err != nil {
		return nil, err
	}
	memberIDs := make([]string, 0, len(details.Members))
	for _, member := range details.Members {
		memberIDs = append(memberIDs, member.UserID)
	}
	return memberIDs, nil
}

func (m *Manager) CanInvite(roomID, userID string) bool {
	state, err := m.lockRoom(roomID)
	if err != nil {
		return false
	}
	defer state.mu.Unlock()
	if state.summary.Status != StatusWaiting && state.summary.Status != StatusPlaying {
		return false
	}
	if userID == state.ownerID {
		return true
	}
	member, exists := state.members[userID]
	return exists && member.Role == RolePlayer && member.Seat != 0
}

func (m *Manager) IsFriendRoom(roomID string) bool {
	state, err := m.lockRoom(roomID)
	if err != nil {
		return false
	}
	defer state.mu.Unlock()
	return state.summary.HallID == lobby.HallFriend
}

func (s *roomState) checkVersion(expected uint64) error {
	if expected != s.version {
		return ErrVersionConflict
	}
	return nil
}

func (s *roomState) checkHallAdmission(userID string, points int64) error {
	if userID == "" || points < 0 {
		return ErrInvalidInput
	}
	if !lobby.CanEnter(points, s.summary.HallID) {
		return ErrAdmissionDenied
	}
	return nil
}

func (s *roomState) checkAdmission(userID string, points int64) error {
	if err := s.checkHallAdmission(userID, points); err != nil {
		return err
	}
	if points < s.minimumPoints {
		return ErrAdmissionDenied
	}
	return nil
}

func (m *Manager) findRoom(roomID string) (*roomState, error) {
	m.mu.RLock()
	state := m.rooms[roomID]
	m.mu.RUnlock()
	if state == nil {
		return nil, ErrRoomNotFound
	}
	return state, nil
}

func (m *Manager) lockRoom(roomID string) (*roomState, error) {
	state, err := m.findRoom(roomID)
	if err != nil {
		return nil, err
	}
	state.mu.Lock()
	m.mu.RLock()
	current := m.rooms[roomID] == state
	m.mu.RUnlock()
	if !current {
		state.mu.Unlock()
		return nil, ErrRoomNotFound
	}
	return state, nil
}

func (m *Manager) evictIfEmpty(state *roomState) {
	if state.summary.Status != StatusClosed || len(state.members) != 0 {
		return
	}
	m.mu.Lock()
	if m.rooms[state.summary.ID] == state {
		delete(m.rooms, state.summary.ID)
		m.removeRoomIDLocked(state.summary.HallID, state.summary.ID)
	}
	m.mu.Unlock()
}

func snapshot(state *roomState) Details {
	state.mu.Lock()
	defer state.mu.Unlock()
	return snapshotLocked(state)
}

func snapshotLocked(state *roomState) Details {
	summary := state.summary
	summary.Version = state.version
	result := Details{Room: summary, Version: state.version}
	result.Members = make([]Member, 0, len(state.members))
	for _, member := range state.members {
		result.Members = append(result.Members, member.Member)
	}
	sort.Slice(result.Members, func(i, j int) bool {
		if result.Members[i].Seat != result.Members[j].Seat {
			return result.Members[i].Seat < result.Members[j].Seat
		}
		return result.Members[i].UserID < result.Members[j].UserID
	})
	return result
}

func firstOpenSeat(members map[string]memberState) uint32 {
	for seat := uint32(1); seat <= 4; seat++ {
		if !seatTaken(members, seat) {
			return seat
		}
	}
	return 0
}

func seatTaken(members map[string]memberState, seat uint32) bool {
	return seatTakenByOther(members, seat, "")
}

func seatTakenByOther(members map[string]memberState, seat uint32, userID string) bool {
	for id, member := range members {
		if id != userID && member.Role == RolePlayer && member.Seat == seat {
			return true
		}
	}
	return false
}

func validName(name string) bool {
	name = strings.TrimSpace(name)
	return name != "" && utf8.ValidString(name) && utf8.RuneCountInString(name) <= 64 &&
		!strings.ContainsAny(name, "\x00\r\n")
}

func newRoomID() (string, error) {
	value := make([]byte, 16)
	if _, err := rand.Read(value); err != nil {
		return "", err
	}
	return hex.EncodeToString(value), nil
}

func hashPassword(password string, salt []byte) []byte {
	return argon2.IDKey([]byte(password), salt, 3, 64*1024, 2, 32)
}

func verifyPassword(password string, salt, expected []byte) bool {
	if password == "" {
		return false
	}
	actual := hashPassword(password, salt)
	return subtle.ConstantTimeCompare(actual, expected) == 1
}
