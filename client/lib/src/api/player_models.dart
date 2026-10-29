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
