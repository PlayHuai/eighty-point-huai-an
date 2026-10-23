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
dart pub global activate protoc_plugin 21.1.2
cd api
PATH="$HOME/.pub-cache/bin:$PATH" buf generate --template buf.gen.dart.yaml
```

This writes Dart messages and gRPC clients under
`client/lib/src/generated/huai/v1`. The Flutter application can import those
generated files when it is introduced by T11.

To check that a change remains wire-compatible with the previous schema:

```sh
cd api
buf breaking --against '<previous API schema or module reference>'
```

The Go tests assert the versioned service and selected field-number contracts
and round-trip a representative action message against a cross-language wire
fixture. Both language bindings are generated from this same schema, so
Flutter and Go share the same field numbers and RPC definitions.
