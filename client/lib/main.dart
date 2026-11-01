import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'src/api/api_client.dart';
import 'src/auth/auth_controller.dart';
import 'src/auth/session_store.dart';
import 'src/logging/app_log.dart';
import 'src/ui/client_app.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await AppLog.initialize();
    FlutterError.onError = (details) {
      AppLog.failure('flutter.unhandled', details.exception, details.stack);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      AppLog.failure('platform.unhandled', error, stack);
      return true;
    };
    AppLifecycleListener(
      onStateChange: (state) =>
          AppLog.info('application.lifecycle ${state.name}'),
    );
    final endpoint = Uri.parse(
      const String.fromEnvironment(
        'API_ENDPOINT',
        defaultValue: 'https://localhost:8443',
      ),
    );
    AppLog.info(
      'application.endpoint scheme=${endpoint.scheme} '
      'host=${endpoint.host} port=${endpoint.port}',
    );
    const websocketEndpointValue = String.fromEnvironment('WEBSOCKET_ENDPOINT');
    final websocketEndpoint = websocketEndpointValue.isEmpty
        ? null
        : Uri.parse(websocketEndpointValue);
    final api = GrpcApiClient(endpoint);
    final auth = AuthController(api: api, store: SecureSessionStore());
    runApp(
      ClientApp(
        auth: auth,
        endpoint: endpoint,
        websocketEndpoint: websocketEndpoint,
      ),
    );
  }, (error, stack) => AppLog.failure('zone.unhandled', error, stack));
}
