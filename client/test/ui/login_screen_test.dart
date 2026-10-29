import 'dart:async';

import 'package:eighty_point_huai_an/src/api/api_client.dart';
import 'package:eighty_point_huai_an/src/auth/auth_controller.dart';
import 'package:eighty_point_huai_an/src/auth/auth_session.dart';
import 'package:eighty_point_huai_an/src/auth/session_store.dart';
import 'package:eighty_point_huai_an/src/ui/client_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';

void main() {
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
    await tester.enterText(find.byType(TextFormField).at(0), 'account');
    await tester.enterText(find.byType(TextFormField).at(1), 'nickname');
    await tester.enterText(find.byType(TextFormField).at(2), 'password');
    await tester.ensureVisible(find.widgetWithText(FilledButton, '注册'));
    await tester.tap(find.widgetWithText(FilledButton, '注册'));
    await tester.pump();

    expect(find.text('创建账号'), findsWidgets);
    expect(find.byType(ModalBarrier), findsOneWidget);
    expect(
      tester.widget<AbsorbPointer>(find.byType(AbsorbPointer).first).absorbing,
      isTrue,
    );
    expect(
      tester.widgetList<TextFormField>(find.byType(TextFormField)).map(
        (field) => field.controller!.text,
      ),
      ['account', 'nickname', 'password'],
    );

    api.registerCompleter.completeError(
      GrpcError.unauthenticated('registration failed'),
    );
    await tester.pumpAndSettle();

    expect(find.text('创建账号'), findsWidgets);
    expect(
      tester.widgetList<TextFormField>(find.byType(TextFormField)).map(
        (field) => field.controller!.text,
      ),
      ['account', 'nickname', 'password'],
    );
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('login form remains scrollable on a short viewport', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 240));
    final auth = AuthController(
      api: _FakeApiClient(),
      store: _FakeSessionStore(),
    );

    await tester.pumpWidget(ClientApp(auth: auth));
    await tester.pumpAndSettle();
    await tester.tap(find.text('创建账号'));
    await tester.pumpAndSettle();

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    await tester.ensureVisible(find.widgetWithText(FilledButton, '注册'));
    expect(tester.takeException(), isNull);

    await tester.binding.setSurfaceSize(null);
  });
}

class _FakeApiClient implements ApiClient {
  final registerCompleter = Completer<AuthSession>();

  @override
  Future<AuthSession> login({
    required String account,
    required String password,
  }) => Completer<AuthSession>().future;

  @override
  Future<AuthSession> register({
    required String account,
    required String password,
    required String nickname,
  }) => registerCompleter.future;

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
