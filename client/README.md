# Flutter client

The shared Flutter application targets iOS, Windows, and Web. Install the
Flutter 3.47.8 SDK and configure the local environment as described in
`../.agent/instructions.md`.

Generate the Dart API bindings by following the instructions in
`../api/README.md`, then run `flutter pub get`.

The API endpoint defaults to `https://localhost:8443`. Override it at build or
run time with `--dart-define=API_ENDPOINT=https://your-api.example`.
