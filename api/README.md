# Versioned API

`proto/huai/v1/api.proto` is the canonical client/server contract. Keep wire
field numbers stable within a version; make incompatible changes in a new
package version (for example, `huai.v2`). The API uses gRPC for commands and
queries. WebSocket events use the shared `GameEvent` envelope; event payloads
are typed Protobuf `Any` values and versioned by their type URL. WebSocket
snapshots are personalized by the server; `visible_hand` must contain only
cards the authenticated connection is authorized to see. Authenticated RPCs
carry credentials in gRPC metadata; user IDs in request bodies are never an
authorization identity.

GameTable room mutations use `request_id` UUIDs and the current `expected_version`.
The server deduplicates an identical retry and rejects request-ID reuse for a
different operation. `RoomMember.show_hand` is a player's opt-in spectator
visibility flag; `view_seat` is only meaningful for spectators, and `team` is
derived from the player's seat.

Game snapshots retain the existing string-card fields for wire compatibility.
Card strings use the stable `suit:rank:copy` identity (`clubs`, `diamonds`,
`hearts`, `spades`, or `joker`; ranks 2 through 14, small joker 15, big joker
16; copy 0 or 1). `bottom_cards` must remain empty for unauthorized viewers
while play is active and may be populated for everyone only after bottom
capture. `available_actions` contains server-authorized action labels and is
not a client-side rules hint.

## Generate bindings

Install `buf` and the pinned Go plugins:

```sh
go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.36.12
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.5.1
```

Then run:

```sh
cd api
buf lint
PATH="$(go env GOPATH)/bin:$PATH" buf generate
```

This generates Go messages and gRPC stubs under `server/gen/huai/v1`. Install
the pinned Dart generator and generate the Flutter bindings from the same
schema:

```sh
dart pub global activate protoc_plugin 25.1.0
cd api
PATH="$HOME/.pub-cache/bin:$PATH" buf generate --template buf.gen.dart.yaml --include-imports
```

This writes Dart messages and gRPC clients under
`client/lib/src/generated/huai/v1`, using the protobuf 6 runtime declared by
the Flutter client. Imported standard types are included in generation.
Generate these bindings before running
`flutter pub get`, analysis, tests, or builds for the Flutter client.

To check that a change remains wire-compatible with the previous schema:

```sh
cd api
buf breaking --against '<previous API schema or module reference>'
```

The Go tests assert the versioned service and selected field-number contracts
and round-trip a representative action message against a cross-language wire
fixture. Both language bindings are generated from this same schema, so
Flutter and Go share the same field numbers and RPC definitions.
