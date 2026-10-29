import 'package:flutter/material.dart';

import '../auth/auth_controller.dart';
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
  final _nickname = TextEditingController();
  bool _registering = false;

  @override
  void dispose() {
    _account.dispose();
    _password.dispose();
    _nickname.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_registering) {
      await widget.auth.register(
        _account.text.trim(),
        _password.text,
        _nickname.text.trim(),
      );
    } else {
      await widget.auth.login(_account.text.trim(), _password.text);
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
                        _registering ? '创建账号' : '淮安80分',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: DarkTokens.spacingS5),
                      TextFormField(
                        controller: _account,
                        decoration: const InputDecoration(labelText: '账号或邮箱'),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? '请输入账号'
                            : null,
                        textInputAction: TextInputAction.next,
                      ),
                      if (_registering)
                        TextFormField(
                          controller: _nickname,
                          decoration: const InputDecoration(labelText: '昵称'),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? '请输入昵称'
                              : null,
                          textInputAction: TextInputAction.next,
                        ),
                      TextFormField(
                        controller: _password,
                        decoration: const InputDecoration(labelText: '密码'),
                        obscureText: true,
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
                        child: Text(_registering ? '注册' : '登录'),
                      ),
                      TextButton(
                        onPressed: widget.auth.isLoading
                            ? null
                            : () => setState(() {
                                _registering = !_registering;
                                widget.auth.clearError();
                              }),
                        child: Text(_registering ? '已有账号？登录' : '创建账号'),
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
