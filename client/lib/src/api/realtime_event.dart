import 'dart:convert';

class RealtimeEvent {
  const RealtimeEvent({
    required this.type,
    this.sequence = 0,
    this.messageId = '',
    this.senderUserId = '',
    this.peerUserId = '',
    this.roomId = '',
    this.body = '',
    this.entityId = '',
    this.version = 0,
    this.payload = const {},
  });

  factory RealtimeEvent.fromJson(String json) {
    final value = jsonDecode(json);
    if (value is! Map<String, dynamic>) {
      throw const FormatException('WebSocket event must be a JSON object.');
    }
    return RealtimeEvent(
      type: value['type'] as String? ?? '',
      sequence: (value['seq'] as num?)?.toInt() ?? 0,
      messageId: value['message_id'] as String? ?? '',
      senderUserId: value['sender_user_id'] as String? ?? '',
      peerUserId: value['peer_user_id'] as String? ?? '',
      roomId: value['room_id'] as String? ?? '',
      body: value['body'] as String? ?? '',
      entityId: value['entity_id'] as String? ?? '',
      version: (value['version'] as num?)?.toInt() ?? 0,
      payload: value['payload'] is Map<String, dynamic>
          ? value['payload'] as Map<String, dynamic>
          : const {},
    );
  }

  final String type;
  final int sequence;
  final String messageId;
  final String senderUserId;
  final String peerUserId;
  final String roomId;
  final String body;
  final String entityId;
  final int version;
  final Map<String, dynamic> payload;
}
