import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grpc/grpc.dart';

import '../api/api_client.dart';
import '../api/request_id.dart';
import '../auth/auth_controller.dart';
import '../generated/huai/v1/api.pb.dart' as api;
import 'components/design_icon.dart';
import 'theme/app_theme.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({required this.auth, super.key});

  final AuthController auth;

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _form = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.auth.changePassword(_current.text, _next.text);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _error = switch (error) {
          GrpcError(code: StatusCode.unauthenticated) => '当前密码不正确，请重新输入。',
          GrpcError(code: StatusCode.invalidArgument) =>
            '新密码须为8到128字节且包含字母和数字。',
          _ => '修改密码失败，请检查网络后重试；若已退出，请使用新密码登录。',
        },
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: AlertDialog(
      backgroundColor: DarkTokens.bgPanel,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DarkTokens.radiusPanel),
      ),
      title: const Text('修改密码'),
      scrollable: true,
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              key: const ValueKey('password-current'),
              controller: _current,
              obscureText: true,
              decoration: const InputDecoration(labelText: '当前密码'),
              validator: (value) =>
                  value == null || value.isEmpty ? '请输入当前密码' : null,
            ),
            const SizedBox(height: DarkTokens.spacingS3),
            TextFormField(
              key: const ValueKey('password-new'),
              controller: _next,
              obscureText: true,
              decoration: const InputDecoration(labelText: '新密码'),
              validator: (value) {
                final text = value ?? '';
                final length = utf8.encode(text).length;
                return length < 8 ||
                        length > 128 ||
                        !RegExp('[A-Za-z]').hasMatch(text) ||
                        !RegExp('[0-9]').hasMatch(text)
                    ? '新密码须为8到128字节且包含字母和数字'
                    : null;
              },
            ),
            const SizedBox(height: DarkTokens.spacingS3),
            TextFormField(
              key: const ValueKey('password-confirm'),
              controller: _confirm,
              obscureText: true,
              decoration: const InputDecoration(labelText: '确认新密码'),
              validator: (value) => value != _next.text ? '两次输入的密码不一致' : null,
            ),
            if (_error != null) Text(_error!),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: Text(_busy ? '提交中…' : '确认修改'),
        ),
      ],
    ),
  );
}

String _supportError(Object error) => switch (error) {
  GrpcError(code: StatusCode.unauthenticated) => '登录状态已失效，请重新登录。',
  GrpcError(code: StatusCode.invalidArgument) => '请选择反馈类型并输入 1–2000 字的内容。',
  GrpcError(code: StatusCode.alreadyExists) => '提交编号冲突，请关闭弹框后重新提交。',
  GrpcError(code: StatusCode.failedPrecondition) => '当前阶段暂不可执行此操作。',
  _ => '服务暂不可用，请重试。',
};

class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({
    required this.client,
    required this.accessToken,
    super.key,
  });

  final ApiClient client;
  final String accessToken;

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final _body = TextEditingController();
  api.FeedbackKind _kind = api.FeedbackKind.FEEDBACK_KIND_BUG;
  ({api.FeedbackKind kind, String body, String requestId})? _pending;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final body = _body.text.trim();
    if (body.isEmpty || body.runes.length > 2000) {
      setState(() => _error = '请输入 1–2000 字的反馈内容。');
      return;
    }
    final previous = _pending;
    final requestId =
        previous != null && previous.kind == _kind && previous.body == body
        ? previous.requestId
        : createRequestId();
    _pending = (kind: _kind, body: body, requestId: requestId);
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await widget.client.submitFeedback(
        accessToken: widget.accessToken,
        kind: _kind,
        body: body,
        requestId: requestId,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) setState(() => _error = _supportError(error));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_submitting,
    child: AlertDialog(
      backgroundColor: DarkTokens.bgPanel,
      elevation: 0,
      titleTextStyle: Theme.of(context).textTheme.headlineSmall,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DarkTokens.radiusPanel),
      ),
      title: Row(
        children: [
          const Expanded(child: Text('反馈')),
          IconButton(
            tooltip: '关闭反馈',
            onPressed: _submitting ? null : () => Navigator.of(context).pop(),
            icon: DesignIcon(name: DesignIconName.close, enabled: !_submitting),
          ),
        ],
      ),
      scrollable: true,
      content: SizedBox(
        width: MediaQuery.sizeOf(context).width
            .clamp(0, DarkTokens.spacingS6 * 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<api.FeedbackKind>(
              initialValue: _kind,
              decoration: const InputDecoration(labelText: '反馈类型'),
              items: const [
                DropdownMenuItem(
                  value: api.FeedbackKind.FEEDBACK_KIND_BUG,
                  child: Text('问题'),
                ),
                DropdownMenuItem(
                  value: api.FeedbackKind.FEEDBACK_KIND_SUGGESTION,
                  child: Text('建议'),
                ),
              ],
              onChanged: _submitting
                  ? null
                  : (value) {
                      if (value != null) setState(() => _kind = value);
                    },
            ),
            const SizedBox(height: DarkTokens.spacingS4),
            TextField(
              controller: _body,
              enabled: !_submitting,
              minLines: 6,
              maxLines: 10,
              maxLength: 2000,
              decoration: const InputDecoration(
                labelText: '反馈内容',
                hintText: '请描述遇到的问题或建议',
                alignLabelWithHint: true,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: DarkTokens.spacingS2),
              Semantics(
                liveRegion: true,
                child: Text(
                  _error!,
                  style: const TextStyle(color: DarkTokens.redBright),
                ),
              ),
            ],
            const SizedBox(height: DarkTokens.spacingS4),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: Text(_submitting ? '提交中…' : '提交'),
            ),
          ],
        ),
      ),
    ),
  );
}

final _serverInfoProvider = FutureProvider.autoDispose
    .family<api.ServerInfo, ({ApiClient client, String accessToken})>(
      (ref, input) =>
          input.client.getServerInfo(accessToken: input.accessToken),
      retry: (_, _) => null,
    );

class ServerInfoDialog extends ConsumerWidget {
  const ServerInfoDialog({
    required this.client,
    required this.accessToken,
    super.key,
  });

  final ApiClient client;
  final String accessToken;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = _serverInfoProvider((
      client: client,
      accessToken: accessToken,
    ));
    return AlertDialog(
      backgroundColor: DarkTokens.bgPanel,
      elevation: 0,
      titleTextStyle: Theme.of(context).textTheme.headlineSmall,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DarkTokens.radiusPanel),
      ),
      title: const Text('关于淮安80分'),
      scrollable: true,
      content: ref
          .watch(provider)
          .when(
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_supportError(error)),
                TextButton(
                  onPressed: () => ref.invalidate(provider),
                  child: const Text('重试'),
                ),
              ],
            ),
            data: (info) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText('软件版本：${info.version}'),
                const SizedBox(height: DarkTokens.spacingS3),
                SelectableText('Commit ID：${info.commitId}'),
                const SizedBox(height: DarkTokens.spacingS4),
                const Text('更新记录'),
                const SizedBox(height: DarkTokens.spacingS2),
                SelectableText(
                  info.changelist.isEmpty ? '开发构建，未固化更新记录。' : info.changelist,
                ),
              ],
            ),
          ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
      ],
    );
  }
}
