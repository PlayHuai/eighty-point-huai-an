enum LobbyRoomStatus { waiting, playing, closed, unspecified }

const friendRoomHallId = 'friend';

class LobbyHall {
  const LobbyHall({
    required this.id,
    required this.name,
    required this.minimumPoints,
    required this.maximumPoints,
    required this.multiplier,
  });

  final String id;
  final String name;
  final int minimumPoints;
  final int maximumPoints;
  final double multiplier;
}

class LobbyRoom {
  const LobbyRoom({
    required this.id,
    required this.hallId,
    required this.name,
    required this.status,
    required this.occupiedSeats,
    required this.capacity,
    required this.hasPassword,
    required this.version,
    this.allowSpectators = false,
    this.minimumPoints = 0,
  });

  final String id;
  final String hallId;
  final String name;
  final LobbyRoomStatus status;
  final int occupiedSeats;
  final int capacity;
  final bool hasPassword;
  final int version;
  final bool allowSpectators;
  final int minimumPoints;
}
