import 'package:flutter/material.dart';

import '../auth/auth_controller.dart';
import 'lobby_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.auth, required this.nickname, super.key});

  final AuthController auth;
  final String nickname;

  @override
  Widget build(BuildContext context) =>
      LobbyScreen(auth: auth, nickname: nickname);
}
