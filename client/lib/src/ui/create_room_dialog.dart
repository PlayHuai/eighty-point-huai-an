import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/lobby_models.dart';
import '../api/player_models.dart';
import 'components/design_icon.dart';
import 'theme/app_theme.dart';

class CreateRoomDialog extends StatefulWidget {
  const CreateRoomDialog({
    required this.hall,
    required this.statistics,
    required this.onRetryStatistics,
    required this.onCreate,
    super.key,
  });

  final LobbyHall hall;
  final AsyncValue<PlayerStatistics?> statistics;
  final VoidCallback onRetryStatistics;
  final Future<void> Function(
    String name,
    String password,
    bool allowSpectators,
    int minimumPoints,
  )
  onCreate;

  @override
  State<CreateRoomDialog> createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends State<CreateRoomDialog> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _minimumPointsController = TextEditingController(text: '0');
  bool _privateRoom = false;
  bool _allowSpectators = false;
  bool _submitting = false;

  bool get _isFriendRoom => widget.hall.id == friendRoomHallId;

  String? get _pointsError {
    if (_isFriendRoom) return null;
    final minimum = int.tryParse(_minimumPointsController.text);
    if (minimum == null || minimum < 0) {
      return '最低准入积分必须是非负整数。';
    }
    if (widget.hall.maximumPoints > 0 && minimum > widget.hall.maximumPoints) {
      return '最低准入积分不能超过当前大厅上限（${widget.hall.maximumPoints} 分）。';
    }
    final statistics = widget.statistics.asData?.value;
    if (statistics != null && statistics.points < minimum) {
      return '当前积分 ${statistics.points}，不满足 $minimum 的门槛要求。';
    }
    return null;
  }

  bool get _canCreate =>
      !_submitting &&
      _nameController.text.trim().isNotEmpty &&
      (_isFriendRoom || !_privateRoom || _passwordController.text.isNotEmpty) &&
      _pointsError == null;

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _minimumPointsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_canCreate) return;
    setState(() => _submitting = true);
    try {
      await widget.onCreate(
        _nameController.text.trim(),
        !_isFriendRoom && _privateRoom ? _passwordController.text : '',
        !_isFriendRoom && _allowSpectators,
        _isFriendRoom ? 0 : int.parse(_minimumPointsController.text),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _field(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: DarkTokens.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: DarkTokens.spacingS2),
      child,
    ],
  );

  InputDecoration _decoration(String hint) => InputDecoration(
    hintText: hint,
    fillColor: DarkTokens.bgPanel,
    contentPadding: const EdgeInsets.all(DarkTokens.spacingS3),
  );

  Widget _toggle({
    required Key key,
    required bool value,
    required String label,
    required ValueChanged<bool> onChanged,
  }) => Container(
    decoration: BoxDecoration(
      border: Border.all(color: DarkTokens.cardBack),
      borderRadius: BorderRadius.circular(DarkTokens.radiusButton),
    ),
    padding: const EdgeInsets.symmetric(horizontal: DarkTokens.spacingS3),
    child: Row(
      children: [
        Expanded(child: Text(value ? '已开启' : '未开启')),
        Semantics(
          label: label,
          child: Switch(
            key: key,
            value: value,
            onChanged: _submitting ? null : onChanged,
            thumbColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.disabled)
                  ? DarkTokens.textDisabled
                  : DarkTokens.cardFace,
            ),
            trackColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? DarkTokens.goldPrimary
                  : DarkTokens.cardBack,
            ),
            trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final pointsError = _pointsError;
    final padding = MediaQuery.sizeOf(context).width < 600
        ? DarkTokens.spacingS4
        : DarkTokens.spacingS5;
    return PopScope(
      canPop: !_submitting,
      child: AlertDialog(
        key: const ValueKey('create-room-dialog'),
        backgroundColor: DarkTokens.bgPanel,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DarkTokens.radiusPanel),
          side: const BorderSide(color: DarkTokens.goldPrimary),
        ),
        constraints: const BoxConstraints(maxWidth: 520),
        insetPadding: EdgeInsets.all(padding),
        scrollable: true,
        titlePadding: EdgeInsets.zero,
        title: Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: DarkTokens.cardBack)),
          ),
          padding: EdgeInsets.all(padding),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '创建房间',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              IconButton(
                tooltip: '关闭',
                constraints: const BoxConstraints.tightFor(
                  width: DarkTokens.spacingS6,
                  height: DarkTokens.spacingS6,
                ),
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                padding: EdgeInsets.zero,
                onPressed: _submitting
                    ? null
                    : () => Navigator.of(context).pop(),
                icon: DesignIcon(
                  name: DesignIconName.close,
                  enabled: !_submitting,
                  size: DarkTokens.spacingS4,
                ),
              ),
            ],
          ),
        ),
        contentPadding: EdgeInsets.all(padding),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: DarkTokens.spacingS5,
            children: [
              _field(
                '房间名',
                TextField(
                  key: const ValueKey('create-room-name'),
                  controller: _nameController,
                  enabled: !_submitting,
                  maxLength: 32,
                  decoration: _decoration('输入房间名称').copyWith(counterText: ''),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              if (!_isFriendRoom) ...[
                _field(
                  '私密房间',
                  _toggle(
                    key: const ValueKey('create-room-private'),
                    value: _privateRoom,
                    label: '私密房间',
                    onChanged: (value) => setState(() => _privateRoom = value),
                  ),
                ),
                if (_privateRoom)
                  _field(
                    '入场密码',
                    TextField(
                      key: const ValueKey('create-room-password'),
                      controller: _passwordController,
                      enabled: !_submitting,
                      obscureText: true,
                      decoration: _decoration('请输入入场密码'),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                _field(
                  '最低准入积分门槛',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        key: const ValueKey('create-room-minimum-points'),
                        controller: _minimumPointsController,
                        enabled: !_submitting,
                        keyboardType: TextInputType.number,
                        decoration: _decoration('最低准入积分'),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: DarkTokens.spacingS2),
                      Text(
                        widget.hall.maximumPoints > 0
                            ? '房间门槛须 ≤ 当前大厅上限：${widget.hall.maximumPoints} 分。'
                            : '当前大厅无积分上限。',
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: DarkTokens.goldPrimary),
                      ),
                    ],
                  ),
                ),
                _field(
                  '是否允许观战',
                  _toggle(
                    key: const ValueKey('create-room-spectators'),
                    value: _allowSpectators,
                    label: '允许观战',
                    onChanged: (value) =>
                        setState(() => _allowSpectators = value),
                  ),
                ),
                if (pointsError != null)
                  Text(
                    pointsError,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: DarkTokens.redBright),
                  ),
                if (widget.statistics.hasError)
                  TextButton(
                    onPressed: widget.onRetryStatistics,
                    child: const Text('当前积分加载失败，点击重试；准入以服务端为准。'),
                  ),
              ],
            ],
          ),
        ),
        actionsPadding: EdgeInsets.zero,
        actions: [
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: DarkTokens.cardBack)),
            ),
            padding: EdgeInsets.all(padding),
            child: Row(
              spacing: DarkTokens.spacingS3,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _submitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, DarkTokens.spacingS5 * 2),
                      foregroundColor: DarkTokens.textSecondary,
                      side: const BorderSide(color: DarkTokens.cardBack),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          DarkTokens.radiusButton,
                        ),
                      ),
                    ),
                    child: const Text('取消'),
                  ),
                ),
                Expanded(
                  child: FilledButton(
                    onPressed: _canCreate ? _submit : null,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, DarkTokens.spacingS5 * 2),
                      disabledBackgroundColor: DarkTokens.goldPrimary
                          .withValues(alpha: 0.4),
                      disabledForegroundColor: DarkTokens.bgBase,
                    ),
                    child: Text(_submitting ? '创建中…' : '创建'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
