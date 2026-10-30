import 'dart:async';

import 'package:eighty_point_huai_an/src/api/api_client.dart';
import 'package:eighty_point_huai_an/src/api/lobby_models.dart';
import 'package:eighty_point_huai_an/src/api/player_models.dart';
import 'package:eighty_point_huai_an/src/auth/auth_controller.dart';
import 'package:eighty_point_huai_an/src/auth/auth_session.dart';
import 'package:eighty_point_huai_an/src/auth/session_store.dart';
import 'package:eighty_point_huai_an/src/ui/client_app.dart';
import 'package:eighty_point_huai_an/src/ui/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';

void main() {
  testWidgets('login matches desktop design spacing and control sizes', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final auth = AuthController(
      api: _FakeApiClient(),
      store: _FakeSessionStore(),
    );
    await auth.restoreSession();
    await tester.pumpWidget(MaterialApp(home: LoginScreen(auth: auth)));
    await tester.pumpAndSettle();

    final panel = tester.getRect(find.byKey(const ValueKey('login-panel')));
    final account = tester.getRect(
      find.byKey(const ValueKey('login-account-field')),
    );
    final password = tester.getRect(
      find.byKey(const ValueKey('login-password-field')),
    );
    final button = tester.getRect(find.byKey(const ValueKey('login-submit')));
    expect(panel.width, 420);
    expect(panel.center, const Offset(720, 450));
    expect(account.left - panel.left, 40);
    expect(account.width, 340);
    expect(account.height, 52);
    expect(password.height, 52);
    expect(password.top - account.bottom, 16);
    expect(button.height, 52);
    expect(button.top - password.bottom, 24);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    auth.dispose();
  });

  for (final platform in [TargetPlatform.iOS, TargetPlatform.windows]) {
    testWidgets('login stays scrollable on $platform at compact sizes', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 240));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final auth = AuthController(
        api: _FakeApiClient(),
        store: _FakeSessionStore(),
      );
      await auth.restoreSession();
      await tester.pumpWidget(MaterialApp(home: LoginScreen(auth: auth)));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('创建账号'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byKey(const ValueKey('login-panel'))).width,
        lessThanOrEqualTo(320),
      );
      await tester.pumpWidget(const SizedBox.shrink());
      auth.dispose();
    }, variant: TargetPlatformVariant({platform}));
  }

  testWidgets('failed lobby reads wait for explicit retry', (tester) async {
    final api = _FakeApiClient()..failHallListing = true;
    final auth = AuthController(api: api, store: _FakeSessionStore());
    final login = auth.login('account', 'password');
    api.loginCompleter.complete(_session);
    await login;

    await tester.pumpWidget(ClientApp(auth: auth));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));

    expect(api.hallListCount, 1);
    expect(find.text('重试'), findsOneWidget);
    api.failHallListing = false;
    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();
    expect(api.hallListCount, 2);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('ClientApp disposes its shared auth controller only once', (
    tester,
  ) async {
    final api = _FakeApiClient();
    final auth = _TrackingAuthController(api: api, store: _FakeSessionStore());
    final login = auth.login('account', 'password');
    api.loginCompleter.complete(_session);
    await login;

    await tester.pumpWidget(ClientApp(auth: auth));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());

    expect(auth.disposeCount, 1);
    expect(api.closeCount, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('friend chat retries with the same request ID', (tester) async {
    final api = _FakeApiClient()
      ..halls = const [
        LobbyHall(
          id: 'ordinary',
          name: '普通大厅',
          minimumPoints: 0,
          maximumPoints: 9999,
          multiplier: 1,
        ),
      ]
      ..friends = const [
        PlayerFriend(userId: 'friend-1', nickname: '好友甲', avatarUrl: ''),
      ]
      ..failNextChatSend = true;
    final auth = AuthController(api: api, store: _FakeSessionStore());
    final login = auth.login('account', 'password');
    api.loginCompleter.complete(_session);
    await login;

    await tester.pumpWidget(ClientApp(auth: auth));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('好友'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('聊天'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.hintText == '输入消息',
      ),
      '你好',
    );
    await tester.tap(find.byTooltip('发送'));
    await tester.pumpAndSettle();
    final firstRequestId = api.chatRequestIds.single;

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('发送'));
    await tester.pumpAndSettle();
    expect(api.chatRequestIds, [firstRequestId, firstRequestId]);
    expect(api.sentMessages.single.body, '你好');

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('friend hall is invitation-only, not a public room listing', (
    tester,
  ) async {
    final api = _FakeApiClient()
      ..halls = const [
        LobbyHall(
          id: 'ordinary',
          name: '普通大厅',
          minimumPoints: 0,
          maximumPoints: 9999,
          multiplier: 1,
        ),
        LobbyHall(
          id: friendRoomHallId,
          name: '好友房',
          minimumPoints: 0,
          maximumPoints: 0,
          multiplier: 1,
        ),
      ]
      ..roomInvitations = [
        RoomInvitation(
          roomId: 'friend-room-1',
          inviterUserId: 'friend-1',
          inviterNickname: '好友甲',
          invitedAt: DateTime.utc(2026, 1, 1),
        ),
      ];
    final auth = AuthController(api: api, store: _FakeSessionStore());
    final login = auth.login('account', 'password');
    api.loginCompleter.complete(_session);
    await login;

    await tester.pumpWidget(ClientApp(auth: auth));
    await tester.pumpAndSettle();
    await tester.tap(find.text('好友房'));
    await tester.pumpAndSettle();

    expect(find.text('好友甲 邀请你加入好友房'), findsOneWidget);
    expect(api.requestedRoomHallIds, isNot(contains(friendRoomHallId)));
    await tester.tap(find.text('接受邀请'));
    await tester.pumpAndSettle();
    expect(api.joinedInvitationRoomId, 'friend-room-1');
    expect(api.joinedInvitationRequestId, matches(RegExp(r'^[0-9a-f-]{36}$')));
    expect(find.text('好友房 · 房间聊天'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'friend-room creation offers invites from the authenticated list',
    (tester) async {
      final api = _FakeApiClient()
        ..halls = const [
          LobbyHall(
            id: friendRoomHallId,
            name: '好友房',
            minimumPoints: 0,
            maximumPoints: 0,
            multiplier: 1,
          ),
        ]
        ..friends = const [
          PlayerFriend(userId: 'friend-1', nickname: '好友乙', avatarUrl: ''),
        ];
      final auth = AuthController(api: api, store: _FakeSessionStore());
      final login = auth.login('account', 'password');
      api.loginCompleter.complete(_session);
      await login;

      await tester.pumpWidget(ClientApp(auth: auth));
      await tester.pumpAndSettle();
      await tester.tap(find.text('创建房间'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find
            .descendant(
              of: find.byType(AlertDialog),
              matching: find.byType(TextField),
            )
            .first,
        '周末好友局',
      );
      await tester.tap(find.widgetWithText(FilledButton, '创建'));
      await tester.pumpAndSettle();

      expect(find.text('邀请好友加入好友房'), findsOneWidget);
      expect(find.text('好友乙'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('发送邀请'));
      await tester.pumpAndSettle();
      expect(api.invitedRoomId, 'created-friend-room');
      expect(api.invitedFriendId, 'friend-1');
      expect(find.text('好友房邀请已发送。'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('password-protected room creation joins with its password', (
    tester,
  ) async {
    final api = _FakeApiClient()
      ..halls = const [
        LobbyHall(
          id: 'normal',
          name: '普通大厅',
          minimumPoints: 0,
          maximumPoints: 9999,
          multiplier: 1,
        ),
      ];
    final auth = AuthController(api: api, store: _FakeSessionStore());
    final login = auth.login('account', 'password');
    api.loginCompleter.complete(_session);
    await login;

    await tester.pumpWidget(ClientApp(auth: auth));
    await tester.pumpAndSettle();
    await tester.tap(find.text('创建房间'));
    await tester.pumpAndSettle();
    final fields = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(fields.at(0), '密码房');
    await tester.enterText(fields.at(1), 'secret');
    await tester.tap(find.widgetWithText(FilledButton, '创建'));
    await tester.pumpAndSettle();

    expect(api.joinedRoomCode, 'created-friend-room');
    expect(find.text('密码房 · 房间聊天'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('lobby renders server halls and joins a waiting room', (
    tester,
  ) async {
    final api = _FakeApiClient()
      ..halls = const [
        LobbyHall(
          id: 'normal',
          name: '普通大厅',
          minimumPoints: 0,
          maximumPoints: 9999,
          multiplier: 1,
        ),
      ]
      ..roomsByHall = const {
        'normal': [
          LobbyRoom(
            id: 'room-1',
            hallId: 'normal',
            name: '周末牌局',
            status: LobbyRoomStatus.waiting,
            occupiedSeats: 2,
            capacity: 4,
            hasPassword: false,
            version: 3,
            allowSpectators: true,
            minimumPoints: 100,
          ),
        ],
      };
    final auth = AuthController(api: api, store: _FakeSessionStore());
    final login = auth.login('account', 'password');
    api.loginCompleter.complete(_session);
    await login;

    await tester.pumpWidget(ClientApp(auth: auth));
    await tester.pumpAndSettle();
    expect(find.text('普通大厅'), findsOneWidget);
    expect(find.text('周末牌局'), findsOneWidget);
    expect(find.text('Player · 800 分 · 青铜'), findsOneWidget);
    expect(find.text('2/4 人  ·  等待中'), findsOneWidget);
    expect(find.text('最低积分 100'), findsOneWidget);
    expect(find.text('允许观战'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '加入'));
    await tester.pumpAndSettle();
    expect(api.joinedRoomId, 'room-1');
    expect(find.text('周末牌局 · 房间聊天'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'advanced hall admission errors explain the server points requirement',
    (tester) async {
      final api = _FakeApiClient()
        ..halls = const [
          _ordinaryHall,
          LobbyHall(
            id: 'advanced',
            name: '高手大厅',
            minimumPoints: 10000,
            maximumPoints: 39999,
            multiplier: 1.5,
          ),
        ]
        ..roomListErrors['advanced'] = GrpcError.permissionDenied(
          'hall admission denied',
        );
      final auth = AuthController(api: api, store: _FakeSessionStore());
      final login = auth.login('account', 'password');
      api.loginCompleter.complete(_session);
      await login;

      await tester.pumpWidget(ClientApp(auth: auth));
      await tester.pumpAndSettle();
      await tester.tap(find.text('高手大厅'));
      await tester.pumpAndSettle();

      expect(find.text('积分不足，进入高手大厅至少需要 10000 分。'), findsOneWidget);
      expect(find.textContaining('检查网络'), findsNothing);
      expect(api.requestedRoomHallIds, ['ordinary', 'advanced']);

      api.roomListErrors.clear();
      await tester.tap(find.text('重试'));
      await tester.pumpAndSettle();
      expect(find.textContaining('积分不足'), findsNothing);
      expect(api.requestedRoomHallIds, ['ordinary', 'advanced', 'advanced']);
      await tester.pumpWidget(const SizedBox.shrink());
    },
    variant: TargetPlatformVariant({
      TargetPlatform.iOS,
      TargetPlatform.windows,
    }),
  );

  testWidgets('room list network errors retain an explicit retry', (
    tester,
  ) async {
    final api = _FakeApiClient()
      ..halls = const [_ordinaryHall]
      ..roomListErrors['ordinary'] = GrpcError.unavailable('offline');
    final auth = AuthController(api: api, store: _FakeSessionStore());
    final login = auth.login('account', 'password');
    api.loginCompleter.complete(_session);
    await login;

    await tester.pumpWidget(ClientApp(auth: auth));
    await tester.pumpAndSettle();
    expect(find.text('连接服务失败，请检查网络后重试。'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    expect(api.requestedRoomHallIds, ['ordinary']);

    api.roomListErrors.clear();
    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();
    expect(api.requestedRoomHallIds, ['ordinary', 'ordinary']);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'leaving a created room refreshes the lobby without realtime events',
    (tester) async {
      final api = _FakeApiClient()
        ..halls = const [_ordinaryHall]
        ..removeRoomOnLeave = true;
      final auth = AuthController(api: api, store: _FakeSessionStore());
      final login = auth.login('account', 'password');
      api.loginCompleter.complete(_session);
      await login;

      await tester.pumpWidget(ClientApp(auth: auth));
      await tester.pumpAndSettle();
      await tester.tap(find.text('创建房间'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find
            .descendant(
              of: find.byType(AlertDialog),
              matching: find.byType(TextField),
            )
            .first,
        'test',
      );
      await tester.tap(find.widgetWithText(FilledButton, '创建'));
      await tester.pumpAndSettle();
      expect(find.text('test · 房间聊天'), findsOneWidget);
      final readsBeforeLeaving = api.requestedRoomHallIds.length;

      await tester.tap(find.byTooltip('离开房间'));
      await tester.pumpAndSettle();
      expect(api.leftRoomIds, ['created-friend-room']);
      expect(api.requestedRoomHallIds.length, readsBeforeLeaving + 1);
      expect(find.text('test'), findsNothing);
      expect(find.widgetWithText(FilledButton, '加入'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
    variant: TargetPlatformVariant({
      TargetPlatform.iOS,
      TargetPlatform.windows,
    }),
  );

  testWidgets(
    'returning to an open room uses its refreshed expected version',
    (tester) async {
      final api = _FakeApiClient()
        ..halls = const [_ordinaryHall]
        ..roomsByHall = const {
          'ordinary': [_waitingRoom],
        };
      final auth = AuthController(api: api, store: _FakeSessionStore());
      final login = auth.login('account', 'password');
      api.loginCompleter.complete(_session);
      await login;

      await tester.pumpWidget(ClientApp(auth: auth));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, '加入'));
      await tester.pumpAndSettle();
      api.roomsByHall = const {
        'ordinary': [
          LobbyRoom(
            id: 'room-1',
            hallId: 'ordinary',
            name: '周末牌局',
            status: LobbyRoomStatus.waiting,
            occupiedSeats: 1,
            capacity: 4,
            hasPassword: false,
            version: 5,
          ),
        ],
      };
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(api.leftRoomIds, ['room-1']);
      expect(find.text('1/4 人  ·  等待中'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, '加入'));
      await tester.pumpAndSettle();
      expect(api.joinedExpectedVersions, [3, 5]);
      expect(find.text('周末牌局 · 房间聊天'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
    variant: TargetPlatformVariant({
      TargetPlatform.iOS,
      TargetPlatform.windows,
    }),
  );

  for (final (error, message) in [
    (GrpcError.notFound('room not found'), '房间不存在或已解散，请选择其他房间。'),
    (GrpcError.aborted('room state changed'), '房间状态已变化，请根据刷新后的列表重新加入。'),
    (GrpcError.failedPrecondition('room is not available'), '当前阶段暂不可执行此操作。'),
  ]) {
    testWidgets('stale join ${error.code} refreshes rooms without retrying', (
      tester,
    ) async {
      final api = _FakeApiClient()
        ..halls = const [_ordinaryHall]
        ..roomsByHall = const {
          'ordinary': [_waitingRoom],
        }
        ..joinError = error;
      final auth = AuthController(api: api, store: _FakeSessionStore());
      final login = auth.login('account', 'password');
      api.loginCompleter.complete(_session);
      await login;

      await tester.pumpWidget(ClientApp(auth: auth));
      await tester.pumpAndSettle();
      api.roomsByHall = const {};
      await tester.tap(find.widgetWithText(FilledButton, '加入'));
      await tester.pumpAndSettle();

      expect(find.text(message), findsOneWidget);
      expect(find.textContaining('检查网络'), findsNothing);
      expect(api.requestedRoomHallIds, ['ordinary', 'ordinary']);
      expect(api.joinedExpectedVersions, [3]);
      expect(find.text('周末牌局'), findsNothing);
      expect(find.text('周末牌局 · 房间聊天'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  for (final width in [599.0, 600.0, 601.0]) {
    testWidgets(
      'lobby room settings fit at ${width}px with wrapped text',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 1000);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        final api = _FakeApiClient()
          ..halls = const [
            LobbyHall(
              id: 'normal',
              name: '普通大厅',
              minimumPoints: 0,
              maximumPoints: 0,
              multiplier: 1,
            ),
          ]
          ..roomsByHall = const {
            'normal': [
              LobbyRoom(
                id: 'room-1',
                hallId: 'normal',
                name: '周末牌局',
                status: LobbyRoomStatus.waiting,
                occupiedSeats: 2,
                capacity: 4,
                hasPassword: false,
                version: 3,
                allowSpectators: true,
                minimumPoints: 999999999999999,
              ),
            ],
          };
        final auth = AuthController(api: api, store: _FakeSessionStore());
        final login = auth.login('account', 'password');
        api.loginCompleter.complete(_session);
        await login;

        await tester.pumpWidget(ClientApp(auth: auth));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        final threshold = find.text('最低积分 999999999999999');
        final spectators = find.text('允许观战');
        final join = find.widgetWithText(FilledButton, '加入');
        expect(threshold, findsOneWidget);
        expect(spectators, findsOneWidget);
        expect(join.hitTestable(), findsOneWidget);
        if (width >= 600) {
          expect(
            tester.getTopLeft(spectators).dy,
            greaterThan(tester.getTopLeft(threshold).dy),
          );
        }
        final card = find.ancestor(of: join, matching: find.byType(Card));
        expect(
          tester.getBottomRight(join).dy,
          lessThanOrEqualTo(tester.getBottomRight(card).dy),
        );
        await tester.tap(join);
        await tester.pumpAndSettle();
        expect(api.joinedRoomId, 'room-1');
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
      variant: TargetPlatformVariant({
        TargetPlatform.iOS,
        TargetPlatform.windows,
      }),
    );
  }

  testWidgets('joining a password-protected room pre-fills its room number', (
    tester,
  ) async {
    final api = _FakeApiClient()
      ..halls = const [
        LobbyHall(
          id: 'normal',
          name: '普通大厅',
          minimumPoints: 0,
          maximumPoints: 9999,
          multiplier: 1,
        ),
      ]
      ..roomsByHall = const {
        'normal': [
          LobbyRoom(
            id: 'locked-room',
            hallId: 'normal',
            name: '密码房',
            status: LobbyRoomStatus.waiting,
            occupiedSeats: 1,
            capacity: 4,
            hasPassword: true,
            version: 1,
          ),
        ],
      };
    final auth = AuthController(api: api, store: _FakeSessionStore());
    final login = auth.login('account', 'password');
    api.loginCompleter.complete(_session);
    await login;

    await tester.pumpWidget(ClientApp(auth: auth));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '加入'));
    await tester.pumpAndSettle();

    final roomCodeField = find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.labelText == '房间号',
    );
    expect(
      tester.widget<TextField>(roomCodeField).controller!.text,
      'locked-room',
    );
    await tester.tap(
      find.descendant(of: find.byType(AlertDialog), matching: find.text('加入')),
    );
    await tester.pumpAndSettle();
    expect(api.joinedRoomCode, 'locked-room');
  });

  testWidgets('room minimum points cannot exceed the selected hall cap', (
    tester,
  ) async {
    final api = _FakeApiClient()
      ..halls = const [
        LobbyHall(
          id: 'normal',
          name: '普通大厅',
          minimumPoints: 0,
          maximumPoints: 100,
          multiplier: 1,
        ),
      ];
    final auth = AuthController(api: api, store: _FakeSessionStore());
    final login = auth.login('account', 'password');
    api.loginCompleter.complete(_session);
    await login;

    await tester.pumpWidget(ClientApp(auth: auth));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '创建房间'));
    await tester.pumpAndSettle();
    final roomNameField = find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.labelText == '房间名称',
    );
    final minimumPointsField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == '最低准入积分',
    );
    await tester.enterText(roomNameField, '测试牌局');
    await tester.enterText(minimumPointsField, '101');
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, '创建'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('最低准入积分不能超过当前大厅上限（100 分）。'), findsOneWidget);
    expect(api.createdRoomMinimumPoints, isEmpty);
  });

  testWidgets('login validates required fields and shows server errors', (
    tester,
  ) async {
    final api = _FakeApiClient();
    final auth = AuthController(api: api, store: _FakeSessionStore());
    await tester.pumpWidget(ClientApp(auth: auth));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, '登录'));
    await tester.pump();
    expect(
      tester
          .state<FormFieldState<String>>(
            find.byKey(const ValueKey('login-account-field')),
          )
          .errorText,
      '请输入账号',
    );
    expect(
      tester
          .state<FormFieldState<String>>(
            find.byKey(const ValueKey('login-password-field')),
          )
          .errorText,
      '请输入密码',
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'account');
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.widgetWithText(FilledButton, '登录'));
    await tester.pump();
    expect(auth.isLoading, isTrue);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is ModalBarrier &&
            !widget.dismissible &&
            widget.color == Colors.black26,
      ),
      findsOneWidget,
    );

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

    expect(find.text('游戏大厅'), findsOneWidget);
  });

  testWidgets('login password visibility can be toggled', (tester) async {
    final auth = AuthController(
      api: _FakeApiClient(),
      store: _FakeSessionStore(),
    );
    await auth.restoreSession();
    await tester.pumpWidget(MaterialApp(home: LoginScreen(auth: auth)));

    final passwordField = find.byKey(const ValueKey('login-password-field'));
    expect(
      tester
          .widget<TextField>(
            find.descendant(
              of: passwordField,
              matching: find.byType(TextField),
            ),
          )
          .obscureText,
      isTrue,
    );
    await tester.tap(
      find.descendant(of: passwordField, matching: find.byTooltip('显示密码')),
    );
    await tester.pump();
    expect(
      tester
          .widget<TextField>(
            find.descendant(
              of: passwordField,
              matching: find.byType(TextField),
            ),
          )
          .obscureText,
      isFalse,
    );

    await tester.tap(
      find.descendant(of: passwordField, matching: find.byTooltip('隐藏密码')),
    );
    await tester.pump();
    expect(
      tester
          .widget<TextField>(
            find.descendant(
              of: passwordField,
              matching: find.byType(TextField),
            ),
          )
          .obscureText,
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
    await tester.ensureVisible(find.widgetWithText(FilledButton, '注册'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, '注册'));
    await tester.pump();

    expect(find.text('账号不能为空'), findsOneWidget);
    expect(find.text('密码须为8到128字节且需包含字母和数字'), findsOneWidget);
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
    await tester.ensureVisible(find.widgetWithText(FilledButton, '注册'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, '注册'));
    await tester.pump();

    expect(find.text('密码须为8到128字节且需包含字母和数字'), findsOneWidget);
    expect(find.text('两次输入的密码不一致'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'keeps registration fields mounted while the request is pending',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 500));
      addTearDown(() => tester.binding.setSurfaceSize(null));
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
        tester
            .widget<AbsorbPointer>(
              find
                  .ancestor(
                    of: find.byKey(const ValueKey('register-account-field')),
                    matching: find.byType(AbsorbPointer),
                  )
                  .first,
            )
            .absorbing,
        isTrue,
      );
      expect(
        tester
            .widgetList<TextFormField>(find.byType(TextFormField))
            .map((field) => field.controller!.text),
        ['account', 'password123', 'password123', 'nickname'],
      );

      api.registerCompleter.completeError(
        GrpcError.unauthenticated('registration failed'),
      );
      await tester.pumpAndSettle();

      expect(find.text('选择头像'), findsOneWidget);
      expect(
        tester
            .widgetList<TextFormField>(find.byType(TextFormField))
            .map((field) => field.controller!.text),
        ['account', 'password123', 'password123', 'nickname'],
      );
      await tester.binding.setSurfaceSize(null);
    },
  );

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
    await tester.ensureVisible(find.byKey(const ValueKey('register-avatar-1')));
    await tester.pump();
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
    expect(find.text('游戏大厅'), findsOneWidget);
  });

  testWidgets('registration form remains scrollable on a short viewport', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 240));
    addTearDown(() => tester.binding.setSurfaceSize(null));
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

const _ordinaryHall = LobbyHall(
  id: 'ordinary',
  name: '普通大厅',
  minimumPoints: 0,
  maximumPoints: 9999,
  multiplier: 1,
);

const _waitingRoom = LobbyRoom(
  id: 'room-1',
  hallId: 'ordinary',
  name: '周末牌局',
  status: LobbyRoomStatus.waiting,
  occupiedSeats: 2,
  capacity: 4,
  hasPassword: false,
  version: 3,
);

class _FakeApiClient implements ApiClient {
  var closeCount = 0;
  var hallListCount = 0;
  var failHallListing = false;
  final loginCompleter = Completer<AuthSession>();
  final registerCompleter = Completer<AuthSession>();
  final profileUpdateCompleter = Completer<void>();
  String? updatedNickname;
  String? updatedAvatarUrl;
  List<LobbyHall> halls = const [];
  Map<String, List<LobbyRoom>> roomsByHall = const {};
  List<RoomInvitation> roomInvitations = const [];
  List<PlayerFriend> friends = const [];
  final requestedRoomHallIds = <String>[];
  final roomListErrors = <String, GrpcError>{};
  final joinedExpectedVersions = <int>[];
  GrpcError? joinError;
  bool removeRoomOnLeave = false;
  String? joinedRoomId;
  String? joinedRoomCode;
  String? joinedInvitationRoomId;
  String? joinedInvitationRequestId;
  String? invitedFriendId;
  String? invitedRoomId;
  final chatRequestIds = <String>[];
  final sentMessages = <ChatMessage>[];
  final createdRoomMinimumPoints = <int>[];
  final leftRoomIds = <String>[];
  bool failNextChatSend = false;

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
  Future<List<LobbyHall>> listHalls({required String accessToken}) async {
    hallListCount++;
    if (failHallListing) throw GrpcError.unavailable('offline');
    return halls;
  }

  @override
  Future<List<LobbyRoom>> listRooms({
    required String accessToken,
    required String hallId,
  }) async {
    requestedRoomHallIds.add(hallId);
    final error = roomListErrors[hallId];
    if (error != null) throw error;
    return roomsByHall[hallId] ?? const [];
  }

  @override
  Future<LobbyRoom> createRoom({
    required String accessToken,
    required String hallId,
    required String name,
    required String password,
    bool allowSpectators = false,
    int minimumPoints = 0,
    String requestId = '',
  }) async {
    createdRoomMinimumPoints.add(minimumPoints);
    final room = LobbyRoom(
      id: 'created-friend-room',
      hallId: hallId,
      name: name,
      status: LobbyRoomStatus.waiting,
      occupiedSeats: 0,
      capacity: 4,
      hasPassword: password.isNotEmpty,
      version: 1,
    );
    roomsByHall = {
      ...roomsByHall,
      hallId: [...(roomsByHall[hallId] ?? const <LobbyRoom>[]), room],
    };
    return room;
  }

  @override
  Future<LobbyRoom> joinRoom({
    required String accessToken,
    required String roomId,
    int expectedVersion = 0,
  }) async {
    joinedRoomId = roomId;
    joinedExpectedVersions.add(expectedVersion);
    final error = joinError;
    if (error != null) throw error;
    return roomsByHall.values
        .expand((rooms) => rooms)
        .firstWhere((room) => room.id == roomId);
  }

  @override
  Future<void> leaveRoom({
    required String accessToken,
    required String roomId,
    required int expectedVersion,
    required String requestId,
  }) async {
    leftRoomIds.add(roomId);
    if (removeRoomOnLeave) {
      roomsByHall = {
        for (final entry in roomsByHall.entries)
          entry.key: entry.value.where((room) => room.id != roomId).toList(),
      };
    }
  }

  @override
  Future<LobbyRoom> getRoom({
    required String accessToken,
    required String roomId,
  }) async {
    return roomsByHall.values
        .expand((rooms) => rooms)
        .firstWhere((room) => room.id == roomId);
  }

  @override
  Future<LobbyRoom> joinByCode({
    required String accessToken,
    required String roomCode,
    required String password,
  }) async {
    joinedRoomCode = roomCode;
    return LobbyRoom(
      id: roomCode,
      hallId: 'normal',
      name: '密码房',
      status: LobbyRoomStatus.waiting,
      occupiedSeats: 1,
      capacity: 4,
      hasPassword: true,
      version: 1,
    );
  }

  @override
  Future<PlayerStatistics> getStatistics({required String accessToken}) async =>
      const PlayerStatistics(
        totalGames: 0,
        wins: 0,
        losses: 0,
        points: 800,
        rank: '青铜',
      );

  @override
  Future<PlayerStatistics> getFriendStatistics({
    required String accessToken,
    required String userId,
  }) => throw UnimplementedError();

  @override
  Future<void> hidePrivateMessage({
    required String accessToken,
    required String messageId,
  }) async {}

  @override
  Future<void> reportPrivateMessage({
    required String accessToken,
    required String messageId,
    String reason = '',
  }) async {}

  @override
  Future<ChatMessage> sendRoomMessage({
    required String accessToken,
    required String roomId,
    required String body,
    required String requestId,
  }) => throw UnimplementedError();

  @override
  Future<FriendRecentResultsPage> listFriendRecentResults({
    required String accessToken,
    required String userId,
    String pageToken = '',
    int pageSize = 20,
  }) => throw UnimplementedError();

  @override
  Future<List<RoomInvitation>> listRoomInvitations({
    required String accessToken,
  }) async => roomInvitations;

  @override
  Future<List<PlayerFriend>> listFriends({required String accessToken}) async =>
      friends;

  @override
  Future<List<PlayerFriend>> searchPlayers({
    required String accessToken,
    required String query,
  }) async => friends.where((friend) => friend.userId.contains(query)).toList();

  @override
  Future<void> sendFriendRequest({
    required String accessToken,
    required String userId,
    String requestId = '',
  }) async {}

  @override
  Future<List<PlayerFriend>> listFriendRequests({
    required String accessToken,
  }) async => const [];

  @override
  Future<void> respondFriendRequest({
    required String accessToken,
    required String userId,
    required bool accept,
    String requestId = '',
  }) async {}

  @override
  Future<void> removeFriend({
    required String accessToken,
    required String userId,
    String requestId = '',
  }) async {}

  @override
  Future<ChatMessagesPage> listPrivateMessages({
    required String accessToken,
    required String peerUserId,
    String pageToken = '',
    int pageSize = 50,
  }) async => ChatMessagesPage(
    messages: List.unmodifiable(sentMessages),
    nextPageToken: '',
  );

  @override
  Future<ChatMessage> sendPrivateMessage({
    required String accessToken,
    required String peerUserId,
    required String body,
    required String requestId,
  }) async {
    chatRequestIds.add(requestId);
    if (failNextChatSend) {
      failNextChatSend = false;
      throw StateError('injected send failure');
    }
    final message = ChatMessage(
      id: 'message-${sentMessages.length + 1}',
      senderUserId: 'user',
      body: body,
      createdAt: DateTime.utc(2026),
    );
    sentMessages.add(message);
    return message;
  }

  @override
  Future<void> sendRoomInvite({
    required String accessToken,
    required String roomId,
    required String friendId,
    String requestId = '',
  }) async {
    invitedRoomId = roomId;
    invitedFriendId = friendId;
  }

  @override
  Future<LobbyRoom> joinInvitedRoom({
    required String accessToken,
    required String roomId,
    required String requestId,
  }) async {
    joinedInvitationRoomId = roomId;
    joinedInvitationRequestId = requestId;
    return LobbyRoom(
      id: roomId,
      hallId: friendRoomHallId,
      name: '好友房',
      status: LobbyRoomStatus.waiting,
      occupiedSeats: 2,
      capacity: 4,
      hasPassword: false,
      version: 3,
    );
  }

  @override
  Future<void> close() async {
    closeCount++;
  }
}

class _TrackingAuthController extends AuthController {
  _TrackingAuthController({required super.api, required super.store});

  var disposeCount = 0;

  @override
  void dispose() {
    disposeCount++;
    super.dispose();
  }
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
