# Server development

The server is a Go modular monolith. Domain packages live under `internal/`;
transport and persistence adapters depend on domain/application contracts, not
the other way around. `game/engine` must remain deterministic and independent
of network and storage code.

## Prerequisites

- Go 1.24 or newer

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
