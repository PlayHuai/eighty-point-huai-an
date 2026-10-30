import 'dart:async';

import 'package:eighty_point_huai_an/src/api/api_client.dart';
import 'package:eighty_point_huai_an/src/api/game_table_client.dart';
import 'package:eighty_point_huai_an/src/api/lobby_models.dart';
import 'package:eighty_point_huai_an/src/api/realtime_event.dart';
import 'package:eighty_point_huai_an/src/auth/auth_controller.dart';
import 'package:eighty_point_huai_an/src/auth/auth_session.dart';
import 'package:eighty_point_huai_an/src/auth/session_store.dart';
import 'package:eighty_point_huai_an/src/generated/huai/v1/api.pb.dart' as pb;
import 'package:eighty_point_huai_an/src/ui/client_providers.dart';
import 'package:eighty_point_huai_an/src/ui/components/card_visual.dart';
import 'package:eighty_point_huai_an/src/ui/game_table_screen.dart';
import 'package:eighty_point_huai_an/src/ui/theme/app_theme.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';

const _summary = LobbyRoom(
  id: 'room-1',
  hallId: 'ordinary',
  name: '测试牌桌',
  status: LobbyRoomStatus.playing,
  occupiedSeats: 4,
  capacity: 4,
  hasPassword: false,
  version: 3,
);

pb.RoomDetails _room({bool spectator = false}) => pb.RoomDetails(
  room: pb.RoomSummary(
    roomId: 'room-1',
    name: '测试牌桌',
    status: pb.RoomStatus.ROOM_STATUS_PLAYING,
    owner: pb.UserProfile(userId: 'player-1'),
    occupiedSeats: 4,
  ),
  version: Int64(3),
  gameSessionId: 'session-1',
  members: [
    for (var seat = 1; seat <= 4; seat++)
      pb.RoomMember(
        userId: seat == 1 && !spectator ? 'viewer' : 'player-$seat',
        role: pb.RoomMemberRole.ROOM_MEMBER_ROLE_PLAYER,
        seatNo: seat,
        team: seat <= 2 ? 1 : 2,
        profile: pb.UserProfile(nickname: '玩家$seat'),
      ),
    if (spectator)
      pb.RoomMember(
        userId: 'viewer',
        role: pb.RoomMemberRole.ROOM_MEMBER_ROLE_SPECTATOR,
        viewSeat: 1,
      ),
  ],
);

pb.GameSnapshot _snapshot() => pb.GameSnapshot(
  gameSessionId: 'session-1',
  handId: 'hand-1',
  stateVersion: Int64(8),
  roundNo: 1,
  phase: 'PLAYING',
  currentTurnUserId: 'viewer',
  visibleHand: ['spades:14:0', 'hearts:5:0'],
  visibleHandCount: 2,
  capturedPoints: Int64(0),
  teamOneLevel: 'A',
  teamTwoLevel: '8',
  scoringTeam: 2,
  availableActions: ['PLAY'],
  bottomOwnerUserId: 'viewer',
  bottomCards: ['clubs:2:0', 'clubs:3:0'],
);

Future<void> _open(
  WidgetTester tester,
  _FakeGameClient client, {
  Stream<RealtimeEvent> events = const Stream.empty(),
  Size size = const Size(1440, 918),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final auth = AuthController(api: _AuthApi(), store: _Store());
  await auth.login('viewer', 'password');
  addTearDown(auth.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        gameTableClientProvider.overrideWithValue(client),
        realtimeEventsProvider.overrideWith((ref) => events),
      ],
      child: MaterialApp(
        theme: AppTheme.dark,
        home: GameTableScreen(auth: auth, room: _summary),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _close(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
}

void main() {
  testWidgets('players see server actions and visibility but not perspective', (
    tester,
  ) async {
    final client = _FakeGameClient(_room(), _snapshot());
    await _open(tester, client);
    expect(find.byKey(const ValueKey('spectator-view-1')), findsNothing);
    expect(find.byKey(const ValueKey('card-visibility')), findsOneWidget);
    expect(find.byKey(const ValueKey('play-action')), findsOneWidget);
    expect(find.byKey(const ValueKey('bottom-cards-panel')), findsOneWidget);
    expect(find.text('反主'), findsNothing);
    expect(find.text('不出'), findsNothing);
    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.byKey(const ValueKey('card-visibility')));
    await tester.pumpAndSettle();
    expect(client.visibility.single.showHand, isTrue);
    expect(client.visibility.single.expectedVersion, Int64(3));
    expect(
      client.visibility.single.requestId,
      matches(RegExp(r'^[0-9a-f-]{36}$')),
    );
    expect(find.text('关牌'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _close(tester);
  });

  testWidgets('spectators only switch server perspective and never play', (
    tester,
  ) async {
    final client = _FakeGameClient(
      _room(spectator: true),
      _snapshot()
        ..visibleHand.clear()
        ..bottomCards.clear(),
    );
    await _open(tester, client);
    expect(find.byKey(const ValueKey('card-visibility')), findsNothing);
    expect(find.byKey(const ValueKey('play-buttons')), findsNothing);
    expect(find.byKey(const ValueKey('play-action')), findsNothing);
    expect(find.byKey(const ValueKey('bottom-cards-panel')), findsNothing);
    expect(find.byType(CardVisual), findsNothing);
    expect(find.byType(CardBack), findsNWidgets(2));
    await tester.tap(find.byKey(const ValueKey('spectator-view-3')));
    await tester.pumpAndSettle();
    expect(client.views.single.viewSeat, 3);
    expect(client.views.single.expectedVersion, Int64(3));
    expect(
      tester
          .widget<ChoiceChip>(find.byKey(const ValueKey('spectator-view-3')))
          .selected,
      isTrue,
    );
    expect(
      tester
          .widget<ChoiceChip>(find.byKey(const ValueKey('spectator-view-1')))
          .selected,
      isFalse,
    );
    expect(client.actions, isEmpty);
    await _close(tester);
  });

  testWidgets('public bottom is visible for spectators after capture ends', (
    tester,
  ) async {
    final client = _FakeGameClient(
      _room(spectator: true),
      _snapshot()
        ..visibleHand.clear()
        ..bottomPublic = true,
    );
    await _open(tester, client);
    expect(find.byKey(const ValueKey('bottom-cards-panel')), findsOneWidget);
    expect(find.text('已公开'), findsOneWidget);
    expect(find.byType(CardVisual), findsNWidgets(2));
    await _close(tester);
  });

  testWidgets('non-owner players cannot inspect private bottom', (
    tester,
  ) async {
    final client = _FakeGameClient(
      _room(),
      _snapshot()..bottomOwnerUserId = 'player-2',
    );
    await _open(tester, client);
    expect(find.byKey(const ValueKey('bottom-cards-panel')), findsNothing);
    await _close(tester);
  });

  testWidgets('play retry reuses request id and conflict refreshes state', (
    tester,
  ) async {
    final client = _FakeGameClient(_room(), _snapshot())
      ..actionError = GrpcError.unavailable('offline');
    await _open(tester, client);
    await tester.tap(find.byKey(const ValueKey('hand-card-spades:14:0')));
    await tester.pump();
    await tester.tap(find.text('确认出牌 · 1 张'));
    await tester.pumpAndSettle();
    expect(client.actions.single.expectedVersion, Int64(8));
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.tap(find.text('确认出牌 · 1 张'));
    await tester.pumpAndSettle();
    expect(client.actions, hasLength(2));
    expect(client.actions.first.requestId, client.actions.last.requestId);
    expect(client.actions.last.action.playCards.cards, ['spades:14:0']);

    client.actionError = GrpcError.aborted('stale version');
    client.snapshot = _snapshot()
      ..stateVersion = Int64(9)
      ..roundNo = 2
      ..teamOneLevel = 'K'
      ..availableActions.clear();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('我方 K  :  对方 8'), findsOneWidget);
    expect(find.textContaining('第 2 局'), findsOneWidget);
    expect(find.text('确认出牌 · 1 张'), findsNothing);
    await _close(tester);
  });

  for (final width in [320.0, 600.0, 1449.0]) {
    testWidgets(
      'table fits $width with four seats',
      (tester) async {
        await _open(
          tester,
          _FakeGameClient(_room(), _snapshot()),
          size: Size(width, 918),
        );
        for (var seat = 1; seat <= 4; seat++) {
          expect(find.byKey(ValueKey('table-seat-$seat')), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
        await _close(tester);
      },
      variant: TargetPlatformVariant({
        TargetPlatform.iOS,
        TargetPlatform.windows,
      }),
    );
  }
}

class _FakeGameClient implements GameTableClient {
  _FakeGameClient(this.room, this.snapshot);
  pb.RoomDetails room;
  pb.GameSnapshot snapshot;
  GrpcError? actionError;
  final actions = <pb.SubmitActionRequest>[];
  final views = <pb.SpectatorViewRequest>[];
  final visibility = <pb.SpectatorViewRequest>[];

  @override
  Future<pb.RoomDetails> getRoom(pb.RoomRequest request) async => room;
  @override
  Future<pb.GameSnapshot> getSnapshot(pb.GameSnapshotRequest request) async =>
      snapshot;
  @override
  Future<pb.RoomDetails> setSpectatorView(
    pb.SpectatorViewRequest request,
  ) async {
    views.add(request);
    room.members.last.viewSeat = request.viewSeat;
    return room;
  }

  @override
  Future<pb.RoomDetails> setHandVisibility(
    pb.SpectatorViewRequest request,
  ) async {
    visibility.add(request);
    room.members.first.showHand = request.showHand;
    return room;
  }

  @override
  Future<pb.SubmitActionResponse> submitAction(
    pb.SubmitActionRequest request,
  ) async {
    actions.add(request);
    final error = actionError;
    if (error != null) throw error;
    return pb.SubmitActionResponse(accepted: true, stateVersion: Int64(9));
  }

  @override
  Future<void> close() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _AuthApi implements ApiClient {
  @override
  Future<AuthSession> login({
    required String account,
    required String password,
  }) async => AuthSession(
    userId: 'viewer',
    nickname: '测试玩家',
    accessToken: 'test-token',
    refreshToken: 'test-refresh',
    expiresAt: DateTime.utc(2100),
  );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Store implements SessionStore {
  @override
  Future<AuthSession?> read() async => null;
  @override
  Future<void> write(AuthSession session) async {}
  @override
  Future<void> clear() async {}
}
