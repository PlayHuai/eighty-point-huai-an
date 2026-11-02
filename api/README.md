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
`RoomMember.points` and `rank` are loaded with the same batched authoritative
profile query as nickname/avatar. Clients display these fields rather than
deriving ranks or balances locally; room/team levels come from GameSnapshot.

`SupportService` requires authentication for both RPCs. `SubmitFeedback` accepts
`FEEDBACK_KIND_BUG` or `FEEDBACK_KIND_SUGGESTION`, a trimmed UTF-8 body of 1–2000
Unicode code points and a UUID `request_id`. Identical retries are idempotent
per user; reusing the ID with different content returns `ALREADY_EXISTS`.
Invalid input returns `INVALID_ARGUMENT`; storage failures return `INTERNAL`.
Feedback creates a new record and does not use a game/room `expected_version`.
`GetServerInfo` returns the packaged Git commit, manually maintained version
and UTF-8 changelist, not the current runtime checkout. See the deployment
guide for the metadata build scripts.

Game snapshots retain the existing string-card fields for wire compatibility.
Card strings use the stable `suit:rank:copy` identity (`clubs`, `diamonds`,
`hearts`, `spades`, or `joker`; ranks 2 through 14, small joker 15, big joker
16; copy 0 or 1). `bottom_cards` must remain empty for unauthorized viewers
while play is active and may be populated for everyone only after bottom
capture. `available_actions` contains server-authorized action labels and is
not a client-side rules hint. `current_counter` identifies the current counter
tier, and `suggested_play` contains a bounded, server-validated play for the
current player when one can be found; clients may use it for autoplay following.

`LobbyService.CreateRoom` accepts the reserved hall ID `practice` for a
private room containing the authenticated player and three server-controlled
robots. This hall is never listed and cannot be joined, invited to, or
spectated. The server starts practice sessions immediately after creation and
automatically advances robot turns using only each robot's current hand and
public game state. Practice room state and game sessions are held in memory
only; they are never sent to MySQL room, match, settlement, or statistics
repositories. The room and its session are discarded when the creator leaves.

`RoomService.StartGame` creates a versioned authoritative session for a ready
four-player room. `GameService` binds actions to the authenticated seated
player, validates the hand ID, request ID, expected state version, and action
against the server rules, and returns personalized snapshots. Reconnect returns
a fresh personalized snapshot plus ordered public action metadata. Use
`ListEventsAfter` pagination for more than 1,000 missed events. The live runtime
and replay remain in memory, so active games cannot resume after a server restart.
Ordinary matches receive a unique durable match ID (separate from the reusable
room/session transport ID); MySQL records their participants and final snapshot,
and atomically settles results, all four ledger entries and statistics.
Zero-balance losses are capped and actual awards conserve the deducted amount.
Equal-level finishes use a minimum scoring difference of one level.
Practice sessions never enter these durable paths.

`GameSnapshot.settlement` contains authoritative per-hand outcome flags and,
on match completion, nominal points and actual durable player changes. `history`
contains only completed public trick cards with hand/trick/seat attribution.
`action_deadline` is a server-owned deadline; clients may display it but must not
decide expiry. The server scheduler advances timed-out turns without any client.
`ConfirmAutoplayAction.accept` enables/cancels server automation for that seat;
`autoplay_seats` reports current settings. Older servers without deadlines retain
the client's previous explicit-autoplay behavior for compatibility.

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
