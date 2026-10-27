import 'package:flutter/material.dart';

import 'src/api/api_client.dart';
import 'src/auth/auth_controller.dart';
import 'src/auth/session_store.dart';
import 'src/ui/client_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final endpoint = Uri.parse(
    const String.fromEnvironment(
      'API_ENDPOINT',
      defaultValue: 'https://localhost:8443',
    ),
  );
  final api = GrpcApiClient(endpoint);
  final auth = AuthController(api: api, store: SecureSessionStore());
  runApp(ClientApp(auth: auth));
}
