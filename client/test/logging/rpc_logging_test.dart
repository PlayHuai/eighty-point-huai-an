@TestOn('vm')
library;

import 'package:eighty_point_huai_an/src/api/game_table_client.dart';
import 'package:eighty_point_huai_an/src/generated/huai/v1/api.pb.dart';
import 'package:eighty_point_huai_an/src/logging/app_log.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';

void main() {
  test(
    'logging preserves retry IDs, versions, and conflict errors on the wire',
    () async {
      final lines = <String>[];
      final previous = AppLog.output;
      AppLog.output = lines.add;
      addTearDown(() => AppLog.output = previous);
      final service = _RoomService();
      final server = Server.create(services: [service]);
      await server.serve(address: '127.0.0.1', port: 0);
      final client = GrpcGameTableClient(
        Uri.parse('http://127.0.0.1:${server.port}'),
        'private-token',
      );
      addTearDown(() async {
        await client.close();
        await server.shutdown();
      });
      final request = SeatRequest(
        roomId: 'room-1',
        seatNo: 1,
        requestId: '00000000-0000-4000-8000-000000000001',
        expectedVersion: Int64(17),
      );
      final original = request.writeToBuffer();
      await client.sitDown(request);
      await client.sitDown(request);
      service.conflict = true;
      await expectLater(
        client.sitDown(request),
        throwsA(
          isA<GrpcError>().having(
            (error) => error.code,
            'code',
            StatusCode.aborted,
          ),
        ),
      );
      expect(service.requests.length, 3);
      for (final received in service.requests) {
        expect(received.writeToBuffer(), orderedEquals(original));
      }
      expect(lines.join(), contains('expectedVersion=17'));
      expect(lines.join(), contains('code=10'));
      expect(lines.join(), isNot(contains('private-token')));
      expect(lines.join(), isNot(contains('private-error')));
    },
  );
}

class _RoomService extends Service {
  _RoomService() {
    $addMethod(
      ServiceMethod<SeatRequest, RoomDetails>(
        'SitDown',
        (ServiceCall call, Future<SeatRequest> request) async {
          requests.add(await request);
          if (conflict) throw const GrpcError.aborted('private-error');
          return RoomDetails(version: Int64(18));
        },
        false,
        false,
        SeatRequest.fromBuffer,
        (response) => response.writeToBuffer(),
      ),
    );
  }

  @override
  String get $name => 'huai.v1.RoomService';

  final requests = <SeatRequest>[];
  bool conflict = false;
}
