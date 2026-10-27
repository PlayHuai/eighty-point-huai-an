import 'package:eighty_point_huai_an/src/generated/huai/v1/api.pbgrpc.dart'
    as api;
import 'package:grpc/grpc.dart';

import 'channel_factory.dart';
import '../auth/auth_session.dart';

abstract interface class ApiClient {
  Future<AuthSession> login({
    required String account,
    required String password,
  });

  Future<AuthSession> register({
    required String account,
    required String password,
    required String nickname,
  });

  Future<AuthSession> refresh(String refreshToken);

  Future<void> logout(String refreshToken);

  Future<void> close();
}

class GrpcApiClient implements ApiClient {
  GrpcApiClient(Uri endpoint) : _channel = createClientChannel(endpoint) {
    _auth = api.AuthServiceClient(_channel);
  }

  final ClientChannel _channel;
  late final api.AuthServiceClient _auth;

  @override
  Future<AuthSession> login({
    required String account,
    required String password,
  }) async {
    final response = await _auth.login(
      api.LoginRequest()
        ..account = account
        ..password = password,
    );
    return _sessionFrom(response);
  }

  @override
  Future<AuthSession> register({
    required String account,
    required String password,
    required String nickname,
  }) async {
    final response = await _auth.register(
      api.RegisterRequest()
        ..account = account
        ..password = password
        ..nickname = nickname,
    );
    return _sessionFrom(response);
  }

  @override
  Future<AuthSession> refresh(String refreshToken) async {
    final response = await _auth.refreshSession(
      api.RefreshSessionRequest()..refreshToken = refreshToken,
    );
    return _sessionFrom(response);
  }

  @override
  Future<void> logout(String refreshToken) async {
    await _auth.logout(api.LogoutRequest()..refreshToken = refreshToken);
  }

  @override
  Future<void> close() => _channel.shutdown();

  AuthSession _sessionFrom(api.AuthResponse response) {
    final tokens = response.tokens;
    final profile = response.profile;
    return AuthSession(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      expiresAt: tokens.accessTokenExpiresAt.toDateTime(),
      userId: profile.userId,
      nickname: profile.nickname,
    );
  }
}
