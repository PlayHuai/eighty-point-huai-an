class PlayerStatistics {
  const PlayerStatistics({
    required this.totalGames,
    required this.wins,
    required this.losses,
    required this.points,
    required this.rank,
  });

  final int totalGames;
  final int wins;
  final int losses;
  final int points;
  final String rank;
}

class RecentGameResult {
  const RecentGameResult({
    required this.gameSessionId,
    required this.won,
    required this.pointsDelta,
    required this.endedAt,
  });

  final String gameSessionId;
  final bool won;
  final int pointsDelta;
  final DateTime endedAt;
}

class FriendRecentResultsPage {
  const FriendRecentResultsPage({
    required this.results,
    required this.nextPageToken,
  });

  final List<RecentGameResult> results;
  final String nextPageToken;
}

class RoomInvitation {
  const RoomInvitation({
    required this.roomId,
    required this.inviterUserId,
    required this.inviterNickname,
    required this.invitedAt,
  });

  final String roomId;
  final String inviterUserId;
  final String inviterNickname;
  final DateTime invitedAt;
}

class PlayerFriend {
  const PlayerFriend({
    required this.userId,
    required this.nickname,
    required this.avatarUrl,
    this.isOnline = false,
  });

  final String userId;
  final String nickname;
  final String avatarUrl;
  final bool isOnline;
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderUserId,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String senderUserId;
  final String body;
  final DateTime createdAt;
}

class ChatMessagesPage {
  const ChatMessagesPage({required this.messages, required this.nextPageToken});

  final List<ChatMessage> messages;
  final String nextPageToken;
}
