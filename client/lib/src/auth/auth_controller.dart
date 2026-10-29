import 'package:flutter/foundation.dart';
import 'package:grpc/grpc.dart';

import '../api/api_client.dart';
import 'auth_session.dart';
import 'session_store.dart';

class AuthController extends ChangeNotifier {
  AuthController({required ApiClient api, required SessionStore store})
    : _api = api,
      _store = store;

  final ApiClient _api;
  final SessionStore _store;

  AuthSession? _session;
  bool _isLoading = true;
  String? _error;
  bool _canRetryRestore = false;

  AuthSession? get session => _session;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get canRetryRestore => _canRetryRestore;

  void clearError() {
    _error = null;
    _canRetryRestore = false;
    notifyListeners();
  }

  Future<void> close() => _api.close();

  Future<void> restoreSession() async {
    _isLoading = true;
    _error = null;
    _canRetryRestore = false;
    notifyListeners();
    try {
      final saved = await _store.read();
      if (saved != null) {
        _session = await _api.refresh(saved.refreshToken);
        await _store.write(_session!);
      }
    } catch (error) {
      _session = null;
      if (error is GrpcError && error.code == StatusCode.unauthenticated) {
        try {
          await _store.clear();
        } catch (_) {
          _error = 'Unable to clear the saved session.';
        }
      } else {
        _error = error.toString();
        _canRetryRestore = true;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String account, String password) =>
      _authenticate(() => _api.login(account: account, password: password));

  Future<bool> register(
    String account,
    String password,
    String nickname,
  ) => _authenticate(
    () => _api.register(
      account: account,
      password: password,
      nickname: nickname,
    ),
  );

  Future<bool> _authenticate(Future<AuthSession> Function() authenticate) async {
    _isLoading = true;
    _error = null;
    _canRetryRestore = false;
    notifyListeners();
    try {
      final session = await authenticate();
      await _store.write(session);
      _session = session;
      return true;
    } catch (error) {
      _session = null;
      _error = error.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final current = _session;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      if (current != null) {
        await _api.logout(current.refreshToken);
      }
    } catch (error) {
      _error = error.toString();
    } finally {
      try {
        await _store.clear();
      } catch (_) {
        _error = 'Unable to clear the saved session.';
      }
      _session = null;
      _isLoading = false;
      notifyListeners();
    }
  }
}
