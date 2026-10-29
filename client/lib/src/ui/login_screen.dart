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
    if (!_formKey.currentState!.validate()) return;
    await widget.auth.login(_account.text.trim(), _password.text);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(DarkTokens.spacingS5),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '淮安80分',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: DarkTokens.spacingS5),
                      TextFormField(
                        controller: _account,
                        decoration: const InputDecoration(
                          labelText: '账号或邮箱',
                          prefixIcon: DesignIcon(
                            name: DesignIconName.login,
                            enabled: true,
                            size: DarkTokens.spacingS4 + DarkTokens.spacingS1,
                          ),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? '请输入账号'
                            : null,
                        textInputAction: TextInputAction.next,
                      ),
                      TextFormField(
                        key: const ValueKey('login-password-field'),
                        controller: _password,
                        decoration: InputDecoration(
                          labelText: '密码',
                          prefixIcon: const DesignIcon(
                            name: DesignIconName.locked,
                            enabled: true,
                            size: DarkTokens.spacingS4 + DarkTokens.spacingS1,
                          ),
                          suffixIcon: TextButton(
                            onPressed: () => setState(
                              () => _passwordVisible = !_passwordVisible,
                            ),
                            child: Text(_passwordVisible ? '隐藏' : '显示'),
                          ),
                        ),
                        obscureText: !_passwordVisible,
                        validator: (value) =>
                            value == null || value.isEmpty ? '请输入密码' : null,
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
                              color: Theme.of(context).colorScheme.error,
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
                      const SizedBox(height: DarkTokens.spacingS4),
                      FilledButton(
                        onPressed: widget.auth.isLoading ? null : _submit,
                        child: const Text('登录'),
                      ),
                      TextButton(
                        onPressed: widget.auth.isLoading
                            ? null
                            : () {
                                widget.auth.clearError();
                                Navigator.of(context).push<void>(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        RegisterScreen(auth: widget.auth),
                                  ),
                                );
                              },
                        child: const Text('创建账号'),
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
  );
}
