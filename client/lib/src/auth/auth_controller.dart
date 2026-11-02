import 'package:flutter/foundation.dart';
import 'package:grpc/grpc.dart';

import '../api/api_client.dart';
import '../logging/app_log.dart';
import 'auth_session.dart';
import 'session_store.dart';

class AuthController extends ChangeNotifier {
  AuthController({required ApiClient api, required SessionStore store})
    : _api = api,
      _store = store;

  final ApiClient _api;
  final SessionStore _store;

  ApiClient get api => _api;

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
    AppLog.info('auth.restore.start');
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
      AppLog.info('auth.restore.complete authenticated=${_session != null}');
    } catch (error) {
      AppLog.failure('auth.restore', error);
      _session = null;
      if (error is GrpcError && error.code == StatusCode.unauthenticated) {
        try {
          await _store.clear();
        } catch (error) {
          AppLog.failure('auth.store.clear', error);
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
    String avatarUrl,
  ) async {
    if (_isLoading) return false;
    AppLog.info('auth.register.start');
    _isLoading = true;
    _error = null;
    _canRetryRestore = false;
    notifyListeners();
    try {
      final session = await _api.register(
        account: account,
        password: password,
        nickname: nickname,
      );
      _session = session;
      final warnings = <String>[];
      try {
        await _store.write(session);
      } catch (error) {
        AppLog.failure('auth.store.write', error);
        warnings.add('账号已创建，但登录状态无法保存。');
      }
      try {
        await _api.updateProfile(
          accessToken: session.accessToken,
          nickname: nickname,
          avatarUrl: avatarUrl,
        );
      } catch (error) {
        AppLog.failure('auth.profile.update', error);
        warnings.add('账号已创建，但头像暂未保存。');
      }
      _error = warnings.isEmpty ? null : warnings.join(' ');
      AppLog.info('auth.register.complete warnings=${warnings.length}');
      return true;
    } catch (error) {
      AppLog.failure('auth.register', error);
      _session = null;
      _error = _authenticationMessage(error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _authenticate(
    Future<AuthSession> Function() authenticate,
  ) async {
    AppLog.info('auth.login.start');
    _isLoading = true;
    _error = null;
    _canRetryRestore = false;
    notifyListeners();
    try {
      final session = await authenticate();
      await _store.write(session);
      _session = session;
      AppLog.info('auth.login.complete');
      return true;
    } catch (error) {
      AppLog.failure('auth.login', error);
      _session = null;
      _error = _authenticationMessage(error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _authenticationMessage(Object error) => switch (error) {
    GrpcError(code: StatusCode.alreadyExists) => '账号已存在，请直接登录或更换账号。',
    GrpcError(code: StatusCode.unauthenticated) => '账号或密码不正确，请重新输入。',
    GrpcError(code: StatusCode.resourceExhausted) =>
      '密码错误次数过多，账号已临时锁定，请15分钟后重试。',
    GrpcError(code: StatusCode.invalidArgument) => '账号或密码格式不正确，请检查后重试。',
    GrpcError(code: StatusCode.permissionDenied) => '账号暂不可用，请联系管理员。',
    GrpcError(code: StatusCode.unavailable || StatusCode.deadlineExceeded) =>
      '连接服务失败，请检查网络后重试。',
    _ => '登录或注册失败，请稍后重试。',
  };

  Future<void> logout() async {
    AppLog.info('auth.logout.start');
    final current = _session;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      if (current != null) {
        await _api.logout(current.refreshToken);
      }
    } catch (error) {
      AppLog.failure('auth.logout', error);
      _error = error.toString();
    } finally {
      try {
        await _store.clear();
      } catch (error) {
        AppLog.failure('auth.store.clear', error);
        _error = 'Unable to clear the saved session.';
      }
      _session = null;
      _isLoading = false;
      notifyListeners();
      AppLog.info('auth.logout.complete');
    }
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final session = _session;
    if (session == null) throw StateError('请先登录。');
    await _api.changePassword(
      accessToken: session.accessToken,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    // The server revokes every session, including this one.
    _session = null;
    _error = null;
    try {
      await _store.clear();
    } finally {
      notifyListeners();
    }
    AppLog.info('auth.password.changed');
  }
}
