import 'package:eighty_point_huai_an/src/generated/huai/v1/api.pb.dart';
import 'package:eighty_point_huai_an/src/logging/app_log.dart';
import 'package:eighty_point_huai_an/src/logging/log_sink_console.dart'
    as console;
import 'package:eighty_point_huai_an/src/logging/rpc_logging.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';

void main() {
  test('console platform does not create a native file sink', () async {
    expect(await console.openLogSink(), isNull);
  });

  test('Web startup uses console logging without a native file sink', () async {
    final previous = AppLog.output;
    final lines = <String>[];
    AppLog.output = lines.add;
    addTearDown(() {
      AppLog.close();
      AppLog.output = previous;
    });
    await AppLog.initialize();
    AppLog.info('web.console');
    expect(lines.length, 2);
    expect(lines.first, contains('[application.start]'));
    expect(lines.last, contains('[web.console]'));
  }, skip: !kIsWeb);

  test('format uses UTC, brackets and one physical line', () {
    expect(
      AppLog.format('INFO', DateTime.utc(2026, 11, 1, 10, 30), 'start\nnext\r'),
      r'[INFO] [2026-11-01T10:30:00.000Z] [start\nnext\r]',
    );
  });

  test('errors include status but never server messages or credentials', () {
    final previous = AppLog.output;
    final lines = <String>[];
    AppLog.output = lines.add;
    addTearDown(() => AppLog.output = previous);
    AppLog.failure('rpc.complete', const GrpcError.aborted('secret-token'));
    expect(lines.single, contains('[ERROR]'));
    expect(lines.single, contains('code=10'));
    expect(lines.single, isNot(contains('secret-token')));
  });

  test(
    'request context is a bounded allowlist and leaves messages unchanged',
    () {
      final action = SubmitActionRequest(
        requestId: '00000000-0000-4000-8000-000000000001',
        expectedVersion: Int64(17),
        gameSessionId: 'room-1',
        handId: 'private-hand',
      );
      final before = action.writeToBuffer();
      final context = requestLogContext(action);
      expect(context, contains('requestId=${action.requestId}'));
      expect(context, contains('expectedVersion=17'));
      expect(context, contains('gameSessionId=room-1'));
      expect(context, isNot(contains('private-hand')));
      expect(action.writeToBuffer(), orderedEquals(before));
      expect(
        requestLogContext(LoginRequest(account: 'private', password: 'secret')),
        isEmpty,
      );
      expect(
        requestLogContext(SubmitFeedbackRequest(body: 'private-message')),
        isNot(contains('private-message')),
      );
      expect(
        requestLogContext(RoomRequest(roomId: 'a\nb')),
        contains('roomId=a_b'),
      );
    },
  );
}
