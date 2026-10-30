import 'dart:async';

import 'event_socket.dart';
import 'realtime_event.dart';

class RealtimeEventClient {
  RealtimeEventClient({required Uri endpoint, required String accessToken})
    : _uri = _webSocketUri(endpoint),
      _accessToken = accessToken {
    unawaited(_run());
  }

  final Uri _uri;
  final String _accessToken;
  final StreamController<RealtimeEvent> _events =
      StreamController<RealtimeEvent>.broadcast();
  EventSocket? _socket;
  bool _closed = false;
  bool _connectedOnce = false;

  Stream<RealtimeEvent> get events => _events.stream;

  Future<void> close() async {
    _closed = true;
    await _socket?.close();
    await _events.close();
  }

  Future<void> _run() async {
    var retryDelay = const Duration(seconds: 1);
    while (!_closed) {
      try {
        final socket = await connectEventSocket(_uri, _accessToken);
        if (_closed) {
          await socket.close();
          return;
        }
        _socket = socket;
        if (_connectedOnce) {
          _events.add(const RealtimeEvent(type: 'CONNECTION_RESTORED'));
        }
        _connectedOnce = true;
        retryDelay = const Duration(seconds: 1);
        await for (final message in socket.messages) {
          if (_closed) break;
          try {
            _events.add(RealtimeEvent.fromJson(message));
          } on FormatException {
            continue;
          }
        }
      } catch (_) {
        if (_closed) return;
      } finally {
        _socket = null;
      }
      if (_closed) return;
      await Future<void>.delayed(retryDelay);
      if (retryDelay < const Duration(seconds: 30)) {
        retryDelay *= 2;
      }
    }
  }

  static Uri _webSocketUri(Uri endpoint) {
    final scheme = switch (endpoint.scheme) {
      'https' => 'wss',
      'http' => 'ws',
      _ => throw ArgumentError.value(
        endpoint,
        'endpoint',
        'HTTP(S) URL required',
      ),
    };
    return endpoint.replace(
      scheme: scheme,
      path: '/events',
      query: null,
      fragment: null,
    );
  }
}
