import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_session.dart';

abstract interface class SessionStore {
  Future<AuthSession?> read();

  Future<void> write(AuthSession session);

  Future<void> clear();
}

class SecureSessionStore implements SessionStore {
  SecureSessionStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _expiresAtKey = 'access_token_expires_at';
  static const _userIdKey = 'user_id';
  static const _nicknameKey = 'nickname';

  final FlutterSecureStorage _storage;

  @override
  Future<AuthSession?> read() async {
    final values = await Future.wait([
      _storage.read(key: _accessTokenKey),
      _storage.read(key: _refreshTokenKey),
      _storage.read(key: _expiresAtKey),
      _storage.read(key: _userIdKey),
      _storage.read(key: _nicknameKey),
    ]);
    if (values.any((value) => value == null)) return null;
    final expiresAt = DateTime.tryParse(values[2]!);
    if (expiresAt == null) return null;
    return AuthSession(
      accessToken: values[0]!,
      refreshToken: values[1]!,
      expiresAt: expiresAt,
      userId: values[3]!,
      nickname: values[4]!,
    );
  }

  @override
  Future<void> write(AuthSession session) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: session.accessToken),
      _storage.write(key: _refreshTokenKey, value: session.refreshToken),
      _storage.write(
        key: _expiresAtKey,
        value: session.expiresAt.toUtc().toIso8601String(),
      ),
      _storage.write(key: _userIdKey, value: session.userId),
      _storage.write(key: _nicknameKey, value: session.nickname),
    ]);
  }

  @override
  Future<void> clear() => _storage.deleteAll();
}
