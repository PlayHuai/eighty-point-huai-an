import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/realtime_event.dart';
import '../auth/auth_controller.dart';
import 'chat_screen.dart';
import 'client_providers.dart';
import 'friend_list_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'lobby_screen.dart';
import 'theme/app_theme.dart';

class ClientApp extends StatefulWidget {
  const ClientApp({
    required this.auth,
    this.endpoint,
    this.routes = const {},
    super.key,
  });

  final AuthController auth;
  final Uri? endpoint;
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
      apiEndpointProvider.overrideWithValue(widget.endpoint),
      authControllerProvider.overrideWith(
        (ref) => widget.auth,
        disposeNotifier: false,
      ),
    ],
    child: MaterialApp(
      title: '淮安80分',
      theme: AppTheme.dark,
      routes: widget.routes,
      builder: (context, child) =>
          _RealtimeStateListener(child: child ?? const SizedBox.shrink()),
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

class _RealtimeStateListener extends ConsumerWidget {
  const _RealtimeStateListener({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(realtimeEventsProvider, (previous, next) {
      next.whenData((event) => _refreshForEvent(ref, event));
    });
    return child;
  }

  void _refreshForEvent(WidgetRef ref, RealtimeEvent event) {
    switch (event.type) {
      case 'PRIVATE_MESSAGE_CREATED':
        if (event.peerUserId.isNotEmpty) {
          ref.invalidate(privateMessagesProvider(event.peerUserId));
        }
        break;
      case 'FRIEND_STATE_CHANGED':
        ref.invalidate(friendListProvider);
        ref.invalidate(friendRequestsProvider);
        ref.invalidate(roomInvitationsProvider);
        break;
      case 'LOBBY_STATE_CHANGED':
        ref.invalidate(lobbyHallsProvider);
        ref.invalidate(lobbyRoomsProvider);
        break;
      case 'ROOM_STATE_CHANGED':
        ref.invalidate(lobbyRoomsProvider);
        break;
      case 'CONNECTION_RESTORED':
        ref.invalidate(privateMessagesProvider);
        ref.invalidate(friendListProvider);
        ref.invalidate(friendRequestsProvider);
        ref.invalidate(roomInvitationsProvider);
        ref.invalidate(lobbyHallsProvider);
        ref.invalidate(lobbyRoomsProvider);
        break;
    }
  }
}
