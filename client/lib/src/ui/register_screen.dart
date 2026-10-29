import 'dart:convert';

import 'package:flutter/material.dart';

import '../auth/auth_controller.dart';
import 'components/design_icon.dart';
import 'theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({required this.auth, super.key});

  final AuthController auth;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _account = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  final _nickname = TextEditingController();
  var _passwordVisible = false;
  var _confirmationVisible = false;
  var _selectedAvatar = 0;

  @override
  void dispose() {
    _account.dispose();
    _password.dispose();
    _confirmation.dispose();
    _nickname.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await widget.auth.register(
      _account.text.trim(),
      _password.text,
      _nickname.text.trim(),
      avatarUrl: _avatarOptions[_selectedAvatar].assetPath,
    );
    if (success && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.auth,
    builder: (context, _) => Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Padding(
                        padding: const EdgeInsets.all(DarkTokens.spacingS5),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                        const AppIcon(size: DarkTokens.spacingS6),
                        const SizedBox(height: DarkTokens.spacingS3),
                        Text(
                          '淮安80分',
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: DarkTokens.spacingS2),
                        Text(
                          '注册账号并开始使用',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: DarkTokens.spacingS5),
                        TextFormField(
                          key: const ValueKey('register-account-field'),
                          controller: _account,
                          decoration: const InputDecoration(
                            labelText: '请输入账号',
                            prefixIcon: DesignIcon(
                              name: DesignIconName.login,
                              enabled: true,
                              size: 24,
                            ),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? '请输入账号'
                              : null,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: DarkTokens.spacingS2),
                        TextFormField(
                          key: const ValueKey('register-password-field'),
                          controller: _password,
                          obscureText: !_passwordVisible,
                          decoration: InputDecoration(
                            labelText: '请输入密码（至少 8 位，含字母和数字）',
                            prefixIcon: const DesignIcon(
                              name: DesignIconName.locked,
                              enabled: true,
                              size: 24,
                            ),
                            suffixIcon: TextButton(
                              onPressed: () => setState(
                                () => _passwordVisible = !_passwordVisible,
                              ),
                              child: Text(_passwordVisible ? '隐藏' : '显示'),
                            ),
                          ),
                          validator: _validatePassword,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: DarkTokens.spacingS2),
                        TextFormField(
                          key: const ValueKey('register-confirm-password-field'),
                          controller: _confirmation,
                          obscureText: !_confirmationVisible,
                          decoration: InputDecoration(
                            labelText: '请再次输入密码',
                            prefixIcon: const DesignIcon(
                              name: DesignIconName.locked,
                              enabled: true,
                              size: 24,
                            ),
                            suffixIcon: TextButton(
                              onPressed: () => setState(
                                () => _confirmationVisible =
                                    !_confirmationVisible,
                              ),
                              child: Text(_confirmationVisible ? '隐藏' : '显示'),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请再次输入密码';
                            }
                            return value != _password.text
                                ? '两次输入的密码不一致'
                                : null;
                          },
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: DarkTokens.spacingS2),
                        TextFormField(
                          key: const ValueKey('register-nickname-field'),
                          controller: _nickname,
                          decoration: const InputDecoration(
                            labelText: '请输入昵称',
                            prefixIcon: DesignIcon(
                              name: DesignIconName.login,
                              enabled: true,
                              size: 24,
                            ),
                          ),
                          validator: (value) {
                            final nickname = value?.trim() ?? '';
                            if (nickname.isEmpty) return '请输入昵称';
                            if (nickname.runes.length > 64) {
                              return '昵称不能超过 64 个字符';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: DarkTokens.spacingS3),
                        Text(
                          '选择头像',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: DarkTokens.spacingS2),
                        Wrap(
                          spacing: DarkTokens.spacingS3,
                          runSpacing: DarkTokens.spacingS2,
                          children: [
                            for (var index = 0;
                                index < _avatarOptions.length;
                                index++)
                              _AvatarChoice(
                                key: ValueKey(
                                  'register-avatar-${_avatarOptions[index].id}',
                                ),
                                option: _avatarOptions[index],
                                selected: _selectedAvatar == index,
                                onTap: () =>
                                    setState(() => _selectedAvatar = index),
                              ),
                          ],
                        ),
                        if (widget.auth.error case final error?)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: DarkTokens.spacingS3,
                            ),
                            child: Text(
                              error,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        const SizedBox(height: DarkTokens.spacingS4),
                        FilledButton(
                          onPressed: widget.auth.isLoading ? null : _submit,
                          child: const Text('注册'),
                        ),
                        TextButton(
                          onPressed: widget.auth.isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Text('已有账号？返回登录'),
                        ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (widget.auth.isLoading) ...[
            const ModalBarrier(dismissible: false),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    ),
  );

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return '请输入密码';
    final length = utf8.encode(value).length;
    if (length < 8 || length > 128) {
      return '密码长度需为 8–128 位';
    }
    if (!RegExp('[A-Za-z]').hasMatch(value) ||
        !RegExp('[0-9]').hasMatch(value)) {
      return '密码需同时包含字母和数字';
    }
    return null;
  }
}

class _AvatarChoice extends StatelessWidget {
  const _AvatarChoice({
    required this.option,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final _RegisterAvatar option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: '头像：${option.label}',
    child: InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        padding: const EdgeInsets.all(DarkTokens.spacingS2),
        decoration: BoxDecoration(
          color: DarkTokens.bgBase,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? DarkTokens.goldPrimary : DarkTokens.textSecondary,
            width: selected ? 2 : 1,
          ),
        ),
        child: DesignIcon(
          name: option.icon,
          enabled: true,
          size: DarkTokens.fontSizeL3,
          semanticLabel: option.label,
        ),
      ),
    ),
  );
}

class _RegisterAvatar {
  const _RegisterAvatar({
    required this.id,
    required this.label,
    required this.icon,
    required this.assetPath,
  });

  final String id;
  final String label;
  final DesignIconName icon;
  final String assetPath;
}

const _avatarOptions = [
  _RegisterAvatar(
    id: 'player',
    label: '玩家',
    icon: DesignIconName.login,
    assetPath: 'assets/icons/ic_login/32xenabled.svg',
  ),
  _RegisterAvatar(
    id: 'host',
    label: '庄家',
    icon: DesignIconName.host,
    assetPath: 'assets/icons/ic_host/state=enabled.svg',
  ),
  _RegisterAvatar(
    id: 'locked',
    label: '守护',
    icon: DesignIconName.locked,
    assetPath: 'assets/icons/ic_locked/state=enabled.svg',
  ),
  _RegisterAvatar(
    id: 'watching',
    label: '观战',
    icon: DesignIconName.watching,
    assetPath: 'assets/icons/ic_watching/state=enabled.svg',
  ),
];
