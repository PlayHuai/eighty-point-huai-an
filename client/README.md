# Flutter client

The shared Flutter application targets iOS, Windows, and Web. Install the
Flutter 3.47.8 SDK and configure the local environment as described in
`../.agent/instructions.md`.

Generate the Dart API bindings by following the instructions in
`../api/README.md`, then run `flutter pub get` and
`dart run build_runner build --delete-conflicting-outputs` for Riverpod
providers.

The API endpoint defaults to `https://localhost:8443`. Override it at build or
run time with `--dart-define=API_ENDPOINT=https://your-api.example`.

The shared UI theme is defined in `lib/src/ui/theme/app_theme.dart` from
`ui-design/DarkTokens.json`. Reusable 32px state icons and the AppIcon are
bundled under `assets/`; card faces are rendered from rank/suit data because
the `third-party/playing-cards` source directory currently contains no card
image files.
