import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ChangeNotifierProvider;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../api/api_client.dart';
import '../auth/auth_controller.dart';

part 'client_providers.g.dart';

@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) =>
    throw StateError('ApiClient must be provided by ClientApp.');

final authControllerProvider = ChangeNotifierProvider<AuthController>(
  (ref) => throw StateError('AuthController must be provided by ClientApp.'),
);
