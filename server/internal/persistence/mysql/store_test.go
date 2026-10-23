package mysql

import (
	"context"
	"database/sql"
	"database/sql/driver"
	"errors"
	"fmt"
	"io"
	"reflect"
	"sort"
	"strings"
	"sync"
	"sync/atomic"
	"testing"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/game/coordinator"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/settlement"
)

type memoryProfile struct {
	points int64
	rank   string
}

type memorySession struct {
	roomID   string
	status   string
	version  uint64
	snapshot []byte
}

type memoryResult struct {
	winner          string
	levelDifference uint8
	endType         string
	multiplier      uint32
	configVersion   uint64
	requestHash     []byte
}

type memoryLedgerEntry struct {
	userID string
	delta  int64
	rank   string
}

type memoryEvent struct {
	handID    any
	eventType string
	payload   []byte
	actorID   any
	requestID any
}

type memoryMigration struct {
	name     string
	checksum []byte
}

type memoryState struct {
	sessions   map[string]memorySession
	profiles   map[string]memoryProfile
	results    map[string]memoryResult
	ledger     map[string][]memoryLedgerEntry
	events     map[string][]memoryEvent
	migrations map[uint64]memoryMigration
	ddlCount   int
}

func (s *memoryState) clone() *memoryState {
	copyState := &memoryState{
		sessions:   make(map[string]memorySession, len(s.sessions)),
		profiles:   make(map[string]memoryProfile, len(s.profiles)),
		results:    make(map[string]memoryResult, len(s.results)),
		ledger:     make(map[string][]memoryLedgerEntry, len(s.ledger)),
		events:     make(map[string][]memoryEvent, len(s.events)),
		migrations: make(map[uint64]memoryMigration, len(s.migrations)),
		ddlCount:   s.ddlCount,
	}
	for key, value := range s.sessions {
		value.snapshot = append([]byte(nil), value.snapshot...)
		copyState.sessions[key] = value
	}
	for key, value := range s.profiles {
		copyState.profiles[key] = value
	}
	for key, value := range s.results {
		value.requestHash = append([]byte(nil), value.requestHash...)
		copyState.results[key] = value
	}
	for key, entries := range s.ledger {
		copyState.ledger[key] = append([]memoryLedgerEntry(nil), entries...)
	}
	for key, entries := range s.events {
		copyState.events[key] = append([]memoryEvent(nil), entries...)
	}
	for key, value := range s.migrations {
		value.checksum = append([]byte(nil), value.checksum...)
		copyState.migrations[key] = value
	}
	return copyState
}

type memoryDB struct {
	mu            sync.Mutex
	state         *memoryState
	failLedgerFor string
	failEvent     bool
}

type memoryDriver struct{}

type memoryConn struct {
	db *memoryDB
	tx *memoryTx
}

type memoryTx struct {
	conn  *memoryConn
	state *memoryState
	done  bool
}

var memoryDBs sync.Map
var memoryDriverID atomic.Uint64

func init() {
	sql.Register("mysql-persistence-test", memoryDriver{})
}

func (memoryDriver) Open(name string) (driver.Conn, error) {
	db, ok := memoryDBs.Load(name)
	if !ok {
		return nil, fmt.Errorf("unknown test database %q", name)
	}
	return &memoryConn{db: db.(*memoryDB)}, nil
}

func (c *memoryConn) Prepare(string) (driver.Stmt, error) {
	return nil, errors.New("prepared statements are not supported")
}

func (c *memoryConn) Close() error { return nil }

func (c *memoryConn) Begin() (driver.Tx, error) {
	return c.BeginTx(context.Background(), driver.TxOptions{})
}

func (c *memoryConn) BeginTx(context.Context, driver.TxOptions) (driver.Tx, error) {
	c.db.mu.Lock()
	defer c.db.mu.Unlock()
	c.tx = &memoryTx{conn: c, state: c.db.state.clone()}
	return c.tx, nil
}

func (c *memoryConn) current() *memoryState {
	if c.tx != nil {
		return c.tx.state
	}
	return c.db.state
}

func (c *memoryConn) ExecContext(_ context.Context, query string, args []driver.NamedValue) (driver.Result, error) {
	query = strings.Join(strings.Fields(query), " ")
	state := c.current()
	switch {
	case strings.HasPrefix(query, "CREATE TABLE IF NOT EXISTS schema_migrations"):
		return memoryResultRows(0), nil
	case strings.HasPrefix(query, "CREATE TABLE IF NOT EXISTS"):
		state.ddlCount++
	case strings.HasPrefix(query, "INSERT INTO schema_migrations"):
		if state.migrations == nil {
			state.migrations = make(map[uint64]memoryMigration)
		}
		state.migrations[uint64(args[0].Value.(int64))] = memoryMigration{
			name: args[1].Value.(string), checksum: append([]byte(nil), args[2].Value.([]byte)...),
		}
	case strings.HasPrefix(query, "INSERT INTO match_results"):
		state.results[args[0].Value.(string)] = memoryResult{
			winner:          args[1].Value.(string),
			levelDifference: uint8(args[2].Value.(int64)),
			endType:         args[3].Value.(string),
			multiplier:      uint32(args[4].Value.(int64)),
			configVersion:   uint64(args[5].Value.(int64)),
			requestHash:     append([]byte(nil), args[6].Value.([]byte)...),
		}
	case strings.HasPrefix(query, "UPDATE player_profiles"):
		state.profiles[args[2].Value.(string)] = memoryProfile{
			points: args[0].Value.(int64),
			rank:   args[1].Value.(string),
		}
	case strings.HasPrefix(query, "INSERT INTO point_ledger"):
		userID := args[1].Value.(string)
		if c.db.failLedgerFor == userID {
			return nil, errors.New("injected ledger failure")
		}
		state.ledger[args[0].Value.(string)] = append(state.ledger[args[0].Value.(string)], memoryLedgerEntry{
			userID: userID,
			delta:  args[2].Value.(int64),
			rank:   args[4].Value.(string),
		})
	case strings.HasPrefix(query, "UPDATE game_sessions SET status = 'SETTLED'"):
		sessionID := args[0].Value.(string)
		session := state.sessions[sessionID]
		if session.status != "ACTIVE" {
			return memoryResultRows(0), nil
		}
		session.status = "SETTLED"
		state.sessions[sessionID] = session
	case strings.HasPrefix(query, "UPDATE game_sessions SET snapshot"):
		sessionID := args[2].Value.(string)
		session, ok := state.sessions[sessionID]
		if !ok || session.status != "ACTIVE" || session.version != uint64(args[3].Value.(int64)) {
			return memoryResultRows(0), nil
		}
		session.snapshot = append([]byte(nil), args[0].Value.([]byte)...)
		session.status = args[1].Value.(string)
		session.version++
		state.sessions[sessionID] = session
	case strings.HasPrefix(query, "INSERT INTO game_events"):
		if c.db.failEvent {
			return nil, errors.New("injected event failure")
		}
		sessionID := args[0].Value.(string)
		state.events[sessionID] = append(state.events[sessionID], memoryEvent{
			handID: args[2].Value, eventType: args[3].Value.(string),
			payload: append([]byte(nil), args[4].Value.([]byte)...),
			actorID: args[5].Value, requestID: args[6].Value,
		})
	default:
		return nil, fmt.Errorf("unexpected exec query %q", query)
	}
	return memoryResultRows(1), nil
}

func (c *memoryConn) QueryContext(_ context.Context, query string, args []driver.NamedValue) (driver.Rows, error) {
	query = strings.Join(strings.Fields(query), " ")
	state := c.current()
	switch {
	case strings.HasPrefix(query, "SELECT version, name, checksum FROM schema_migrations"):
		versions := make([]int, 0, len(state.migrations))
		for version := range state.migrations {
			versions = append(versions, int(version))
		}
		sort.Ints(versions)
		values := make([][]driver.Value, 0, len(versions))
		for _, version := range versions {
			migration := state.migrations[uint64(version)]
			values = append(values, []driver.Value{int64(version), migration.name, migration.checksum})
		}
		return &memoryRows{columns: []string{"version", "name", "checksum"}, values: values}, nil
	case strings.HasPrefix(query, "SELECT status FROM game_sessions"):
		session, ok := state.sessions[args[0].Value.(string)]
		if !ok {
			return nil, errors.New("game session not found")
		}
		return &memoryRows{columns: []string{"status"}, values: [][]driver.Value{{session.status}}}, nil
	case strings.HasPrefix(query, "SELECT winner, level_difference"):
		result, ok := state.results[args[0].Value.(string)]
		if !ok {
			return nil, errors.New("match result not found")
		}
		return &memoryRows{
			columns: []string{"winner", "level_difference", "end_type", "hall_multiplier_bp", "config_version", "request_hash"},
			values: [][]driver.Value{{result.winner, int64(result.levelDifference), result.endType,
				int64(result.multiplier), int64(result.configVersion), result.requestHash}},
		}, nil
	case strings.HasPrefix(query, "SELECT user_id, delta, rank_name FROM point_ledger"):
		entries := append([]memoryLedgerEntry(nil), state.ledger[args[0].Value.(string)]...)
		sortLedger(entries)
		values := make([][]driver.Value, 0, len(entries))
		for _, entry := range entries {
			values = append(values, []driver.Value{entry.userID, entry.delta, entry.rank})
		}
		return &memoryRows{columns: []string{"user_id", "delta", "rank_name"}, values: values}, nil
	case strings.HasPrefix(query, "SELECT points FROM player_profiles"):
		profile, ok := state.profiles[args[0].Value.(string)]
		if !ok {
			return nil, errors.New("player profile not found")
		}
		return &memoryRows{columns: []string{"points"}, values: [][]driver.Value{{profile.points}}}, nil
	case strings.HasPrefix(query, "SELECT id, room_id, status, state_version"):
		session, ok := state.sessions[args[0].Value.(string)]
		if !ok {
			return nil, errors.New("game session not found")
		}
		return &memoryRows{
			columns: []string{"id", "room_id", "status", "state_version", "snapshot"},
			values: [][]driver.Value{{args[0].Value, session.roomID, session.status,
				int64(session.version), session.snapshot}},
		}, nil
	case strings.HasPrefix(query, "SELECT hand_id, event_type"):
		return &memoryRows{columns: []string{"hand_id", "event_type", "payload", "actor_id", "request_id"}}, nil
	default:
		return nil, fmt.Errorf("unexpected query %q", query)
	}
}

func (tx *memoryTx) Commit() error {
	if tx.done {
		return errors.New("transaction already finished")
	}
	tx.conn.db.mu.Lock()
	tx.conn.db.state = tx.state
	tx.conn.db.mu.Unlock()
	tx.done = true
	tx.conn.tx = nil
	return nil
}

func (tx *memoryTx) Rollback() error {
	if tx.done {
		return nil
	}
	tx.done = true
	tx.conn.tx = nil
	return nil
}

type memoryRows struct {
	columns []string
	values  [][]driver.Value
	index   int
}

func (r memoryRows) Columns() []string { return r.columns }

func (r memoryRows) Close() error { return nil }

func (r *memoryRows) Next(dest []driver.Value) error {
	if r.index >= len(r.values) {
		return io.EOF
	}
	copy(dest, r.values[r.index])
	r.index++
	return nil
}

type memoryResultRows int64

func (r memoryResultRows) LastInsertId() (int64, error) { return 0, nil }
func (r memoryResultRows) RowsAffected() (int64, error) { return int64(r), nil }

func sortLedger(entries []memoryLedgerEntry) {
	for i := 0; i < len(entries); i++ {
		for j := i + 1; j < len(entries); j++ {
			if entries[j].userID < entries[i].userID {
				entries[i], entries[j] = entries[j], entries[i]
			}
		}
	}
}

func newTestStore(t *testing.T, state *memoryState) (*Store, *memoryDB) {
	t.Helper()
	name := fmt.Sprintf("test-%d", memoryDriverID.Add(1))
	db := &memoryDB{state: state}
	memoryDBs.Store(name, db)
	t.Cleanup(func() { memoryDBs.Delete(name) })
	sqlDB, err := sql.Open("mysql-persistence-test", name)
	if err != nil {
		t.Fatal(err)
	}
	sqlDB.SetMaxOpenConns(1)
	t.Cleanup(func() { sqlDB.Close() })
	store, err := New(sqlDB)
	if err != nil {
		t.Fatal(err)
	}
	return store, db
}

func testMemoryState() *memoryState {
	return &memoryState{
		sessions: map[string]memorySession{
			"game-1": {roomID: "room-1", status: "ACTIVE", snapshot: []byte(`{"turn":0}`)},
		},
		profiles: map[string]memoryProfile{
			"p1": {points: 20, rank: "青铜"},
			"p2": {points: 20, rank: "青铜"},
			"p3": {points: 20, rank: "青铜"},
			"p4": {points: 20, rank: "青铜"},
		},
		results:    map[string]memoryResult{},
		ledger:     map[string][]memoryLedgerEntry{},
		events:     map[string][]memoryEvent{},
		migrations: map[uint64]memoryMigration{},
	}
}

func testSettlement() settlement.MatchResult {
	return settlement.MatchResult{
		GameSessionID: "game-1", Winner: "DEALER", LevelDifference: 2,
		EndType: "NORMAL", HallMultiplierBP: 10000, ConfigVersion: 1,
		Changes: []settlement.PointChange{
			{UserID: "p1", Delta: 100, Rank: "白银"},
			{UserID: "p2", Delta: 100, Rank: "白银"},
			{UserID: "p3", Delta: -100, Rank: "青铜"},
			{UserID: "p4", Delta: -100, Rank: "青铜"},
		},
	}
}

func TestLoadMigrations(t *testing.T) {
	migrations, err := loadMigrations()
	if err != nil {
		t.Fatal(err)
	}
	if len(migrations) != 1 || migrations[0].version != 1 {
		t.Fatalf("unexpected migrations: %#v", migrations)
	}
	for _, required := range []string{
		"UNIQUE KEY uq_point_ledger_game_user",
		"FOREIGN KEY (user_id) REFERENCES users(id)",
		"CHECK (points >= 0)",
		"state_version BIGINT UNSIGNED",
		"request_hash BINARY(32)",
	} {
		if !strings.Contains(migrations[0].sql, required) {
			t.Errorf("migration missing %q", required)
		}
	}
}

func TestApplyMigrationsRecordsVersionsAndIsIdempotent(t *testing.T) {
	db := &memoryDB{state: testMemoryState()}
	name := fmt.Sprintf("migration-%d", memoryDriverID.Add(1))
	memoryDBs.Store(name, db)
	t.Cleanup(func() { memoryDBs.Delete(name) })
	sqlDB, err := sql.Open("mysql-persistence-test", name)
	if err != nil {
		t.Fatal(err)
	}
	sqlDB.SetMaxOpenConns(1)
	t.Cleanup(func() { sqlDB.Close() })

	if err := ApplyMigrations(context.Background(), sqlDB); err != nil {
		t.Fatal(err)
	}
	firstDDLCount := db.state.ddlCount
	if len(db.state.migrations) != 1 || db.state.migrations[1].name != "0001_initial.sql" {
		t.Fatalf("migration version was not recorded: %+v", db.state.migrations)
	}
	if err := ApplyMigrations(context.Background(), sqlDB); err != nil {
		t.Fatal(err)
	}
	if db.state.ddlCount != firstDDLCount {
		t.Fatalf("already-applied migration executed again: before=%d after=%d", firstDDLCount, db.state.ddlCount)
	}
}

func TestApplyMigrationsRejectsUnknownVersionBeforeApplyingDDL(t *testing.T) {
	state := testMemoryState()
	state.migrations[99] = memoryMigration{name: "0099_unknown.sql", checksum: make([]byte, 32)}
	db := &memoryDB{state: state}
	name := fmt.Sprintf("unknown-migration-%d", memoryDriverID.Add(1))
	memoryDBs.Store(name, db)
	t.Cleanup(func() { memoryDBs.Delete(name) })
	sqlDB, err := sql.Open("mysql-persistence-test", name)
	if err != nil {
		t.Fatal(err)
	}
	sqlDB.SetMaxOpenConns(1)
	t.Cleanup(func() { sqlDB.Close() })

	if err := ApplyMigrations(context.Background(), sqlDB); err == nil {
		t.Fatal("expected unknown migration error")
	}
	if db.state.ddlCount != 0 {
		t.Fatalf("migration DDL ran before detecting unknown version: %d", db.state.ddlCount)
	}
}

func TestSettleCommitsOnceAndPreservesPointConstraints(t *testing.T) {
	store, db := newTestStore(t, testMemoryState())
	request := testSettlement()

	first, err := store.Settle(context.Background(), request)
	if err != nil {
		t.Fatal(err)
	}
	if got := first.Changes; len(got) != 4 || got[0].Delta != 0 || got[1].Delta != 40 ||
		got[2].Delta != -20 || got[3].Delta != -20 {
		t.Fatalf("unexpected clamped settlement changes: %+v", got)
	}
	var total int64
	for _, change := range first.Changes {
		total += change.Delta
	}
	if total != 0 {
		t.Fatalf("settlement does not balance: %d", total)
	}

	second, err := store.Settle(context.Background(), request)
	if err != nil {
		t.Fatal(err)
	}
	if !reflect.DeepEqual(first, second) {
		t.Fatalf("retry returned different result: first=%+v second=%+v", first, second)
	}
	if got := len(db.state.ledger["game-1"]); got != 4 {
		t.Fatalf("retry duplicated ledger rows: got %d", got)
	}
	if db.state.profiles["p3"].points != 0 || db.state.profiles["p4"].points != 0 {
		t.Fatalf("negative points were not capped: %+v", db.state.profiles)
	}

	request.Changes[0].Delta++
	request.Changes[2].Delta--
	if _, err := store.Settle(context.Background(), request); !errors.Is(err, ErrSettlementConflict) {
		t.Fatalf("expected idempotency conflict, got %v", err)
	}
}

func TestSettleRollsBackOnLedgerFailure(t *testing.T) {
	store, db := newTestStore(t, testMemoryState())
	db.failLedgerFor = "p4"

	if _, err := store.Settle(context.Background(), testSettlement()); err == nil {
		t.Fatal("expected injected ledger failure")
	}
	if db.state.sessions["game-1"].status != "ACTIVE" {
		t.Fatal("failed settlement changed game status")
	}
	if len(db.state.results) != 0 || len(db.state.ledger["game-1"]) != 0 {
		t.Fatal("failed settlement left result or ledger rows")
	}
	for _, profile := range db.state.profiles {
		if profile.points != 20 {
			t.Fatalf("failed settlement changed profile points: %+v", db.state.profiles)
		}
	}
}

func TestCommitGameUpdateAndRestoreSnapshot(t *testing.T) {
	store, db := newTestStore(t, testMemoryState())
	state := coordinator.GameState{
		SessionID: "game-1", RoomID: "room-1", Status: "ACTIVE", Snapshot: []byte(`{"turn":1}`),
	}
	event := coordinator.GameEvent{
		SessionID: "game-1", Type: "PLAY", Payload: []byte(`{"card":"A"}`), RequestID: "request-1",
	}
	if err := store.CommitGameUpdate(context.Background(), 0, state, event); err != nil {
		t.Fatal(err)
	}
	restored, err := store.LoadRecoveryState(context.Background(), "game-1")
	if err != nil {
		t.Fatal(err)
	}
	if restored.Version != 1 || string(restored.Snapshot) != `{"turn":1}` {
		t.Fatalf("unexpected recovered state: %+v", restored.GameState)
	}
	if len(db.state.events["game-1"]) != 1 {
		t.Fatalf("game event was not persisted atomically: %+v", db.state.events)
	}

	if err := store.CommitGameUpdate(context.Background(), 0, state, event); !errors.Is(err, ErrVersionConflict) {
		t.Fatalf("expected stale version error, got %v", err)
	}
	if len(db.state.events["game-1"]) != 1 {
		t.Fatal("stale update appended an event")
	}
}

func TestCommitGameUpdateRollsBackWhenEventInsertFails(t *testing.T) {
	store, db := newTestStore(t, testMemoryState())
	db.failEvent = true
	err := store.CommitGameUpdate(context.Background(), 0, coordinator.GameState{
		SessionID: "game-1", RoomID: "room-1", Status: "ACTIVE", Snapshot: []byte(`{"turn":1}`),
	}, coordinator.GameEvent{
		SessionID: "game-1", Type: "PLAY", Payload: []byte(`{}`),
	})
	if err == nil {
		t.Fatal("expected injected event failure")
	}
	if db.state.sessions["game-1"].version != 0 || string(db.state.sessions["game-1"].snapshot) != `{"turn":0}` {
		t.Fatalf("snapshot update was not rolled back: %+v", db.state.sessions["game-1"])
	}
}

func TestNewRequiresDatabase(t *testing.T) {
	if _, err := New(nil); err == nil {
		t.Fatal("expected nil database error")
	}
	if err := ApplyMigrations(context.Background(), nil); err == nil {
		t.Fatal("expected nil database migration error")
	}
}
