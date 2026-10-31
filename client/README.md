# Flutter client

The shared Flutter application targets iOS, Windows, and Web. Install the
Flutter 3.47.8 SDK and configure the local environment as described in
`../.agent/instructions.md`.

Generate the Dart API bindings by following the instructions in
`../api/README.md` (protoc_plugin 25.1.0 with protobuf 6), then run
`flutter pub get --enforce-lockfile` and
`dart run build_runner build` for Riverpod
providers.

Commit `pubspec.lock` when updating dependencies. Riverpod's runtime,
annotations, and generator must be upgraded together; build_runner is capped
below 2.17 because the current generator requires build 4. Validate changes
with `flutter analyze` and `flutter test` after regenerating providers.
The application disables Riverpod 3's automatic provider retries to preserve
the explicit error/retry UI, and `ClientApp` remains the sole owner of its
shared authentication controller's disposal.

Hall and room admission remains server-authoritative. A denied hall listing
shows the selected hall's minimum points instead of a network error. Returning
from a room refreshes its hall's room list (and invitations for friend rooms).
The server closes a waiting room when its owner leaves; the client does not
keep that room as a joinable cached entry. A rejected stale join refreshes the
list and distinguishes missing rooms and version conflicts from network errors.

## Platform runners

The checked-in `windows/`, `web/`, and `ios/` projects are generated with
Flutter 3.47.8. Do not regenerate the sample application over `lib/main.dart`.
Platform icons are resized from the existing `assets/app_icon.png`.

- Windows: enable Windows Developer Mode for plugin symlinks, and install
  Visual Studio with Desktop development with C++. Then run
  `flutter build windows --release` or `flutter run -d windows`.
- Web: run `flutter build web --no-web-resources-cdn` to bundle the renderer
  instead of fetching it from a CDN, then serve `build/web/` over HTTP.
  Secure storage requires HTTPS in production (localhost is allowed for
  development). Use a gRPC-Web-compatible API endpoint.
- iOS: build with Xcode on macOS using `flutter build ios --no-codesign`.
  Configure your signing team and confirm the application bundle identifier
  before device distribution. All configurations include the Keychain
  entitlement required by secure storage. Windows cannot validate an iOS
  binary or signing.

Use `flutter doctor -v` to distinguish missing host prerequisites from
application compilation errors. Browser UI smoke tests do not replace native
platform builds or backend integration tests.

The login layout follows `../ui-design/Login/Login.png`: a centered
420px maximum-width panel, 40px desktop inner padding, 52px input/button
heights, 16px between inputs, and 24px between form sections. These values
are derived from the shared design tokens and verified by layout tests.
Compact viewports reduce panel padding and allow scrolling. The existing
registration entry remains available; loading and error messages reflect
actual authentication state rather than the screenshot's mock state.
The lockout hint does not claim a fixed failure threshold, which is a
server-controlled parameter.

The create-room dialog follows `../ui-design/CreateRoomDialog/CreateRoomDialog.png`:
a responsive 520px maximum-width panel, separated header/footer, external field
labels, private-room and spectator switches, a conditional password field, and
equal-width action buttons. Field groups use 24px token spacing; compact screens
use 16px outer/inner padding and the form scrolls above the actions when space
is limited. Point-limit hints use the selected server hall and player statistics,
not the screenshot's sample values; final admission remains server-authoritative.
Friend rooms retain their invitation-only creation flow without public-room
password, spectator, or points controls.

Inter (the design's Latin typeface) and Noto Sans SC (Chinese fallback) are
bundled under `assets/fonts/` so that Web text does not depend on access to
Google Fonts at runtime. Both use the SIL Open Font License; the original
licenses are included alongside the font files and in the asset bundle.
Source: [google/fonts](https://github.com/google/fonts), revision
`6157dfaa640ca5738b4d1a7070fe389c3036d7fc`, directories `ofl/inter` and
`ofl/notosanssc`.

The API endpoint defaults to `https://localhost:8443`. Set `API_ENDPOINT` to
the TLS-protected gRPC endpoint when building or running against a deployment.
If the WebSocket `/events` endpoint is not served from the same host and port,
set `WEBSOCKET_ENDPOINT` to its full secure URL, including `/events`.

For example, build the Windows and Web clients against your deployment with:

```sh
flutter build windows --release --dart-define=API_ENDPOINT=https://api.example.com --dart-define=WEBSOCKET_ENDPOINT=wss://events.example.com/events
flutter build web --no-web-resources-cdn --dart-define=API_ENDPOINT=https://api.example.com --dart-define=WEBSOCKET_ENDPOINT=wss://events.example.com/events
```

For a single TLS gateway that serves both protocols, omit
`WEBSOCKET_ENDPOINT`; the client uses the API host and `/events` path. Native
gRPC clients need a TLS gRPC endpoint, while the Web client requires a
gRPC-Web-compatible API endpoint. Do not configure production endpoints with
plain HTTP or WebSockets. The Windows package workflow also accepts the
repository Actions variables `API_ENDPOINT` and `WEBSOCKET_ENDPOINT`; when
unset, it uses the secure localhost API default.

The shared UI theme is defined in `lib/src/ui/theme/app_theme.dart` from
`ui-design/DarkTokens.json`. Reusable 32px state icons and the AppIcon are
bundled under `assets/`; card faces are rendered from rank/suit data because
the `third-party/playing-cards` source directory currently contains no card
image files.
