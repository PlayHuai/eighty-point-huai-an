import 'dart:async';

import 'package:eighty_point_huai_an/src/api/api_client.dart';
import 'package:eighty_point_huai_an/src/auth/auth_controller.dart';
import 'package:eighty_point_huai_an/src/auth/auth_session.dart';
import 'package:eighty_point_huai_an/src/auth/session_store.dart';
import 'package:eighty_point_huai_an/src/ui/client_app.dart';
import 'package:eighty_point_huai_an/src/ui/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';

void main() {
  testWidgets('login validates required fields and shows server errors', (
    tester,
  ) async {
    final api = _FakeApiClient();
    final auth = AuthController(api: api, store: _FakeSessionStore());
    await tester.pumpWidget(ClientApp(auth: auth));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, '登录'));
    await tester.pump();
    expect(find.text('请输入账号'), findsOneWidget);
    expect(find.text('请输入密码'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'account');
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.widgetWithText(FilledButton, '登录'));
    await tester.pump();
    expect(auth.isLoading, isTrue);
    expect(find.byType(ModalBarrier), findsOneWidget);

    api.loginCompleter.completeError(
      GrpcError.unauthenticated('invalid credentials'),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('invalid credentials'), findsOneWidget);
  });

  testWidgets('successful login opens the authenticated landing screen', (
    tester,
  ) async {
    final api = _FakeApiClient();
    final auth = AuthController(api: api, store: _FakeSessionStore());
    await tester.pumpWidget(ClientApp(auth: auth));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'account');
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.widgetWithText(FilledButton, '登录'));
    await tester.pump();
    api.loginCompleter.complete(_session);
    await tester.pumpAndSettle();

    expect(find.text('你好，Player'), findsOneWidget);
  });

  testWidgets('login password visibility can be toggled', (tester) async {
    final auth = AuthController(
      api: _FakeApiClient(),
      store: _FakeSessionStore(),
    );
    await tester.pumpWidget(MaterialApp(home: LoginScreen(auth: auth)));

    final passwordField = find.byKey(const ValueKey('login-password-field'));
    expect(
      tester.widget<TextField>(
        find.descendant(of: passwordField, matching: find.byType(TextField)),
      ).obscureText,
      isTrue,
    );
    await tester.tap(
      find.descendant(of: passwordField, matching: find.text('显示')),
    );
    await tester.pump();
    expect(
      tester.widget<TextField>(
        find.descendant(of: passwordField, matching: find.byType(TextField)),
      ).obscureText,
      isFalse,
    );

    await tester.tap(
      find.descendant(of: passwordField, matching: find.text('隐藏')),
    );
    await tester.pump();
    expect(
      tester.widget<TextField>(
        find.descendant(of: passwordField, matching: find.byType(TextField)),
      ).obscureText,
      isTrue,
    );

    auth.dispose();
  });

  testWidgets('registration validates required fields and matching passwords', (
    tester,
  ) async {
    final auth = AuthController(
      api: _FakeApiClient(),
      store: _FakeSessionStore(),
    );
    await tester.pumpWidget(ClientApp(auth: auth));
    await tester.pumpAndSettle();
    await tester.tap(find.text('创建账号'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '注册'));
    await tester.pump();

    expect(find.text('账号不能为空'), findsOneWidget);
    expect(
      find.text('密码须为8到128字节且需包含字母和数字'),
      findsOneWidget,
    );
    expect(find.text('请确认密码'), findsOneWidget);
    expect(find.text('昵称不能为空'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('register-account-field')),
      'account',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-password-field')),
      'short',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-confirm-password-field')),
      'different',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-nickname-field')),
      'nickname',
    );
    await tester.tap(find.widgetWithText(FilledButton, '注册'));
    await tester.pump();

    expect(
      find.text('密码须为8到128字节且需包含字母和数字'),
      findsOneWidget,
    );
    expect(find.text('两次输入的密码不一致'), findsOneWidget);
    auth.dispose();
  });

  testWidgets('keeps registration fields mounted while the request is pending', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 500));
    final api = _FakeApiClient();
    final auth = AuthController(api: api, store: _FakeSessionStore());

    await tester.pumpWidget(ClientApp(auth: auth));
    await tester.pumpAndSettle();
    await tester.tap(find.text('创建账号'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('register-account-field')),
      'account',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-password-field')),
      'password123',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-confirm-password-field')),
      'password123',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-nickname-field')),
      'nickname',
    );
    await tester.ensureVisible(find.widgetWithText(FilledButton, '注册'));
    await tester.tap(find.widgetWithText(FilledButton, '注册'));
    await tester.pump();

    expect(find.text('选择头像'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsWidgets);
    expect(auth.isLoading, isTrue);
    expect(
      tester.widget<AbsorbPointer>(
        find.ancestor(
          of: find.byKey(const ValueKey('register-account-field')),
          matching: find.byType(AbsorbPointer),
        ),
      ).absorbing,
      isTrue,
    );
    expect(
      tester.widgetList<TextFormField>(find.byType(TextFormField)).map(
        (field) => field.controller!.text,
      ),
      ['account', 'password123', 'password123', 'nickname'],
    );

    api.registerCompleter.completeError(
      GrpcError.unauthenticated('registration failed'),
    );
    await tester.pumpAndSettle();

    expect(find.text('选择头像'), findsOneWidget);
    expect(
      tester.widgetList<TextFormField>(find.byType(TextFormField)).map(
        (field) => field.controller!.text,
      ),
      ['account', 'password123', 'password123', 'nickname'],
    );
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('registration updates the selected avatar before opening lobby', (
    tester,
  ) async {
    final api = _FakeApiClient();
    final auth = AuthController(api: api, store: _FakeSessionStore());
    await tester.pumpWidget(ClientApp(auth: auth));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('创建账号'));
    await tester.tap(find.text('创建账号'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('register-account-field')),
      'account',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-password-field')),
      'password123',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-confirm-password-field')),
      'password123',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-nickname-field')),
      'Player',
    );
    await tester.tap(find.byKey(const ValueKey('register-avatar-1')));
    await tester.ensureVisible(find.widgetWithText(FilledButton, '注册'));
    await tester.tap(find.widgetWithText(FilledButton, '注册'));
    await tester.pump();

    api.registerCompleter.complete(_session);
    await tester.pump();
    expect(api.updatedNickname, 'Player');
    expect(api.updatedAvatarUrl, 'huai-avatar://host');

    api.profileUpdateCompleter.complete();
    await tester.pumpAndSettle();
    expect(find.text('你好，Player'), findsOneWidget);
  });

  testWidgets('registration form remains scrollable on a short viewport', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 240));
    final auth = AuthController(
      api: _FakeApiClient(),
      store: _FakeSessionStore(),
    );

    await tester.pumpWidget(ClientApp(auth: auth));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('创建账号'));
    await tester.tap(find.text('创建账号'));
    await tester.pumpAndSettle();

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    await tester.ensureVisible(find.widgetWithText(FilledButton, '注册'));
    expect(tester.takeException(), isNull);

    await tester.binding.setSurfaceSize(null);
  });
}

class _FakeApiClient implements ApiClient {
  final loginCompleter = Completer<AuthSession>();
  final registerCompleter = Completer<AuthSession>();
  final profileUpdateCompleter = Completer<void>();
  String? updatedNickname;
  String? updatedAvatarUrl;

  @override
  Future<AuthSession> login({
    required String account,
    required String password,
  }) => loginCompleter.future;

  @override
  Future<AuthSession> register({
    required String account,
    required String password,
    required String nickname,
  }) => registerCompleter.future;

  @override
  Future<void> updateProfile({
    required String accessToken,
    required String nickname,
    required String avatarUrl,
  }) {
    updatedNickname = nickname;
    updatedAvatarUrl = avatarUrl;
    return profileUpdateCompleter.future;
  }

  @override
  Future<AuthSession> refresh(String refreshToken) async =>
      throw UnimplementedError();

  @override
  Future<void> logout(String refreshToken) async {}

  @override
  Future<void> close() async {}
}

class _FakeSessionStore implements SessionStore {
  @override
  Future<AuthSession?> read() async => null;

  @override
  Future<void> write(AuthSession session) async {}

  @override
  Future<void> clear() async {}
}

final _session = AuthSession(
  accessToken: 'access',
  refreshToken: 'refresh',
  expiresAt: DateTime.utc(2030),
  userId: 'user',
  nickname: 'Player',
);
