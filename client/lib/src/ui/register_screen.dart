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
  var _avatarIndex = 0;
  var _passwordVisible = false;
  var _confirmationVisible = false;

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
    final registered = await widget.auth.register(
      _account.text.trim(),
      _password.text,
      _nickname.text.trim(),
      _avatars[_avatarIndex].value,
    );
    if (registered && mounted) {
      if (widget.auth.error case final warning?) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(warning)),
        );
      }
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(DarkTokens.spacingS5),
                child: AnimatedBuilder(
                  animation: widget.auth,
                  builder: (context, _) => AbsorbPointer(
                    absorbing: widget.auth.isLoading,
                    child: Container(
                      padding: const EdgeInsets.all(
                        DarkTokens.spacingS6 + DarkTokens.spacingS2,
                      ),
                      decoration: BoxDecoration(
                        color: DarkTokens.bgPanel,
                        border: Border.all(color: DarkTokens.goldPrimary),
                        borderRadius: BorderRadius.circular(
                          DarkTokens.radiusPanel,
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const AppIcon(
                              size: DarkTokens.spacingS6 + DarkTokens.spacingS5,
                            ),
                            const SizedBox(height: DarkTokens.spacingS3),
                            Text(
                              '淮安80分',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(fontSize: DarkTokens.fontSizeL1),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: DarkTokens.spacingS1),
                            Text(
                              '注册账号并开始使用',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: DarkTokens.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: DarkTokens.spacingS5),
                            TextFormField(
                              key: const ValueKey('register-account-field'),
                              controller: _account,
                              decoration: const InputDecoration(
                                labelText: '账号',
                                hintText: '请输入账号',
                                prefixIcon: DesignIcon(
                                  name: DesignIconName.login,
                                  enabled: true,
                                  size: DarkTokens.spacingS4 +
                                      DarkTokens.spacingS1,
                                ),
                              ),
                              validator: _validateAccount,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: DarkTokens.spacingS3),
                            TextFormField(
                              key: const ValueKey('register-password-field'),
                              controller: _password,
                              obscureText: !_passwordVisible,
                              decoration: InputDecoration(
                                labelText: '请输入密码（≥8位含字母数字）',
                                prefixIcon: const DesignIcon(
                                  name: DesignIconName.locked,
                                  enabled: true,
                                  size: DarkTokens.spacingS4 +
                                      DarkTokens.spacingS1,
                                ),
                                suffixIcon: IconButton(
                                  tooltip: _passwordVisible ? '隐藏密码' : '显示密码',
                                  onPressed: () => setState(
                                    () => _passwordVisible = !_passwordVisible,
                                  ),
                                  icon: DesignIcon(
                                    name: DesignIconName.watching,
                                    enabled: _passwordVisible,
                                    size: DarkTokens.spacingS4 +
                                        DarkTokens.spacingS1,
                                  ),
                                ),
                              ),
                              validator: _validatePassword,
                              onChanged: (_) => setState(() {}),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: DarkTokens.spacingS2),
                            _PasswordStrength(password: _password.text),
                            const SizedBox(height: DarkTokens.spacingS3),
                            TextFormField(
                              key: const ValueKey(
                                'register-confirm-password-field',
                              ),
                              controller: _confirmation,
                              obscureText: !_confirmationVisible,
                              decoration: InputDecoration(
                                labelText: '确认密码',
                                hintText: '请再次输入密码',
                                prefixIcon: const DesignIcon(
                                  name: DesignIconName.locked,
                                  enabled: true,
                                  size: DarkTokens.spacingS4 +
                                      DarkTokens.spacingS1,
                                ),
                                suffixIcon: IconButton(
                                  tooltip: _confirmationVisible
                                      ? '隐藏确认密码'
                                      : '显示确认密码',
                                  onPressed: () => setState(
                                    () => _confirmationVisible =
                                        !_confirmationVisible,
                                  ),
                                  icon: DesignIcon(
                                    name: DesignIconName.watching,
                                    enabled: _confirmationVisible,
                                    size: DarkTokens.spacingS4 +
                                        DarkTokens.spacingS1,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '请确认密码';
                                }
                                if (value != _password.text) {
                                  return '两次输入的密码不一致';
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: DarkTokens.spacingS3),
                            TextFormField(
                              key: const ValueKey('register-nickname-field'),
                              controller: _nickname,
                              decoration: const InputDecoration(
                                labelText: '昵称',
                                hintText: '请输入昵称',
                                prefixIcon: DesignIcon(
                                  name: DesignIconName.login,
                                  enabled: true,
                                  size: DarkTokens.spacingS4 +
                                      DarkTokens.spacingS1,
                                ),
                              ),
                              validator: (value) {
                                final nickname = value?.trim() ?? '';
                                if (nickname.isEmpty) return '昵称不能为空';
                                if (nickname.runes.length > 64) {
                                  return '昵称不能超过64个字符';
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: DarkTokens.spacingS3),
                            Text(
                              '选择头像',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: DarkTokens.textSecondary),
                            ),
                            const SizedBox(height: DarkTokens.spacingS2),
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              spacing: DarkTokens.spacingS2,
                              runSpacing: DarkTokens.spacingS2,
                              children: [
                                for (var index = 0;
                                    index < _avatars.length;
                                    index++)
                                  _buildAvatarOption(index),
                              ],
                            ),
                            if (widget.auth.error case final error?) ...[
                              const SizedBox(height: DarkTokens.spacingS3),
                              Text(
                                error,
                                key: const ValueKey('register-error'),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ],
                            const SizedBox(height: DarkTokens.spacingS4),
                            SizedBox(
                              height: DarkTokens.spacingS5 * 2 +
                                  DarkTokens.spacingS1,
                              child: FilledButton(
                                onPressed: widget.auth.isLoading ? null : _submit,
                                child: widget.auth.isLoading
                                    ? const CircularProgressIndicator()
                                    : const Text('注册'),
                              ),
                            ),
                            TextButton(
                              onPressed: widget.auth.isLoading
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              child: const Text('已有账号，去登录'),
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
      ),
    ),
  );

  Widget _buildAvatarOption(int index) {
    final avatar = _avatars[index];
    final selected = index == _avatarIndex;
    return Semantics(
      button: true,
      selected: selected,
      label: '头像选项 ${index + 1}',
      child: InkWell(
        key: ValueKey('register-avatar-$index'),
        borderRadius: BorderRadius.circular(DarkTokens.radiusBadge),
        onTap: () => setState(() => _avatarIndex = index),
        child: Container(
          width: DarkTokens.spacingS6 * 2,
          height: DarkTokens.spacingS6 * 2,
          decoration: BoxDecoration(
            color: DarkTokens.bgCard,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? DarkTokens.goldPrimary : DarkTokens.goldDark,
              width: selected
                  ? DarkTokens.spacingS1 / 2
                  : DarkTokens.spacingS1 / 4,
            ),
          ),
          child: Center(
            child: Container(
              width: DarkTokens.spacingS6 + DarkTokens.spacingS5,
              height: DarkTokens.spacingS6 + DarkTokens.spacingS5,
              decoration: const BoxDecoration(
                color: DarkTokens.bgBase,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: DesignIcon(
                  name: avatar.icon,
                  enabled: selected,
                  size: DarkTokens.spacingS5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _validateAccount(String? value) {
    final account = value?.trim() ?? '';
    if (account.isEmpty) return '账号不能为空';
    if (account.contains('@')) {
      final parts = account.split('@');
      if (parts.length != 2 ||
          parts.any((part) => part.isEmpty || part.contains(RegExp(r'\s'))) ||
          account.length > 254) {
        return '请输入有效账号';
      }
    } else if (account.runes.length < 3 ||
        account.runes.length > 64 ||
        account.contains(RegExp(r'\s'))) {
      return '账号须为3到64个字符';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.runes.length < 8 ||
        password.runes.length > 128 ||
        !RegExp('[A-Za-z]').hasMatch(password) ||
        !RegExp('[0-9]').hasMatch(password)) {
      return '密码至少8位且需包含字母和数字';
    }
    return null;
  }
}

class _RegisterAvatar {
  const _RegisterAvatar(this.value, this.icon);

  final String value;
  final DesignIconName icon;
}

const _avatars = [
  _RegisterAvatar('huai-avatar://login', DesignIconName.login),
  _RegisterAvatar('huai-avatar://host', DesignIconName.host),
  _RegisterAvatar('huai-avatar://locked', DesignIconName.locked),
  _RegisterAvatar('huai-avatar://watching', DesignIconName.watching),
];

class _PasswordStrength extends StatelessWidget {
  const _PasswordStrength({required this.password});

  final String password;

  int get _level {
    if (password.isEmpty) return 0;
    final valid = password.runes.length >= 8 &&
        RegExp('[A-Za-z]').hasMatch(password) &&
        RegExp('[0-9]').hasMatch(password);
    if (valid && RegExp('[^A-Za-z0-9]').hasMatch(password)) {
      return 3;
    }
    return valid ? 2 : 1;
  }

  @override
  Widget build(BuildContext context) {
    final level = _level;
    final colors = [
      DarkTokens.redAccent,
      DarkTokens.goldPrimary,
      DarkTokens.goldBright,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (var index = 0; index < colors.length; index++) ...[
              if (index > 0) const SizedBox(width: DarkTokens.spacingS1),
              Expanded(
                child: Container(
                  height: DarkTokens.spacingS1 + DarkTokens.spacingS2 / 4,
                  decoration: BoxDecoration(
                    color: index < level
                        ? colors[index]
                        : DarkTokens.bgCard,
                    borderRadius: BorderRadius.circular(DarkTokens.radiusBadge),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: DarkTokens.spacingS2),
        Text(
          '弱 → 中 → 强（建议使用字母、数字和特殊字符）',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
