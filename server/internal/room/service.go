package room

import (
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
	ErrInvalidInput       = errors.New("invalid room input")
	ErrRoomNotFound       = errors.New("room not found")
	ErrNotMember          = errors.New("user is not a room member")
	ErrAlreadyMember      = errors.New("user is already a room member")
	ErrRoomFull           = errors.New("room has no available seats")
	ErrSpectatorsDisabled = errors.New("spectating is disabled")
	ErrInvalidPassword    = errors.New("invalid room password")
	ErrAdmissionDenied    = errors.New("hall or room admission denied")
	ErrSeatUnavailable    = errors.New("seat is unavailable")
	ErrRoomStarted        = errors.New("room is already playing")
	ErrRoomNotReady       = errors.New("room requires four seated players")
	ErrOwnerRequired      = errors.New("room owner permission required")
	ErrVersionConflict    = errors.New("room version conflict")
	ErrRoomClosed         = errors.New("room is closed")
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
	Room    Summary
	Members []Member
	Version uint64
}

type memberState struct {
	Member
}

type roomState struct {
	mu            sync.Mutex
	summary       Summary
	ownerID       string
	minimumPoints int64
	passwordSalt  [16]byte
	passwordHash  []byte
	members       map[string]memberState
	version       uint64
}

type Manager struct {
	mu    sync.RWMutex
	rooms map[string]*roomState
}

func NewManager() *Manager {
	return &Manager{rooms: make(map[string]*roomState)}
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
	if !lobby.CanEnter(ownerPoints, hallID) || settings.MinimumPoints > ownerPoints ||
		(hall.MaximumPoints != 0 && settings.MinimumPoints > hall.MaximumPoints) {
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
		},
		ownerID: ownerID, minimumPoints: settings.MinimumPoints,
		members: make(map[string]memberState),
		version: 1,
	}
	if settings.Password != "" {
		if _, err := rand.Read(state.passwordSalt[:]); err != nil {
			return Details{}, err
		}
		state.passwordHash = hashPassword(settings.Password, state.passwordSalt[:])
	}

	m.mu.Lock()
	m.rooms[id] = state
	m.mu.Unlock()
	return snapshot(state), nil
}

func (m *Manager) ListRooms(hallID string, userPoints int64) ([]Summary, error) {
	if _, err := lobby.FindHall(hallID); err != nil {
		return nil, lobby.ErrUnknownHall
	}
	if userPoints < 0 || !lobby.CanEnter(userPoints, hallID) {
		return nil, ErrAdmissionDenied
	}
	m.mu.RLock()
	rooms := make([]*roomState, 0, len(m.rooms))
	for _, state := range m.rooms {
		rooms = append(rooms, state)
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
	sort.Slice(result, func(i, j int) bool { return result[i].ID < result[j].ID })
	return result, nil
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
	if err := state.checkAdmission(userID, points); err != nil {
		return Details{}, err
	}
	if state.summary.Status != StatusWaiting {
		return Details{}, ErrRoomStarted
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
	state.summary.OccupiedSeats++
	state.version++
	return snapshotLocked(state), nil
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
	return snapshotLocked(state), nil
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
	if err := state.checkAdmission(userID, points); err != nil {
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
	return snapshotLocked(state), nil
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
	return snapshotLocked(state), nil
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
	return snapshotLocked(state), nil
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
	if member.Role == RolePlayer && member.Seat != 0 {
		state.summary.OccupiedSeats--
	}
	if userID == state.ownerID && state.summary.Status == StatusWaiting {
		state.summary.Status = StatusClosed
	}
	state.version++
	m.evictIfEmpty(state)
	return snapshotLocked(state), nil
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
	return snapshotLocked(state), nil
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
	return snapshotLocked(state), nil
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
	return snapshotLocked(state), nil
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
	m.evictIfEmpty(state)
	return snapshotLocked(state), nil
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
