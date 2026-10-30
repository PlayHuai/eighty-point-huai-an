import 'package:flutter/material.dart';

import '../auth/auth_controller.dart';
import 'components/design_icon.dart';
import 'register_screen.dart';
import 'theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({required this.auth, super.key});

  final AuthController auth;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _panelMaxWidth =
      DarkTokens.spacingS6 * 12 + DarkTokens.spacingS5 + DarkTokens.spacingS3;
  static const _fieldHeight =
      DarkTokens.spacingS6 + DarkTokens.spacingS4 + DarkTokens.spacingS1;
  static const _iconSize = DarkTokens.spacingS4 + DarkTokens.spacingS1;

  final _formKey = GlobalKey<FormState>();
  final _account = TextEditingController();
  final _password = TextEditingController();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _account.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (widget.auth.isLoading) return;
    if (!_formKey.currentState!.validate()) return;
    await widget.auth.login(_account.text.trim(), _password.text);
  }

  InputDecoration _decoration(String hint, DesignIconName icon) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: DarkTokens.textSecondary,
          fontSize: DarkTokens.fontSizeL5,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: DarkTokens.spacingS3,
        ),
        constraints: const BoxConstraints(minHeight: _fieldHeight),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(
            left: DarkTokens.spacingS4,
            right: DarkTokens.spacingS3,
          ),
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: DesignIcon(name: icon, enabled: true, size: _iconSize),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: DarkTokens.spacingS4 + _iconSize + DarkTokens.spacingS3,
          minHeight: _fieldHeight,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DarkTokens.radiusButton),
          borderSide: const BorderSide(color: DarkTokens.goldPrimary),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: AnimatedBuilder(
        animation: widget.auth,
        builder: (context, _) => LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                minWidth: constraints.maxWidth,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DarkTokens.spacingS5,
                      vertical: DarkTokens.spacingS6 * 2,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: _panelMaxWidth,
                      ),
                      child: DecoratedBox(
                        key: const ValueKey('login-panel'),
                        decoration: BoxDecoration(
                          color: DarkTokens.bgPanel,
                          border: Border.all(color: DarkTokens.goldPrimary),
                          borderRadius: BorderRadius.circular(
                            DarkTokens.radiusPanel,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(
                            constraints.maxWidth < _panelMaxWidth
                                ? DarkTokens.spacingS5
                                : DarkTokens.spacingS6 + DarkTokens.spacingS2,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Center(
                                  child: AppIcon(
                                    size:
                                        DarkTokens.spacingS6 +
                                        DarkTokens.spacingS5,
                                  ),
                                ),
                                const SizedBox(height: DarkTokens.spacingS4),
                                Text(
                                  '淮安80分',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontSize: DarkTokens.fontSizeL1,
                                        height: 1.2,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: DarkTokens.spacingS5),
                                TextFormField(
                                  key: const ValueKey('login-account-field'),
                                  controller: _account,
                                  enabled: !widget.auth.isLoading,
                                  style: const TextStyle(
                                    fontSize: DarkTokens.fontSizeL5,
                                  ),
                                  decoration: _decoration(
                                    '请输入账号',
                                    DesignIconName.login,
                                  ),
                                  validator: (value) =>
                                      value == null || value.trim().isEmpty
                                      ? '请输入账号'
                                      : null,
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: DarkTokens.spacingS4),
                                TextFormField(
                                  key: const ValueKey('login-password-field'),
                                  controller: _password,
                                  enabled: !widget.auth.isLoading,
                                  style: const TextStyle(
                                    fontSize: DarkTokens.fontSizeL5,
                                  ),
                                  decoration:
                                      _decoration(
                                        '请输入密码',
                                        DesignIconName.locked,
                                      ).copyWith(
                                        suffixIcon: IconButton(
                                          tooltip: _passwordVisible
                                              ? '隐藏密码'
                                              : '显示密码',
                                          onPressed: () => setState(
                                            () => _passwordVisible =
                                                !_passwordVisible,
                                          ),
                                          icon: DesignIcon(
                                            name: DesignIconName.watching,
                                            enabled: true,
                                            size: _iconSize,
                                          ),
                                        ),
                                      ),
                                  obscureText: !_passwordVisible,
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                      ? '请输入密码'
                                      : null,
                                  onFieldSubmitted: (_) => _submit(),
                                ),
                                if (widget.auth.error case final error?)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: DarkTokens.spacingS3,
                                    ),
                                    child: Text(
                                      error,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error,
                                      ),
                                    ),
                                  ),
                                if (widget.auth.canRetryRestore)
                                  TextButton(
                                    onPressed: widget.auth.isLoading
                                        ? null
                                        : widget.auth.restoreSession,
                                    child: const Text('重试恢复登录'),
                                  ),
                                const SizedBox(height: DarkTokens.spacingS5),
                                SizedBox(
                                  height: _fieldHeight,
                                  child: FilledButton(
                                    key: const ValueKey('login-submit'),
                                    onPressed: widget.auth.isLoading
                                        ? null
                                        : _submit,
                                    style: FilledButton.styleFrom(
                                      textStyle: const TextStyle(
                                        fontSize: DarkTokens.fontSizeL5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    child: const Text('登录'),
                                  ),
                                ),
                                const SizedBox(height: DarkTokens.spacingS5),
                                if (widget.auth.isLoading)
                                  const Text(
                                    '正在恢复登录…',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: DarkTokens.textSecondary,
                                      fontSize: DarkTokens.fontSizeL5,
                                    ),
                                  )
                                else
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, _iconSize),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      foregroundColor: DarkTokens.textSecondary,
                                      textStyle: const TextStyle(
                                        fontSize: DarkTokens.fontSizeL5,
                                      ),
                                    ),
                                    onPressed: widget.auth.isLoading
                                        ? null
                                        : () {
                                            widget.auth.clearError();
                                            Navigator.of(context).push<void>(
                                              MaterialPageRoute(
                                                builder: (_) => RegisterScreen(
                                                  auth: widget.auth,
                                                ),
                                              ),
                                            );
                                          },
                                    child: const Text('创建账号'),
                                  ),
                                const SizedBox(height: DarkTokens.spacingS2),
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: DarkTokens.redAccent.withValues(
                                      alpha: 0.2,
                                    ),
                                    border: Border.all(
                                      color: DarkTokens.suitRed,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      DarkTokens.radiusButton,
                                    ),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(
                                      DarkTokens.spacingS3,
                                    ),
                                    child: Text(
                                      '多次输错将临时锁定账号，请谨慎输入',
                                      style: TextStyle(
                                        color: DarkTokens.textPrimary,
                                        fontSize: DarkTokens.fontSizeL5,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    bottom: DarkTokens.spacingS6,
                    child: Text(
                      'v${String.fromEnvironment('FLUTTER_BUILD_NAME', defaultValue: '0.1.0')}',
                      style: TextStyle(
                        color: DarkTokens.textDisabled,
                        fontSize: DarkTokens.fontSizeL6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
