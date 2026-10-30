import 'package:web_socket_channel/web_socket_channel.dart';

import 'event_socket_contract.dart';

export 'event_socket_contract.dart';

Future<EventSocket> connectEventSocket(Uri uri, String accessToken) async {
  final socket = WebSocketChannel.connect(
    uri,
    protocols: ['huai.events.v1', 'huai.auth.$accessToken'],
  );
  await socket.ready;
  return _ChannelEventSocket(socket);
}

class _ChannelEventSocket implements EventSocket {
  const _ChannelEventSocket(this._socket);

  final WebSocketChannel _socket;

  @override
  Stream<String> get messages =>
      _socket.stream.map((message) => message.toString());

  @override
  Future<void> close() async {
    await _socket.sink.close();
  }
}
