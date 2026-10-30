import 'package:eighty_point_huai_an/src/api/realtime_event.dart';
import 'package:eighty_point_huai_an/src/api/realtime_event_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('derives secure WebSocket endpoint from API endpoint', () {
    expect(
      RealtimeEventClient.websocketUriForEndpoint(
        Uri.parse('https://api.example.com:8443'),
      ),
      Uri.parse('wss://api.example.com:8443/events'),
    );
  });

  test('preserves explicit WebSocket endpoint and path', () {
    expect(
      RealtimeEventClient.websocketUriForEndpoint(
        Uri.parse('wss://events.example.com:9443/custom-events'),
      ),
      Uri.parse('wss://events.example.com:9443/custom-events'),
    );
  });

  test('decodes authenticated private chat events', () {
    final event = RealtimeEvent.fromJson(
      '{"type":"PRIVATE_MESSAGE_CREATED","seq":7,'
      '"message_id":"42","sender_user_id":"friend",'
      '"peer_user_id":"friend","body":"hello"}',
    );

    expect(event.type, 'PRIVATE_MESSAGE_CREATED');
    expect(event.sequence, 7);
    expect(event.messageId, '42');
    expect(event.peerUserId, 'friend');
    expect(event.body, 'hello');
  });

  test('decodes room and presence state payloads', () {
    final room = RealtimeEvent.fromJson(
      '{"type":"ROOM_MESSAGE_CREATED","room_id":"r1",'
      '"sender_user_id":"p1","body":"table"}',
    );
    final friend = RealtimeEvent.fromJson(
      '{"type":"FRIEND_STATE_CHANGED","entity_id":"p1",'
      '"payload":{"online":true}}',
    );

    expect(room.roomId, 'r1');
    expect(room.body, 'table');
    expect(friend.entityId, 'p1');
    expect(friend.payload['online'], isTrue);
  });

  test('rejects events that are not JSON objects', () {
    expect(() => RealtimeEvent.fromJson('[]'), throwsFormatException);
  });
}
