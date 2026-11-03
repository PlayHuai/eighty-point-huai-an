import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart' hide ClientChannel;
import 'package:grpc/service_api.dart' show ClientChannel;

import '../api/channel_factory.dart';
import '../api/request_id.dart';
import '../auth/auth_controller.dart';
import '../generated/huai/v1/api.pbgrpc.dart' as pb;
import '../logging/app_log.dart';
import '../logging/rpc_logging.dart';
import 'client_providers.dart';
import 'theme/app_theme.dart';

class SettingsDialog extends ConsumerStatefulWidget {
  const SettingsDialog({required this.auth, super.key});
  final AuthController auth;
  @override
  ConsumerState<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends ConsumerState<SettingsDialog> {
  ClientChannel? _channel;
  pb.PlayerSettings? _settings;
  bool _saving = false;
  String? _error;
  ({bool show, String id, Int64 version})? _pending;
  late pb.PlayerServiceClient _client;
  CallOptions get _options => CallOptions(
    metadata: {'authorization': 'Bearer ${widget.auth.session!.accessToken}'},
    timeout: const Duration(seconds: 15),
  );
  @override
  void initState() {
    super.initState();
    final endpoint = ref.read(apiEndpointProvider);
    if (endpoint == null) {
      _error = '未配置服务端地址。';
      return;
    }
    _channel = createClientChannel(endpoint);
    _client = pb.PlayerServiceClient(
      _channel!,
      interceptors: [RpcLoggingInterceptor()],
    );
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final settings = await _client.getSettings(pb.Empty(), options: _options);
      if (mounted) setState(() => _settings = settings);
    } catch (error, stack) {
      AppLog.failure('settings.load', error, stack);
      if (mounted) setState(() => _error = '读取设置失败，请重试。');
    }
  }

  Future<void> _save(bool value) async {
    if (_saving || _settings == null) return;
    final previous = _pending;
    final pending = previous != null && previous.show == value
        ? previous
        : (show: value, id: createRequestId(), version: _settings!.version);
    _pending = pending;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final settings = await _client.updateSettings(
        pb.UpdateSettingsRequest(
          showHandToSpectators: value,
          requestId: pending.id,
          expectedVersion: pending.version,
        ),
        options: _options,
      );
      if (mounted)
        setState(() {
          _settings = settings;
          _pending = null;
        });
    } on GrpcError catch (error) {
      if (mounted)
        setState(
          () => _error = error.code == StatusCode.aborted
              ? '设置已在其他客户端更改，请重新读取。'
              : '保存设置失败，请重试。',
        );
      if (error.code == StatusCode.aborted) {
        _pending = null;
        await _load();
      }
    } catch (error, stack) {
      AppLog.failure('settings.save', error, stack);
      if (mounted) setState(() => _error = '保存设置失败，请重试。');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    unawaited(_channel?.shutdown());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    key: const ValueKey('global-settings-dialog'),
    title: const Text('全局设置'),
    content: SizedBox(
      width: MediaQuery.sizeOf(context).width
          .clamp(0, DarkTokens.spacingS6 * 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_settings == null && _error == null)
            const CircularProgressIndicator(),
          if (_settings != null)
            SwitchListTile(
              key: const ValueKey('global-show-hand'),
              title: const Text('向旁观者展示手牌'),
              subtitle: const Text('账户全局设置，立即在所有房间生效；其他玩家不能查看你的手牌。'),
              value: _settings!.showHandToSpectators,
              onChanged: _saving ? null : _save,
            ),
          if (_error != null)
            Text(_error!, style: const TextStyle(color: DarkTokens.redBright)),
          if (_error != null)
            TextButton(
              onPressed: _saving ? null : _load,
              child: const Text('重新读取'),
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context),
        child: const Text('关闭'),
      ),
    ],
  );
}
