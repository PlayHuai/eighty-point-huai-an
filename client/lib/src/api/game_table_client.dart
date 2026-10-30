import 'package:grpc/service_api.dart';

import '../generated/huai/v1/api.pbgrpc.dart' as pb;
import 'channel_factory.dart';

abstract interface class GameTableClient {
  Future<pb.RoomDetails> getRoom(pb.RoomRequest request);
  Future<pb.RoomDetails> sitDown(pb.SeatRequest request);
  Future<pb.RoomDetails> changeSeat(pb.SeatRequest request);
  Future<pb.RoomDetails> standUp(pb.RoomRequest request);
  Future<pb.RoomDetails> setSpectatorView(pb.SpectatorViewRequest request);
  Future<pb.RoomDetails> setHandVisibility(pb.SpectatorViewRequest request);
  Future<pb.GameSnapshot> startGame(pb.RoomRequest request);
  Future<pb.GameSnapshot> getSnapshot(pb.GameSnapshotRequest request);
  Future<pb.SubmitActionResponse> submitAction(pb.SubmitActionRequest request);
  Future<pb.RequestReconnectResponse> reconnect(
    pb.RequestReconnectRequest request,
  );
  Future<void> close();
}

class GrpcGameTableClient implements GameTableClient {
  GrpcGameTableClient(Uri endpoint, String accessToken)
    : _channel = createClientChannel(endpoint),
      _options = CallOptions(
        metadata: {'authorization': 'Bearer $accessToken'},
      );

  final ClientChannel _channel;
  final CallOptions _options;
  late final _room = pb.RoomServiceClient(_channel);
  late final _game = pb.GameServiceClient(_channel);

  @override
  Future<pb.RoomDetails> getRoom(pb.RoomRequest request) =>
      _room.getRoom(request, options: _options);

  @override
  Future<pb.RoomDetails> sitDown(pb.SeatRequest request) =>
      _room.sitDown(request, options: _options);

  @override
  Future<pb.RoomDetails> changeSeat(pb.SeatRequest request) =>
      _room.changeSeat(request, options: _options);

  @override
  Future<pb.RoomDetails> standUp(pb.RoomRequest request) =>
      _room.standUp(request, options: _options);

  @override
  Future<pb.RoomDetails> setSpectatorView(pb.SpectatorViewRequest request) =>
      _room.setSpectatorView(request, options: _options);

  @override
  Future<pb.RoomDetails> setHandVisibility(pb.SpectatorViewRequest request) =>
      _room.setHandVisibility(request, options: _options);

  @override
  Future<pb.GameSnapshot> startGame(pb.RoomRequest request) =>
      _room.startGame(request, options: _options);

  @override
  Future<pb.GameSnapshot> getSnapshot(pb.GameSnapshotRequest request) =>
      _game.getGameSnapshot(request, options: _options);

  @override
  Future<pb.SubmitActionResponse> submitAction(
    pb.SubmitActionRequest request,
  ) => _game.submitAction(request, options: _options);

  @override
  Future<pb.RequestReconnectResponse> reconnect(
    pb.RequestReconnectRequest request,
  ) => _game.requestReconnect(request, options: _options);

  @override
  Future<void> close() => _channel.shutdown();
}
