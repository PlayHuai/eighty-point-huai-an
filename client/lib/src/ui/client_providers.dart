import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show ChangeNotifierProvider;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../api/api_client.dart';
import '../api/realtime_event.dart';
import '../api/realtime_event_client.dart';
import '../auth/auth_controller.dart';

part 'client_providers.g.dart';

@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) =>
    throw StateError('ApiClient must be provided by ClientApp.');

final authControllerProvider = ChangeNotifierProvider<AuthController>(
  (ref) => throw StateError('AuthController must be provided by ClientApp.'),
);

final apiEndpointProvider = Provider<Uri?>((ref) => null);

final realtimeEventsProvider = StreamProvider<RealtimeEvent>((ref) {
  final session = ref.watch(
    authControllerProvider.select((auth) => auth.session),
  );
  final endpoint = ref.watch(apiEndpointProvider);
  if (session == null || endpoint == null) {
    return const Stream<RealtimeEvent>.empty();
  }
  final client = RealtimeEventClient(
    endpoint: endpoint,
    accessToken: session.accessToken,
  );
  ref.onDispose(() => unawaited(client.close()));
  return client.events;
});
