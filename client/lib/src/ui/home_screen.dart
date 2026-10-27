import 'package:flutter/material.dart';

import '../auth/auth_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.auth, required this.nickname, super.key});

  final AuthController auth;
  final String nickname;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('淮安80分'),
      actions: [
        IconButton(
          tooltip: '退出登录',
          onPressed: auth.isLoading ? null : auth.logout,
          icon: const Icon(Icons.logout),
        ),
      ],
    ),
    body: Center(
      child: Text('你好，$nickname', style: Theme.of(context).textTheme.headlineSmall),
    ),
  );
}
