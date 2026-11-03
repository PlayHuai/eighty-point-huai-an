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
import '../domain/robot_decision.dart' as robot;
import 'client_providers.dart';
import 'components/design_icon.dart';
import 'components/game_table_board.dart';
import 'components/game_settlement_panel.dart';
import 'components/completed_trick.dart';
import 'components/table_cards.dart';
import 'components/table_status_bar.dart';
import 'theme/app_theme.dart';
import 'room_chat_screen.dart';
import 'settings_dialog.dart';
import 'components/turn_countdown.dart';
import 'components/card_visual.dart';

// RPC calls read this provider outside build; keep the channel for the current
// authenticated scope instead of disposing it between asynchronous requests.
final gameTableClientProvider = Provider<GameTableClient>((ref) {
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
  bool _autoPlaying = false;
  bool _autoActionScheduled = false;
  int? _autoPausedVersion;
  int _revision = 0;
  bool _canPop = false;
  bool _closedDialog = false;
  bool _waitDialog = false;
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
      if (room.room.status == pb.RoomStatus.ROOM_STATUS_CLOSED) {
        if (mounted) {
          setState(() {
            _room = room;
            _loading = false;
          });
          unawaited(_confirmClosed());
        }
        return;
      }
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
        if (game != null && game.hasActionDeadline()) {
          final seat = room.members
              .where((member) => member.userId == _userId)
              .firstOrNull
              ?.seatNo;
          _autoPlaying = game.autoplaySeats.contains(seat);
        }
        if (game != null) {
          _lastSeenSeq = math.max(_lastSeenSeq, game.seq.toInt());
        }
        _selected.removeWhere(
          (card) => !(game?.visibleHand.contains(card) ?? false),
        );
        _loadError = null;
        _loading = false;
      });
      _resetAutoPlayAtGameEnd(game);
      if (game?.readyWaitPrompt == true &&
          game!.availableActions.contains('WAIT_VOTE') &&
          !_waitDialog)
        unawaited(_voteWait());
      if (_autoPlaying) unawaited(_maybeAutoPlay());
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

  Future<void> _toggleAutoPlay() async {
    final game = _game;
    if (game != null && game.hasActionDeadline()) {
      final accept = !_autoPlaying;
      await _run('autoplay:${game.stateVersion}:$accept', (id) async {
        final response = await _client.submitAction(
          pb.SubmitActionRequest(
            gameSessionId: game.gameSessionId,
            handId: game.handId,
            requestId: id,
            expectedVersion: game.stateVersion,
            action: pb.GameAction(
              confirmAutoplay: pb.ConfirmAutoplayAction(accept: accept),
            ),
          ),
        );
        if (!response.accepted)
          throw GrpcError.failedPrecondition(response.errorCode);
      });
      return;
    }
    setState(() {
      _autoPlaying = !_autoPlaying;
      _autoPausedVersion = null;
    });
    if (_autoPlaying) unawaited(_maybeAutoPlay());
  }

  void _resetAutoPlayAtGameEnd(pb.GameSnapshot? game) {
    if (game == null) return;
    final terminal = {
      'FINISHED',
      'GAME_OVER',
      'ABORTED',
    }.contains(game.state.toUpperCase());
    if (_autoPlaying && terminal) {
      setState(() {
        _autoPlaying = false;
        _autoPausedVersion = null;
      });
    }
  }

  Future<void> _maybeAutoPlay() async {
    final game = _game;
    if (!mounted ||
        !_autoPlaying ||
        _autoActionScheduled ||
        _busy ||
        !_isPlayer ||
        game == null ||
        {
          'awaiting_ready',
          'hand_over',
          'void',
          'finished',
        }.contains(game.phase) ||
        game.hasActionDeadline() ||
        (game.currentTurnUserId != _userId &&
            !game.availableActions.contains('CONTINUE') &&
            !game.availableActions.contains('DECLARE')) ||
        _autoPausedVersion == game.stateVersion.toInt()) {
      return;
    }
    _autoActionScheduled = true;
    try {
      final selected = _chooseRobotAction(game);
      if (selected == null) return;
      final (type, cards) = selected;
      setState(() {
        _selected
          ..clear()
          ..addAll(cards.map((card) => card.toString()));
      });
      await _submit(type, automated: true);
    } catch (error) {
      if (mounted) {
        setState(() {
          _autoPausedVersion = game.stateVersion.toInt();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('托管决策失败，已等待下一次牌局状态更新：${_message(error)}')),
        );
      }
    } finally {
      _autoActionScheduled = false;
    }
  }

  (String, List<robot.Card>)? _chooseRobotAction(pb.GameSnapshot game) {
    final available = game.availableActions.toSet();
    if (available.contains('CONTINUE')) return ('CONTINUE', const []);
    final hand = _robotHand(game);
    if (available.contains('BURY')) {
      return (
        'BURY',
        robot.selectBottom(
          hand,
          _robotSuit(game.trumpSuit),
          game.dealerUserId == _userId,
        ),
      );
    }
    if (available.contains('DECLARE') ||
        available.contains('REDECLARE') ||
        available.contains('COUNTER')) {
      final action = robot.decideTrump(
        hand,
        robot.TrumpState(
          canDeclare:
              available.contains('DECLARE') || available.contains('REDECLARE'),
          canCounter: available.contains('COUNTER'),
          currentCounter:
              game.currentCounter > 0 &&
                  game.currentCounter <= robot.CounterKind.values.length
              ? robot.CounterKind.values[game.currentCounter - 1]
              : null,
        ),
      );
      return switch (action.kind) {
        robot.TrumpActionKind.declare => (
          available.contains('REDECLARE') ? 'REDECLARE' : 'DECLARE',
          action.cards,
        ),
        robot.TrumpActionKind.counter => ('COUNTER', action.cards),
        robot.TrumpActionKind.pass when available.contains('PASS') => (
          'PASS',
          const [],
        ),
        _ => null,
      };
    }
    if (available.contains('PASS')) return ('PASS', const []);
    if (available.contains('PLAY')) {
      final publicPlays = game.publicPlays
          .map(
            (play) => play.cards.map(robot.Card.parse).toList(growable: false),
          )
          .toList(growable: false);
      final seen = _robotSeen(game, hand, publicPlays);
      if (publicPlays.isEmpty) {
        return ('PLAY', robot.lead(hand, seen).cards);
      }
      if (game.suggestedPlay.isNotEmpty) {
        return (
          'PLAY',
          game.suggestedPlay.map(robot.Card.parse).toList(growable: false),
        );
      }
      return null;
    }
    return null;
  }

  robot.Hand _robotHand(pb.GameSnapshot game) => robot.Hand(
    game.visibleHand.map(robot.Card.parse),
    levelRank: game.trumpLevel >= 2 && game.trumpLevel <= 14
        ? game.trumpLevel
        : 2,
    trumpSuit: _robotSuit(game.trumpSuit),
  );

  robot.Suit _robotSuit(String value) => switch (value.toLowerCase()) {
    'clubs' => robot.Suit.clubs,
    'diamonds' => robot.Suit.diamonds,
    'hearts' => robot.Suit.hearts,
    'spades' => robot.Suit.spades,
    '' || 'none' || 'no suit' => robot.Suit.none,
    _ => throw FormatException('Unknown trump suit: $value'),
  };

  robot.SeenInfo _robotSeen(
    pb.GameSnapshot game,
    robot.Hand hand,
    List<List<robot.Card>> publicPlays,
  ) {
    final played = game.publicCards.map(robot.Card.parse).toList();
    if (publicPlays.isEmpty) return robot.SeenInfo(playedCards: played);
    final leadSuit = hand.effectiveSuit(publicPlays.first.first);
    final ownTeam = _member?.team;
    final voids = <robot.Suit>{};
    for (final play in game.publicPlays) {
      final teammate = _room?.members
          .where((member) => member.seatNo == play.seatNo)
          .firstOrNull;
      if (teammate?.team == ownTeam &&
          teammate?.userId != _userId &&
          publicPlays[game.publicPlays.indexOf(play)].every(
            (card) => hand.effectiveSuit(card) != leadSuit,
          )) {
        voids.add(leadSuit);
      }
    }
    final winning = robot.currentWinningPlay(hand, publicPlays);
    final winningSeat = game
        .publicPlays[publicPlays.indexWhere(
          (cards) =>
              cards.toSet().containsAll(winning) &&
              winning.toSet().containsAll(cards),
        )]
        .seatNo;
    final winningMember = _room?.members
        .where((member) => member.seatNo == winningSeat)
        .firstOrNull;
    return robot.SeenInfo(
      playedCards: played,
      teammateVoidSuits: voids,
      teammateControlsTrick:
          winningMember?.team == ownTeam && winningMember?.userId != _userId,
    );
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
    void Function()? onFailure,
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
      onFailure?.call();
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

  Future<void> _confirmClosed() async {
    if (_closedDialog || !mounted) return;
    _closedDialog = true;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('房间已关闭'),
          content: const Text('房间内已无玩家，请确认退出。'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('确认'),
            ),
          ],
        ),
      ),
    );
    if (mounted) await _leave();
  }

  Future<void> _voteWait() async {
    if (_waitDialog || !mounted) return;
    _waitDialog = true;
    final continueWaiting = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('准备等待已超过5分钟'),
          content: Text(
            widget.room.practiceMode
                ? '是否继续等待？选择“否”将流局，不计分。'
                : '是否继续等待？两名玩家选择“否”将流局，不计分。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('否'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('是'),
            ),
          ],
        ),
      ),
    );
    final game = _game;
    if (mounted && game != null && continueWaiting != null) {
      await _run('wait:${game.stateVersion}:$continueWaiting', (id) async {
        await _client.submitAction(
          pb.SubmitActionRequest(
            gameSessionId: game.gameSessionId,
            handId: game.handId,
            requestId: id,
            expectedVersion: game.stateVersion,
            action: pb.GameAction(
              waitVote: pb.ConfirmAutoplayAction(accept: continueWaiting),
            ),
          ),
        );
      });
    }
    _waitDialog = false;
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

  Future<void> _submit(String type, {bool automated = false}) async {
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
    await _run(
      key,
      (id) async {
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
      },
      onFailure: automated
          ? () => _autoPausedVersion = game.stateVersion.toInt()
          : null,
    );
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
            TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => SettingsDialog(auth: widget.auth),
              ),
              child: const Text('设置'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) =>
                      RoomChatScreen(auth: widget.auth, room: widget.room),
                ),
              ),
              child: const Text('房间聊天'),
            ),
            TextButton(
              onPressed: _room == null ? null : _showMembers,
              child: const Text('成员'),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(DarkTokens.spacingS3),
                child: Text(
                  '${widget.room.name} ${widget.room.practiceMode ? '· 练习房' : widget.room.id} · 第 ${_game?.roundNo ?? 1} 局',
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
            : DarkTokens.spacingS6 * 16;
        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: math.max(constraints.maxHeight, minHeight),
                child: Column(
                  children: [
                    TableStatusBar(
                      trumpSuit: game?.trumpSuit ?? '',
                      phase: _phaseLabel(game?.phase ?? ''),
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
                          outsidePerspective: !compact,
                          phase: game?.phase ?? '',
                          readySeats: game?.readySeats ?? const [],
                          bottomCards:
                              game != null &&
                                  (game.bottomPublic ||
                                      (_isPlayer &&
                                          game.bottomOwnerUserId == _userId))
                              ? game.bottomCards
                              : const [],
                          bottomPublic: game?.bottomPublic ?? false,
                          perspective: perspective,
                          currentTurnUserId: game?.currentTurnUserId ?? '',
                          actionDeadline: game?.hasActionDeadline() == true
                              ? game!.actionDeadline.toDateTime()
                              : null,
                          serverTime: game?.hasServerTime() == true
                              ? game!.serverTime.toDateTime()
                              : null,
                          ownerId: room.room.owner.userId,
                          dealerUserId: game?.dealerUserId ?? '',
                          onSeat:
                              room.room.status ==
                                      pb.RoomStatus.ROOM_STATUS_WAITING &&
                                  !_busy
                              ? _seat
                              : null,
                          center: _publicPlays(),
                          bottomOverlay:
                              game != null &&
                                  game.availableActions.contains('DECLARE') &&
                                  _isPlayer
                              ? _declarationChoices(game)
                              : null,
                          onPerspective: !_isPlayer && !_busy
                              ? _switchView
                              : null,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(DarkTokens.spacingS3),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: DarkTokens.spacingS5,
                        runSpacing: DarkTokens.spacingS3,
                        children: [
                          if (compact &&
                              game != null &&
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
                                level: game.trumpLevel.toString(),
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
                          if (!compact)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: DarkTokens.spacingS6,
                                top: DarkTokens.spacingS3,
                                right: DarkTokens.spacingS4,
                              ),
                              child: SizedBox(
                                width: DarkTokens.spacingS6 * 6.25,
                                height: DarkTokens.spacingS6 * 2.75,
                                child: GameTableBoard(
                                  members: room.members,
                                  perspective: perspective,
                                  currentTurnUserId:
                                      game?.currentTurnUserId ?? '',
                                  ownerId: room.room.owner.userId,
                                  dealerUserId: game?.dealerUserId ?? '',
                                  center: const SizedBox.shrink(),
                                  onSeat: null,
                                  seatOnly: true,
                                  onPerspective: !_isPlayer && !_busy
                                      ? _switchView
                                      : null,
                                  phase: game?.phase ?? '',
                                  readySeats: game?.readySeats ?? const [],
                                  actionDeadline:
                                      game?.hasActionDeadline() == true
                                      ? game!.actionDeadline.toDateTime()
                                      : null,
                                  serverTime: game?.hasServerTime() == true
                                      ? game!.serverTime.toDateTime()
                                      : null,
                                ),
                              ),
                            ),
                          if (game != null && game.dealerSeat == perspective)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: DarkTokens.spacingS3,
                                top: DarkTokens.spacingS5,
                                right: DarkTokens.spacingS3,
                              ),
                              child: Image.asset(
                                'assets/icons/ic_lighter/lighter.png',
                                key: const ValueKey('dealer-marker-main'),
                                width: DarkTokens.spacingS6,
                                height: DarkTokens.spacingS6,
                                semanticLabel: '本轮庄家',
                              ),
                            ),
                          Expanded(
                            child:
                                (game?.phase == 'hand_over' ||
                                    game?.phase == 'void' ||
                                    game?.phase == 'finished' ||
                                    game?.phase == 'awaiting_ready')
                                ? const SizedBox.shrink()
                                : TableHand(
                                    cards: game?.visibleHand ?? const [],
                                    selected: _selected,
                                    hiddenCount: game?.visibleHandCount ?? 0,
                                    level: game?.trumpLevel.toString() ?? '',
                                    trumpSuit: game?.trumpSuit ?? '',
                                    onSelect:
                                        _isPlayer && !_busy && game != null
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
            ],
          ),
        );
      },
    );
  }

  Widget _finalCenter(pb.GameSnapshot game) {
    final won = game.viewerTeam == game.settlement.winnerTeam;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${game.capturedPoints}分，${won ? '我们赢了' : '我们输了'}',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(color: DarkTokens.goldBright),
          ),
          const SizedBox(height: DarkTokens.spacingS3),
          const Text('本局底牌 · 已公开'),
          const SizedBox(height: DarkTokens.spacingS3),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: DarkTokens.spacingS2,
            children: [
              for (final card in game.bottomCards)
                SizedBox(
                  width: DarkTokens.spacingS6 * 1.5,
                  height: DarkTokens.spacingS6 * 2.5,
                  child: TableCard(
                    card: card,
                    level: game.trumpLevel.toString(),
                    trumpSuit: game.trumpSuit,
                  ),
                ),
            ],
          ),
          const SizedBox(height: DarkTokens.spacingS3),
          Text(game.phase == 'finished' ? '整盘结束' : '本局已结束，点击“准备”继续对局'),
          if (game.phase == 'hand_over')
            _waitingDecision(game, preparing: true),
          if (game.hasSettlement())
            GameSettlementPanel(game: game, onHistory: _showHistory),
        ],
      ),
    );
  }

  Widget _declarationChoices(pb.GameSnapshot game) => Container(
    key: const ValueKey('declaration-choices'),
    padding: const EdgeInsets.all(DarkTokens.spacingS3),
    decoration: BoxDecoration(
      color: DarkTokens.bgBase,
      border: Border.all(color: DarkTokens.cardBack),
      borderRadius: BorderRadius.circular(DarkTokens.radiusPanel),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('抢定 · 选择已有级牌的花色，点击抢定'),
        const SizedBox(
          height: (DarkTokens.spacingS1 + DarkTokens.spacingS2) / 2,
        ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: DarkTokens.spacingS2,
          children: [
            for (final entry in {
              'spades': DesignIconName.suitSpade,
              'hearts': DesignIconName.suitHeart,
              'clubs': DesignIconName.suitClub,
              'diamonds': DesignIconName.suitDiamond,
            }.entries)
              OutlinedButton(
                onPressed:
                    !_busy &&
                        game.visibleHand.any(
                          (card) => card.startsWith(
                            '${entry.key}:${game.trumpLevel}:',
                          ),
                        )
                    ? () => setState(() {
                        _selected
                          ..clear()
                          ..add(
                            game.visibleHand.firstWhere(
                              (card) => card.startsWith(
                                '${entry.key}:${game.trumpLevel}:',
                              ),
                            ),
                          );
                      })
                    : null,
                child: DesignIcon(
                  name: entry.value,
                  enabled:
                      !_busy &&
                      game.visibleHand.any(
                        (card) =>
                            card.startsWith('${entry.key}:${game.trumpLevel}:'),
                      ),
                ),
              ),
          ],
        ),
      ],
    ),
  );

  Widget _waitingDecision(pb.GameSnapshot game, {bool preparing = false}) {
    final waiting = _room!.members.where(
      (member) =>
          member.seatNo != 0 &&
          (preparing
              ? !game.readySeats.contains(member.seatNo)
              : member.userId == game.currentTurnUserId),
    );
    final names = waiting
        .map(
          (member) =>
              '${member.seatNo}号 ${member.profile.nickname.isEmpty ? member.userId : member.profile.nickname}',
        )
        .join('、');
    return DecoratedBox(
      key: const ValueKey('waiting-decision'),
      decoration: BoxDecoration(
        color: DarkTokens.bgBase,
        border: Border.all(color: DarkTokens.goldDark),
        borderRadius: BorderRadius.circular(DarkTokens.radiusPanel),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DarkTokens.spacingS3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              preparing
                  ? '等待准备'
                  : switch (game.phase) {
                      'counter' => '等待反主决定',
                      'playing' => '等待出牌',
                      'bury' => '等待扣底',
                      'dealing' => '正在发牌 · 等待抢定',
                      'declaration' => '等待抢定',
                      _ => '等待操作',
                    },
              style: const TextStyle(color: DarkTokens.goldBright),
            ),
            Text(
              game.phase == 'dealing' || game.phase == 'declaration'
                  ? '等待任意玩家抢定'
                  : names.isEmpty
                  ? '等待服务端确认'
                  : names,
              key: _isPlayer ? const ValueKey('play-action') : null,
              textAlign: TextAlign.center,
            ),
            if (_autoPlaying)
              const Text('托管中', key: ValueKey('autoplay-status')),
          ],
        ),
      ),
    );
  }

  Widget _publicPlays() {
    final game = _game;
    if (game == null) {
      return const Center(child: Text('等待四位玩家入座并准备'));
    }
    if (game.phase == 'void')
      return const Center(
        child: Text('流局 · 不计分', key: ValueKey('void-result')),
      );
    if (game.phase == 'awaiting_ready')
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _waitingDecision(game, preparing: true),
            Text('已有 ${game.readySeats.length} / 4 位玩家准备'),
            if (game.hasReadyDeadline())
              TurnCountdown(
                deadline: game.readyDeadline.toDateTime(),
                serverTime: game.serverTime.toDateTime(),
              ),
          ],
        ),
      );
    if (game.phase == 'hand_over' || game.phase == 'finished')
      return _finalCenter(game);
    return Stack(
      alignment: Alignment.center,
      children: [
        _waitingDecision(game),
        if (game.phase == 'dealing')
          const Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: DarkTokens.spacingS6 * 2,
              child: CardBack(),
            ),
          ),
        if (game.phase == 'declaration' && game.hasActionDeadline())
          Align(
            alignment: Alignment.topCenter,
            child: TurnCountdown(
              deadline: game.actionDeadline.toDateTime(),
              serverTime: game.serverTime.toDateTime(),
            ),
          ),
        if (game.fallbackCard.isNotEmpty)
          Align(
            alignment: Alignment.topCenter,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('无人抢定 · 底牌首张 '),
                SizedBox(
                  width: DarkTokens.spacingS5,
                  height: DarkTokens.spacingS6,
                  child: TableCard(card: game.fallbackCard),
                ),
              ],
            ),
          ),
        if (game.hasLastTrick())
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: DarkTokens.spacingS6 * 2,
              child: SingleChildScrollView(
                child: CompletedTrick(
                  key: ValueKey('${game.handId}:${game.lastTrick.trickNo}'),
                  trick: game.lastTrick,
                ),
              ),
            ),
          ),
        if (game.publicPlays.isNotEmpty)
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: DarkTokens.spacingS6 * 2.5,
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
          ),
      ],
    );
  }

  Future<void> _showHistory() async {
    final game = _game;
    if (game == null) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('对局历史'),
        content: SizedBox(
          width: MediaQuery.sizeOf(context).width * 0.8,
          child: game.history.isEmpty
              ? const Text('暂无已完成轮次')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: game.history.length,
                  itemBuilder: (_, index) {
                    final trick = game.history[index];
                    return Padding(
                      padding: const EdgeInsets.all(DarkTokens.spacingS3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '第 ${trick.roundNo} 局 · 第 ${trick.trickNo} 轮 · ${trick.winnerSeat} 号位获胜',
                          ),
                          for (final play in trick.plays)
                            Text('${play.seatNo} 号位：${play.cards.join('、')}'),
                        ],
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  String _phaseLabel(String phase) => switch (phase) {
    'awaiting_ready' => '等待准备',
    'void' => '流局',
    'dealing' => '发牌中',
    'declaration' => '定主',
    'counter' => '反主',
    'bury' => '扣底',
    'playing' => '出牌',
    'hand_over' => '本局结算',
    'finished' => '整盘结束',
    _ => phase,
  };

  Future<void> _showMembers() async {
    final room = _room!;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DarkTokens.bgPanel,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DarkTokens.radiusPanel),
        ),
        scrollable: true,
        title: const Text('房间成员'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final member in room.members)
              Padding(
                padding: const EdgeInsets.only(bottom: DarkTokens.spacingS3),
                child: Text(
                  '${member.profile.nickname.isEmpty ? member.userId : member.profile.nickname}'
                  ' · ${member.role == pb.RoomMemberRole.ROOM_MEMBER_ROLE_SPECTATOR ? '旁观' : '${member.seatNo}号位'}'
                  '${member.userId == room.room.owner.userId ? ' · 房主' : ''}'
                  '\n段位 ${member.rank} · 积分 ${member.points}'
                  '${member.seatNo == 0 ? '' : ' · 级数 ${member.team == 1 ? (_game?.teamOneLevel ?? '2') : (_game?.teamTwoLevel ?? '2')}'}',
                  key: ValueKey('room-member-${member.userId}'),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _playerActions() {
    final game = _game;
    if (game == null ||
        ((game.phase == 'finished' || game.phase == 'void') &&
            _room!.room.status == pb.RoomStatus.ROOM_STATUS_WAITING)) {
      return Wrap(
        spacing: DarkTokens.spacingS3,
        children: [
          if (_room!.room.occupiedSeats == 4)
            FilledButton(
              onPressed: _busy ? null : _start,
              child: const Text('准备'),
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
      alignment: WrapAlignment.center,
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
                'DECLARE' => '抢定',
                'COUNTER' => '反主',
                'REDECLARE' => '重新定主',
                'PASS' => game.phase == 'counter' ? '不反主' : '不定主',
                'CONTINUE' => '准备',
                _ => '托管',
              }),
            ),
        if (!{
          'awaiting_ready',
          'hand_over',
          'finished',
          'void',
        }.contains(game.phase))
          OutlinedButton(
            key: const ValueKey('autoplay-toggle'),
            onPressed: _toggleAutoPlay,
            child: Text(_autoPlaying ? '取消托管' : '托管'),
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
