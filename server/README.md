# Server development

The server is a Go modular monolith. Domain packages live under `internal/`;
transport and persistence adapters depend on domain/application contracts, not
the other way around. `game/engine` must remain deterministic and independent
of network and storage code.

## Prerequisites

- Go 1.25 or newer

## Commands

From this directory:

```sh
go test ./...
go vet ./...
go run ./cmd/server
```

The command currently verifies the executable scaffold only; transports and
application services are introduced by their respective tasks. No database or
external services are required for these checks.

## MySQL persistence

The MySQL adapters implement the auth, player, game-coordinator, and settlement
repository contracts. They use `database/sql`; the application must register a
MySQL driver and provide a configured `*sql.DB`. Apply the embedded, checksummed
migrations with `mysql.ApplyMigrations(ctx, db)` as a separate deployment step
against MySQL 8.x. Applied migrations are immutable; changed checksums and
unknown schema versions are rejected.

Game snapshot updates and their events are committed together with optimistic
version checks. Final settlement locks the game session and player profiles,
then writes the match result, point ledger, updated profiles, and settled status
in one transaction. Unique keys make match and per-player ledger writes
idempotent; retries with a different result are rejected.
