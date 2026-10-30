import 'dart:async';
import 'dart:math' as math;

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grpc/grpc.dart';

import '../api/game_table_client.dart';
import '../api/lobby_models.dart';
import '../api/realtime_event.dart';
import '../api/request_id.dart';
import '../auth/auth_controller.dart';
import '../generated/huai/v1/api.pb.dart' as pb;
import 'client_providers.dart';
import 'components/design_icon.dart';
import 'components/game_table_board.dart';
import 'components/table_cards.dart';
import 'components/table_status_bar.dart';
import 'theme/app_theme.dart';

final gameTableClientProvider = Provider.autoDispose<GameTableClient>((ref) {
  final endpoint = ref.watch(apiEndpointProvider);
  final session = ref.watch(
    authControllerProvider.select((auth) => auth.session),
  );
  if (endpoint == null || session == null) {
    throw StateError('牌桌需要已登录的服务端连接。');
  }
  final client = GrpcGameTableClient(endpoint, session.accessToken);
  ref.onDispose(() => unawaited(client.close()));
  return client;
});

class GameTableScreen extends ConsumerStatefulWidget {
  const GameTableScreen({required this.auth, required this.room, super.key});

  final AuthController auth;
  final LobbyRoom room;

  @override
  ConsumerState<GameTableScreen> createState() => _GameTableScreenState();
}

class _GameTableScreenState extends ConsumerState<GameTableScreen> {
  pb.RoomDetails? _room;
  pb.GameSnapshot? _game;
  Object? _loadError;
  bool _busy = false;
  bool _loading = true;
  bool _refreshing = false;
  bool _refreshAgain = false;
  int _revision = 0;
  bool _canPop = false;
  int _lastSeenSeq = 0;
  final _selected = <String>{};
  final _pending = <String, String>{};
  Timer? _poll;

  String get _userId => widget.auth.session!.userId;
  pb.RoomMember? get _member =>
      _room?.members.where((member) => member.userId == _userId).firstOrNull;
  bool get _isPlayer =>
      _member?.role == pb.RoomMemberRole.ROOM_MEMBER_ROLE_PLAYER;
  int get _perspective =>
      _isPlayer ? _member!.seatNo : (_member?.viewSeat ?? 1);
  GameTableClient get _client => ref.read(gameTableClientProvider);

  @override
  void initState() {
    super.initState();
    unawaited(_refresh());
    _poll = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!_busy && !_loading && _loadError == null) unawaited(_refresh());
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _refresh({bool reconnect = false}) async {
    if (!mounted || _canPop) return;
    if (_refreshing) {
      _refreshAgain = true;
      return;
    }
    _refreshing = true;
    final revision = _revision;
    try {
      final room = await _client.getRoom(
        pb.RoomRequest(roomId: widget.room.id),
      );
      pb.GameSnapshot? game;
      if (room.gameSessionId.isNotEmpty) {
        if (reconnect) {
          final recovered = await _client.reconnect(
            pb.RequestReconnectRequest(
              gameSessionId: room.gameSessionId,
              lastSeenSeq: Int64(_lastSeenSeq),
            ),
          );
          game = recovered.snapshot;
          for (final event in recovered.events) {
            _lastSeenSeq = math.max(_lastSeenSeq, event.seq.toInt());
          }
        } else {
          game = await _client.getSnapshot(
            pb.GameSnapshotRequest(gameSessionId: room.gameSessionId),
          );
        }
      }
      if (!mounted || revision != _revision || _canPop) return;
      setState(() {
        _room = room;
        _game = game;
        if (game != null) {
          _lastSeenSeq = math.max(_lastSeenSeq, game.seq.toInt());
        }
        _selected.removeWhere(
          (card) => !(game?.visibleHand.contains(card) ?? false),
        );
        _loadError = null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted || revision != _revision || _canPop) return;
      setState(() {
        _loadError = error;
        _loading = false;
        _game = null;
        _selected.clear();
      });
    } finally {
      _refreshing = false;
      if (_refreshAgain && mounted && !_canPop) {
        _refreshAgain = false;
        unawaited(_refresh(reconnect: reconnect));
      }
    }
  }

  void _receive(RealtimeEvent event) {
    if (event.type == 'CONNECTION_RESTORED') {
      unawaited(_refresh(reconnect: true));
    } else if (event.roomId == widget.room.id &&
        (event.type == 'ROOM_STATE_CHANGED' ||
            event.type == 'GAME_STATE_CHANGED')) {
      if (!_busy) unawaited(_refresh());
    }
  }

  String _message(Object error) => switch (error) {
    GrpcError(code: StatusCode.aborted) => '状态已更新，请检查当前牌局后重新操作。',
    GrpcError(code: StatusCode.permissionDenied) => '当前身份没有此操作或查看权限。',
    GrpcError(code: StatusCode.failedPrecondition) => '当前阶段不允许此操作。',
    GrpcError(code: StatusCode.invalidArgument) => '所选牌或操作参数不符合规则。',
    GrpcError(code: StatusCode.unauthenticated) => '登录状态已失效，请重新登录。',
    GrpcError(code: StatusCode.notFound) => '房间或牌局已不存在。',
    GrpcError(code: StatusCode.unimplemented) => '服务端尚未提供此牌桌功能，请更新服务端。',
    _ => '牌桌连接失败，请重试。',
  };

  Future<void> _run(
    String key,
    Future<void> Function(String requestId) operation, {
    bool clearPrivateState = false,
  }) async {
    if (_busy || _room == null) return;
    final requestId = _pending.putIfAbsent(key, createRequestId);
    _revision++;
    setState(() {
      _busy = true;
      if (clearPrivateState) {
        _game = null;
        _selected.clear();
      }
    });
    try {
      await operation(requestId);
      _pending.remove(key);
      await _refresh();
    } catch (error) {
      if (error is GrpcError && error.code == StatusCode.aborted) {
        _pending.remove(key);
        await _refresh();
      }
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(_message(error))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _seat(int seat) async {
    final room = _room!;
    if (room.room.status != pb.RoomStatus.ROOM_STATUS_WAITING) return;
    final key = 'seat:$seat:${room.version}';
    await _run(key, (id) async {
      final request = pb.SeatRequest(
        roomId: widget.room.id,
        seatNo: seat,
        expectedVersion: room.version,
        requestId: id,
      );
      if (_isPlayer && _member!.seatNo != 0) {
        await _client.changeSeat(request);
      } else {
        await _client.sitDown(request);
      }
    });
  }

  Future<void> _switchView(int seat) async {
    if (_isPlayer || seat == _perspective) return;
    final room = _room!;
    await _run('view:$seat:${room.version}', (id) async {
      await _client.setSpectatorView(
        pb.SpectatorViewRequest(
          roomId: widget.room.id,
          viewSeat: seat,
          expectedVersion: room.version,
          requestId: id,
        ),
      );
    }, clearPrivateState: true);
  }

  Future<void> _visibility() async {
    if (!_isPlayer) return;
    final room = _room!;
    final show = !_member!.showHand;
    await _run('visibility:$show:${room.version}', (id) async {
      await _client.setHandVisibility(
        pb.SpectatorViewRequest(
          roomId: widget.room.id,
          showHand: show,
          expectedVersion: room.version,
          requestId: id,
        ),
      );
    });
  }

  Future<void> _start() async {
    final room = _room!;
    await _run('start:${room.version}', (id) async {
      await _client.startGame(
        pb.RoomRequest(
          roomId: widget.room.id,
          requestId: id,
          expectedVersion: room.version,
        ),
      );
    });
  }

  Future<void> _standUp() async {
    final room = _room!;
    await _run('stand:${room.version}', (id) async {
      await _client.standUp(
        pb.RoomRequest(
          roomId: widget.room.id,
          requestId: id,
          expectedVersion: room.version,
        ),
      );
    }, clearPrivateState: true);
  }

  Future<void> _submit(String type) async {
    final game = _game;
    if (!_isPlayer || game == null || !game.availableActions.contains(type)) {
      return;
    }
    final cards = _selected.toList()..sort();
    final action = pb.GameAction();
    switch (type) {
      case 'PLAY':
        action.playCards = pb.PlayCardsAction(cards: cards);
      case 'BURY':
        action.buryCards = pb.BuryCardsAction(cards: cards);
      case 'DECLARE':
      case 'COUNTER':
      case 'REDECLARE':
        final suit = cards.isEmpty ? '' : cards.first.split(':').first;
        final declaration = pb.DeclareTrumpAction(suit: suit, cards: cards);
        if (type == 'DECLARE') action.declareTrump = declaration;
        if (type == 'COUNTER') action.counterTrump = declaration;
        if (type == 'REDECLARE') action.redeclareTrump = declaration;
      case 'AUTOPLAY':
        action.confirmAutoplay = pb.ConfirmAutoplayAction(accept: true);
      case 'PASS':
        action.pass = pb.PassAction();
      case 'CONTINUE':
        action.continueAction = pb.ContinueAction();
      default:
        return;
    }
    final key = 'game:${game.gameSessionId}:${game.stateVersion}:$type:$cards';
    await _run(key, (id) async {
      final response = await _client.submitAction(
        pb.SubmitActionRequest(
          gameSessionId: game.gameSessionId,
          handId: game.handId,
          requestId: id,
          expectedVersion: game.stateVersion,
          action: action,
        ),
      );
      if (!response.accepted) {
        throw GrpcError.failedPrecondition(response.errorCode);
      }
      _selected.clear();
    });
  }

  Future<void> _leave() async {
    if (_busy) return;
    final version = _room?.version ?? Int64(widget.room.version);
    final key = 'leave:$version';
    final id = _pending.putIfAbsent(key, createRequestId);
    setState(() => _busy = true);
    try {
      await widget.auth.api.leaveRoom(
        accessToken: widget.auth.session!.accessToken,
        roomId: widget.room.id,
        expectedVersion: version.toInt(),
        requestId: id,
      );
      if (!mounted) return;
      setState(() => _canPop = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    } catch (error) {
      if (error is GrpcError && error.code == StatusCode.aborted) {
        _pending.remove(key);
        await _refresh();
      }
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(_message(error))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(realtimeEventsProvider, (_, next) => next.whenData(_receive));
    return PopScope(
      canPop: _canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_leave());
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: '离开房间',
            onPressed: _busy ? null : _leave,
            icon: const DesignIcon(name: DesignIconName.back, enabled: true),
          ),
          title: const Text('淮安80分'),
          actions: [
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(DarkTokens.spacingS3),
                child: Text(
                  '${widget.room.name} ${widget.room.id} · 第 ${_game?.roundNo ?? 1} 局',
                  key: const ValueKey('room-identity'),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_message(_loadError!)),
                    TextButton(
                      onPressed: () => _refresh(reconnect: true),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              )
            : _content(),
      ),
    );
  }

  Widget _content() {
    final game = _game;
    final room = _room!;
    final perspective = _perspective.clamp(1, 4);
    final ownTeam =
        room.members
            .where((member) => member.seatNo == perspective)
            .firstOrNull
            ?.team ??
        0;
    final ownLevel = ownTeam == 1 ? game?.teamOneLevel : game?.teamTwoLevel;
    final otherLevel = ownTeam == 1 ? game?.teamTwoLevel : game?.teamOneLevel;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 600;
        final minHeight = compact
            ? DarkTokens.spacingS6 * 20
            : DarkTokens.spacingS6 * 22;
        return SingleChildScrollView(
          child: SizedBox(
            height: math.max(constraints.maxHeight, minHeight),
            child: Column(
              children: [
                TableStatusBar(
                  ownLevel: ownLevel ?? '—',
                  opponentLevel: otherLevel ?? '—',
                  points: game?.capturedPoints.toInt() ?? 0,
                  scoringPerspective: game?.scoringTeam == ownTeam,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(DarkTokens.spacingS3),
                    child: GameTableBoard(
                      members: room.members,
                      perspective: perspective,
                      currentTurnUserId: game?.currentTurnUserId ?? '',
                      ownerId: room.room.owner.userId,
                      dealerUserId: game?.dealerUserId ?? '',
                      onSeat:
                          room.room.status ==
                                  pb.RoomStatus.ROOM_STATUS_WAITING &&
                              !_busy
                          ? _seat
                          : null,
                      center: _publicPlays(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(DarkTokens.spacingS3),
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: DarkTokens.spacingS5,
                    runSpacing: DarkTokens.spacingS3,
                    children: [
                      if (game != null &&
                          (game.bottomPublic ||
                              (_isPlayer &&
                                  game.bottomOwnerUserId == _userId)) &&
                          game.bottomCards.isNotEmpty)
                        SizedBox(
                          width: math.min(
                            constraints.maxWidth - DarkTokens.spacingS5,
                            DarkTokens.spacingS6 * 8,
                          ),
                          child: BottomCardsPanel(
                            key: ValueKey(
                              '${game.handId}:${game.bottomPublic}',
                            ),
                            cards: game.bottomCards,
                            publiclyRevealed: game.bottomPublic,
                            level: ownLevel ?? '',
                            trumpSuit: game.trumpSuit,
                          ),
                        ),
                      if (_isPlayer) _playerActions(),
                    ],
                  ),
                ),
                SizedBox(
                  height: DarkTokens.spacingS6 * (compact ? 3 : 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (game != null && game.dealerSeat == perspective)
                        Padding(
                          padding: const EdgeInsets.only(
                            left: DarkTokens.spacingS3,
                            top: DarkTokens.spacingS5,
                            right: DarkTokens.spacingS3,
                          ),
                          child: Image.asset(
                            '../ui-design/asserts/ic_lighter/lighter.png',
                            key: const ValueKey('dealer-marker-main'),
                            width: DarkTokens.spacingS6,
                            height: DarkTokens.spacingS6,
                            semanticLabel: '本轮庄家',
                          ),
                        ),
                      Expanded(
                        child: TableHand(
                          cards: game?.visibleHand ?? const [],
                          selected: _selected,
                          hiddenCount: game?.visibleHandCount ?? 0,
                          level: ownLevel ?? '',
                          trumpSuit: game?.trumpSuit ?? '',
                          onSelect: _isPlayer && !_busy && game != null
                              ? (card) => setState(() {
                                  if (!_selected.add(card))
                                    _selected.remove(card);
                                })
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                _footer(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _publicPlays() {
    final game = _game;
    if (game == null) {
      return const Center(child: Text('等待四位玩家入座，由房主开始'));
    }
    return Column(
      children: [
        Text(
          game.currentTurnUserId == _userId
              ? '${game.phase} · 轮到你操作'
              : game.phase,
          key: _isPlayer ? const ValueKey('play-action') : null,
          textAlign: TextAlign.center,
          style: const TextStyle(color: DarkTokens.goldBright),
        ),
        const SizedBox(height: DarkTokens.spacingS3),
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: DarkTokens.spacingS3,
              runSpacing: DarkTokens.spacingS2,
              children: [
                for (final play in game.publicPlays)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${play.seatNo} 号位'),
                      SizedBox(
                        height: DarkTokens.spacingS6 * 2,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (final card in play.cards)
                              SizedBox(
                                width: DarkTokens.spacingS6,
                                child: TableCard(card: card),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _playerActions() {
    final game = _game;
    if (game == null) {
      return Wrap(
        spacing: DarkTokens.spacingS3,
        children: [
          if (_room!.room.owner.userId == _userId &&
              _room!.room.occupiedSeats == 4)
            FilledButton(
              onPressed: _busy ? null : _start,
              child: const Text('开始游戏'),
            ),
          if (_member!.seatNo != 0)
            OutlinedButton(
              onPressed: _busy ? null : _standUp,
              child: const Text('站起'),
            ),
        ],
      );
    }
    return Wrap(
      key: const ValueKey('play-buttons'),
      spacing: DarkTokens.spacingS3,
      runSpacing: DarkTokens.spacingS2,
      children: [
        for (final action in game.availableActions)
          if (const {
            'PLAY',
            'BURY',
            'DECLARE',
            'COUNTER',
            'REDECLARE',
            'AUTOPLAY',
            'PASS',
            'CONTINUE',
          }.contains(action))
            FilledButton(
              onPressed: _busy ? null : () => _submit(action),
              child: Text(switch (action) {
                'PLAY' => '确认出牌 · ${_selected.length} 张',
                'BURY' => '确认扣底 · ${_selected.length} 张',
                'DECLARE' => '定主',
                'COUNTER' => '反主',
                'REDECLARE' => '重新定主',
                'PASS' => '不定主',
                'CONTINUE' => '下一局',
                _ => '托管',
              }),
            ),
      ],
    );
  }

  Widget _footer() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(DarkTokens.spacingS4),
    color: DarkTokens.bgPanel,
    child: SafeArea(
      top: false,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: DarkTokens.spacingS2,
        runSpacing: DarkTokens.spacingS2,
        children: [
          if (!_isPlayer && _member != null) ...[
            const Text('主视角'),
            for (var seat = 1; seat <= 4; seat++)
              ChoiceChip(
                key: ValueKey('spectator-view-$seat'),
                label: Text('$seat'),
                selected: seat == _perspective,
                selectedColor: DarkTokens.goldDark,
                onSelected: _busy ? null : (_) => _switchView(seat),
              ),
          ],
          if (_isPlayer)
            TextButton.icon(
              key: const ValueKey('card-visibility'),
              onPressed: _busy ? null : _visibility,
              icon: DesignIcon(
                name: _member!.showHand
                    ? DesignIconName.openHand
                    : DesignIconName.closeHand,
                enabled: !_busy,
                size: DarkTokens.spacingS5,
              ),
              label: Text(_member!.showHand ? '关牌' : '开牌'),
            ),
        ],
      ),
    ),
  );
}
