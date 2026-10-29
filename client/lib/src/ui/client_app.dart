import 'dart:async';

import 'package:flutter/material.dart';

import '../auth/auth_controller.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class ClientApp extends StatefulWidget {
  const ClientApp({required this.auth, super.key});

  final AuthController auth;

  @override
  State<ClientApp> createState() => _ClientAppState();
}

class _ClientAppState extends State<ClientApp> {
  @override
  void initState() {
    super.initState();
    widget.auth.restoreSession();
  }

  @override
  void dispose() {
    unawaited(widget.auth.close());
    widget.auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: '淮安80分',
    theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
    home: AnimatedBuilder(
      animation: widget.auth,
      builder: (context, _) {
        final session = widget.auth.session;
        return Stack(
          fit: StackFit.expand,
          children: [
            AbsorbPointer(
              absorbing: widget.auth.isLoading,
              child: session == null
                  ? LoginScreen(auth: widget.auth)
                  : HomeScreen(auth: widget.auth, nickname: session.nickname),
            ),
            if (widget.auth.isLoading) ...[
              const ModalBarrier(dismissible: false, color: Colors.black26),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        );
      },
    ),
  );
}
