import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import 'client_providers.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'theme/app_theme.dart';

class ClientApp extends StatefulWidget {
  const ClientApp({required this.auth, this.routes = const {}, super.key});

  final AuthController auth;
  final Map<String, WidgetBuilder> routes;

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
  Widget build(BuildContext context) => ProviderScope(
    retry: (retryCount, error) => null,
    overrides: [
      apiClientProvider.overrideWithValue(widget.auth.api),
      authControllerProvider.overrideWith(
        (ref) => widget.auth,
        disposeNotifier: false,
      ),
    ],
    child: MaterialApp(
      title: '淮安80分',
      theme: AppTheme.dark,
      routes: widget.routes,
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
    ),
  );
}
