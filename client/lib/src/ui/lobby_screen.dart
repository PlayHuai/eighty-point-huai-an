import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grpc/grpc.dart';

import '../api/lobby_models.dart';
import '../auth/auth_controller.dart';
import 'client_providers.dart';
import 'components/design_icon.dart';
import 'responsive_breakpoints.dart';
import 'theme/app_theme.dart';

final lobbyHallsProvider = FutureProvider<List<LobbyHall>>((ref) {
  final session = ref.watch(authControllerProvider).session;
  if (session == null) return Future.value(const <LobbyHall>[]);
  return ref
      .watch(apiClientProvider)
      .listHalls(accessToken: session.accessToken);
});

final lobbyRoomsProvider = FutureProvider.family<List<LobbyRoom>, String>((
  ref,
  hallId,
) {
  final session = ref.watch(authControllerProvider).session;
  if (session == null) return Future.value(const <LobbyRoom>[]);
  return ref
      .watch(apiClientProvider)
      .listRooms(accessToken: session.accessToken, hallId: hallId);
});

class LobbyScreen extends ConsumerStatefulWidget {
  const LobbyScreen({
    required this.auth,
    required this.nickname,
    super.key,
  });

  final AuthController auth;
  final String nickname;

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  String? _selectedHallId;
  String _roomQuery = '';
  bool _isJoining = false;
  bool _isCreating = false;

  Future<void> _joinRoom(LobbyRoom room) async {
    final session = widget.auth.session;
    if (session == null || _isJoining) return;
    if (room.hasPassword) {
      await _showJoinByCodeDialog();
      return;
    }
    setState(() => _isJoining = true);
    try {
      final joined = await ref.read(apiClientProvider).joinRoom(
        accessToken: session.accessToken,
        roomId: room.id,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已加入 ${joined.name}（房间号 ${joined.id}）')),
      );
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  Future<void> _joinByCode(String code, String password) async {
    final session = widget.auth.session;
    if (session == null || _isJoining) return;
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入房间号。')),
      );
      return;
    }
    setState(() => _isJoining = true);
    try {
      final room = await ref.read(apiClientProvider).joinByCode(
        accessToken: session.accessToken,
        roomCode: code,
        password: password,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已加入 ${room.name}（房间号 ${room.id}）')),
      );
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  Future<void> _createRoom(String hallId, String name, String password) async {
    final session = widget.auth.session;
    if (session == null || _isCreating) return;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入房间名称。')),
      );
      return;
    }
    setState(() => _isCreating = true);
    try {
      final room = await ref.read(apiClientProvider).createRoom(
        accessToken: session.accessToken,
        hallId: hallId,
        name: name,
        password: password,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ref.invalidate(lobbyRoomsProvider(hallId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('房间已创建（房间号 ${room.id}）')),
      );
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  void _showError(Object error) {
    if (!mounted) return;
    final message = switch (error) {
      GrpcError(code: StatusCode.failedPrecondition) => '当前阶段暂不可执行此操作。',
      GrpcError(code: StatusCode.unauthenticated) => '登录状态已失效，请重新登录。',
      GrpcError(code: StatusCode.permissionDenied) => '没有执行此操作的权限。',
      _ => '操作失败，请检查网络后重试。',
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _showJoinByCodeDialog({String initialCode = ''}) async {
    final codeController = TextEditingController(text: initialCode);
    final passwordController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('通过房间号加入'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeController,
              decoration: const InputDecoration(labelText: '房间号'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: DarkTokens.spacingS3),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: '房间密码（如需要）'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: _isJoining
                ? null
                : () => _joinByCode(
                    codeController.text.trim(),
                    passwordController.text,
                  ),
            child: const Text('加入'),
          ),
        ],
      ),
    );
    codeController.dispose();
    passwordController.dispose();
  }

  Future<void> _showCreateRoomDialog(String hallId) async {
    final nameController = TextEditingController();
    final passwordController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('创建房间'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              maxLength: 32,
              decoration: const InputDecoration(labelText: '房间名称'),
            ),
            const SizedBox(height: DarkTokens.spacingS3),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: '房间密码（可选）'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: _isCreating
                ? null
                : () => _createRoom(
                    hallId,
                    nameController.text.trim(),
                    passwordController.text,
                  ),
            child: const Text('创建'),
          ),
        ],
      ),
    );
    nameController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Row(
        children: [
          const AppIcon(size: DarkTokens.spacingS6),
          const SizedBox(width: DarkTokens.spacingS2),
          Expanded(
            child: Text(
              '淮安80分 · 游戏大厅',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
      actions: [
        if (MediaQuery.sizeOf(context).width >
            ResponsiveBreakpoints.compactMaxWidth)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DarkTokens.spacingS3,
            ),
            child: Center(child: Text(widget.nickname)),
          ),
        IconButton(
          tooltip: '退出登录',
          onPressed: widget.auth.isLoading ? null : widget.auth.logout,
          icon: const Icon(Icons.logout),
        ),
      ],
    ),
    body: ResponsiveLayoutBuilder(
      builder: (context, constraints, size) =>
          _buildLobby(size, constraints.maxWidth),
    ),
  );

  Widget _buildLobby(ResponsiveSize size, double availableWidth) => Padding(
    padding: const EdgeInsets.all(DarkTokens.spacingS4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '游戏大厅',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            IconButton(
              tooltip: '刷新',
              onPressed: () {
                ref.invalidate(lobbyHallsProvider);
                final hallId = _selectedHallId;
                if (hallId != null) ref.invalidate(lobbyRoomsProvider(hallId));
              },
              icon: const DesignIcon(
                name: DesignIconName.refresh,
                enabled: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: DarkTokens.spacingS3),
        Expanded(
          child: ref.watch(lobbyHallsProvider).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => _loadError(
              onRetry: () => ref.invalidate(lobbyHallsProvider),
            ),
            data: (halls) {
              if (halls.isEmpty) return const Center(child: Text('暂无可进入的大厅'));
              final selectedHall = halls.firstWhere(
                (hall) => hall.id == _selectedHallId,
                orElse: () => halls.first,
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: DarkTokens.spacingS2,
                    runSpacing: DarkTokens.spacingS2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      for (final hall in halls)
                        ChoiceChip(
                          label: Text(hall.name),
                          selected: hall.id == selectedHall.id,
                          onSelected: (_) =>
                              setState(() => _selectedHallId = hall.id),
                        ),
                      OutlinedButton.icon(
                        onPressed: _showJoinByCodeDialog,
                        icon: const DesignIcon(
                          name: DesignIconName.search,
                          enabled: true,
                          size: DarkTokens.spacingS4,
                        ),
                        label: const Text('房间号加入'),
                      ),
                      FilledButton.icon(
                        onPressed: _isCreating
                            ? null
                            : () => _showCreateRoomDialog(selectedHall.id),
                        icon: const Icon(Icons.add),
                        label: const Text('创建房间'),
                      ),
                    ],
                  ),
                  const SizedBox(height: DarkTokens.spacingS4),
                  Wrap(
                    spacing: DarkTokens.spacingS3,
                    children: [
                      Text(
                        '积分 ${selectedHall.minimumPoints}–${selectedHall.maximumPoints == 0 ? '不限' : selectedHall.maximumPoints}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '大厅系数 ${selectedHall.multiplier}×',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: DarkTokens.spacingS3),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: '搜索房间号或名称',
                      prefixIcon: DesignIcon(
                        name: DesignIconName.search,
                        enabled: true,
                      ),
                    ),
                    onChanged: (value) => setState(() => _roomQuery = value),
                  ),
                  const SizedBox(height: DarkTokens.spacingS3),
                  Expanded(
                    child: ref.watch(lobbyRoomsProvider(selectedHall.id)).when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (_, _) => _loadError(
                        onRetry: () =>
                            ref.invalidate(lobbyRoomsProvider(selectedHall.id)),
                      ),
                      data: (rooms) =>
                          _buildRooms(rooms, size, availableWidth),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    ),
  );

  Widget _buildRooms(
    List<LobbyRoom> rooms,
    ResponsiveSize size,
    double availableWidth,
  ) {
    final normalizedQuery = _roomQuery.trim().toLowerCase();
    final filteredRooms = rooms.where((room) {
      return normalizedQuery.isEmpty ||
          room.name.toLowerCase().contains(normalizedQuery) ||
          room.id.toLowerCase().contains(normalizedQuery);
    }).toList(growable: false);
    if (filteredRooms.isEmpty) {
      return Center(
        child: Text(rooms.isEmpty ? '当前大厅暂无房间' : '没有匹配的房间'),
      );
    }
    final columnCount = switch (size) {
      ResponsiveSize.compact => 1,
      ResponsiveSize.medium => 2,
      ResponsiveSize.expanded => 3,
    };
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: availableWidth / columnCount,
        childAspectRatio: 1.75,
        crossAxisSpacing: DarkTokens.spacingS3,
        mainAxisSpacing: DarkTokens.spacingS3,
      ),
      itemCount: filteredRooms.length,
      itemBuilder: (context, index) {
        final room = filteredRooms[index];
        final canJoin = room.status == LobbyRoomStatus.waiting &&
            room.occupiedSeats < room.capacity;
        return Card(
          color: DarkTokens.bgCard,
          child: Padding(
            padding: const EdgeInsets.all(DarkTokens.spacingS3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        room.name.isEmpty ? '房间 ${room.id}' : room.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (room.hasPassword)
                      const DesignIcon(
                        name: DesignIconName.passwordRoom,
                        enabled: true,
                        size: DarkTokens.spacingS4,
                      ),
                  ],
                ),
                const SizedBox(height: DarkTokens.spacingS2),
                Text('房间号 ${room.id}'),
                const SizedBox(height: DarkTokens.spacingS1),
                Text(
                  '${room.occupiedSeats}/${room.capacity} 人  ·  ${_statusLabel(room.status)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: canJoin && !_isJoining
                        ? () => _joinRoom(room)
                        : null,
                    child: Text(_isJoining ? '加入中…' : '加入'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _loadError({required VoidCallback onRetry}) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('加载失败，请检查网络后重试。'),
        const SizedBox(height: DarkTokens.spacingS2),
        TextButton(onPressed: onRetry, child: const Text('重试')),
      ],
    ),
  );

  String _statusLabel(LobbyRoomStatus status) => switch (status) {
    LobbyRoomStatus.waiting => '等待中',
    LobbyRoomStatus.playing => '游戏中',
    LobbyRoomStatus.closed => '已关闭',
    LobbyRoomStatus.unspecified => '状态未知',
  };
}
