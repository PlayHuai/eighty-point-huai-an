import 'dart:async';

import 'package:eighty_point_huai_an/src/api/api_client.dart';
import 'package:eighty_point_huai_an/src/auth/auth_controller.dart';
import 'package:eighty_point_huai_an/src/auth/auth_session.dart';
import 'package:eighty_point_huai_an/src/auth/session_store.dart';
import 'package:eighty_point_huai_an/src/generated/huai/v1/api.pb.dart'
    as proto;
import 'package:eighty_point_huai_an/src/ui/client_providers.dart';
import 'package:eighty_point_huai_an/src/ui/lobby_screen.dart';
import 'package:eighty_point_huai_an/src/ui/support_dialogs.dart';
import 'package:eighty_point_huai_an/src/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';

void main() {
  for (final platform in [TargetPlatform.iOS, TargetPlatform.windows]) {
    testWidgets('lobby support buttons open dialogs on $platform', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(
        platform == TargetPlatform.iOS
            ? const Size(390, 844)
            : const Size(1440, 900),
      );
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final api = _FakeApiClient();
      final auth = AuthController(api: api, store: _MemorySessionStore());
      await auth.login('user', 'password');
      addTearDown(auth.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(api),
            authControllerProvider.overrideWith((ref) => auth),
            lobbyHallsProvider.overrideWith((ref) async => []),
            lobbyPlayerStatisticsProvider.overrideWith((ref) async => null),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: LobbyScreen(auth: auth, nickname: '玩家'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('反馈'));
      await tester.pumpAndSettle();
      expect(find.byType(FeedbackDialog), findsOneWidget);
      await tester.enterText(find.byType(TextField), '大厅反馈');
      await tester.tap(find.text('提交'));
      await tester.pumpAndSettle();
      expect(find.byType(FeedbackDialog), findsNothing);
      expect(find.text('反馈已提交，感谢您的反馈。'), findsOneWidget);
      await tester.tap(find.text('关于'));
      await tester.pumpAndSettle();
      expect(find.text('软件版本：1.2.3'), findsOneWidget);
      expect(find.text('Commit ID：abcdef123456'), findsOneWidget);
      expect(find.text('# 更新记录\n- 新增反馈'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }, variant: TargetPlatformVariant({platform}));
  }

  testWidgets('feedback validates, selects suggestion and reuses retry ID', (
    tester,
  ) async {
    final api = _FakeApiClient()..failNextSubmit = true;
    await _openDialog(
      tester,
      FeedbackDialog(client: api, accessToken: 'token'),
    );
    await tester.tap(find.text('提交'));
    await tester.pumpAndSettle();
    expect(api.requests, isEmpty);
    expect(find.text('请输入 1–2000 字的反馈内容。'), findsOneWidget);
    await tester.tap(find.byType(DropdownButtonFormField<proto.FeedbackKind>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('建议').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '  建议内容  ');
    await tester.tap(find.text('提交'));
    await tester.pumpAndSettle();
    expect(find.text('服务暂不可用，请重试。'), findsOneWidget);
    expect(
      api.requests.single.kind,
      proto.FeedbackKind.FEEDBACK_KIND_SUGGESTION,
    );
    expect(api.requests.single.body, '建议内容');
    expect(api.requests.single.requestId, matches(RegExp(r'^[0-9a-f-]{36}$')));
    await tester.tap(find.text('提交'));
    await tester.pumpAndSettle();
    expect(api.requests, hasLength(2));
    expect(api.requests.first.requestId, api.requests.last.requestId);
    expect(find.byType(FeedbackDialog), findsNothing);
  });

  testWidgets('changed feedback gets a new ID and blocks duplicate clicks', (
    tester,
  ) async {
    final api = _FakeApiClient()..failNextSubmit = true;
    await _openDialog(
      tester,
      FeedbackDialog(client: api, accessToken: 'token'),
    );
    await tester.enterText(find.byType(TextField), '第一次');
    await tester.tap(find.text('提交'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '修改后的内容');
    final completion = Completer<void>();
    api.submitCompletion = completion;
    await tester.tap(find.text('提交'));
    await tester.pump();
    expect(api.requests, hasLength(2));
    expect(api.requests.first.requestId, isNot(api.requests.last.requestId));
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    expect(
      tester.widget<IconButton>(find.byType(IconButton).last).onPressed,
      isNull,
    );
    completion.complete();
    await tester.pumpAndSettle();
    expect(find.byType(FeedbackDialog), findsNothing);
  });

  testWidgets('about displays loading, explicit error, then retry', (
    tester,
  ) async {
    final api = _FakeApiClient();
    final info = Completer<proto.ServerInfo>();
    api.infoCompletion = info;
    await _openDialog(
      tester,
      ServerInfoDialog(client: api, accessToken: 'token'),
      settle: false,
    );
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    info.completeError(GrpcError.unavailable('offline'));
    await tester.pumpAndSettle();
    expect(find.text('服务暂不可用，请重试。'), findsOneWidget);
    api.infoCompletion = null;
    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();
    expect(find.text('软件版本：1.2.3'), findsOneWidget);
    expect(api.infoCalls, 2);
    await tester.tap(find.text('关闭'));
    await tester.pumpAndSettle();
    expect(find.byType(ServerInfoDialog), findsNothing);
  });
}

Future<void> _openDialog(
  WidgetTester tester,
  Widget dialog, {
  bool settle = true,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: AppTheme.dark,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () =>
                  showDialog<void>(context: context, builder: (_) => dialog),
              child: const Text('打开'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('打开'));
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }
}

class _FakeApiClient implements ApiClient {
  final requests = <proto.SubmitFeedbackRequest>[];
  bool failNextSubmit = false;
  Completer<void>? submitCompletion;
  Completer<proto.ServerInfo>? infoCompletion;
  int infoCalls = 0;

  @override
  Future<void> submitFeedback({
    required String accessToken,
    required proto.FeedbackKind kind,
    required String body,
    required String requestId,
  }) async {
    requests.add(
      proto.SubmitFeedbackRequest(kind: kind, body: body, requestId: requestId),
    );
    if (failNextSubmit) {
      failNextSubmit = false;
      throw GrpcError.unavailable('offline');
    }
    if (submitCompletion != null) await submitCompletion!.future;
  }

  @override
  Future<proto.ServerInfo> getServerInfo({required String accessToken}) async {
    infoCalls++;
    return infoCompletion?.future ??
        proto.ServerInfo(
          version: '1.2.3',
          commitId: 'abcdef123456',
          changelist: '# 更新记录\n- 新增反馈',
        );
  }

  @override
  Future<AuthSession> login({
    required String account,
    required String password,
  }) async => AuthSession(
    accessToken: 'token',
    refreshToken: 'refresh',
    expiresAt: DateTime.utc(2030),
    userId: 'player',
    nickname: '玩家',
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MemorySessionStore implements SessionStore {
  @override
  Future<void> clear() async {}

  @override
  Future<AuthSession?> read() async => null;

  @override
  Future<void> write(AuthSession session) async {}
}
