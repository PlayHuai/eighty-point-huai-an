import 'package:flutter/foundation.dart';
import 'package:grpc/grpc.dart';

import 'log_sink.dart';
import 'log_sink_console.dart'
    if (dart.library.io) 'log_sink_io.dart'
    as platform;

class AppLog {
  static LogSink? _sink;
  static void Function(String) output = debugPrintSynchronously;

  static Future<void> initialize() async {
    try {
      _sink = await platform.openLogSink();
      info('application.start');
    } catch (error, stack) {
      failure('logging.initialize', error, stack);
      rethrow;
    }
  }

  static String format(String type, DateTime time, String message) =>
      '[$type] [${time.toUtc().toIso8601String()}] '
      '[${message.replaceAll('\r', r'\r').replaceAll('\n', r'\n')}]';

  static void info(String message) => _write('INFO', message);
  static void warning(String message) => _write('WARN', message);

  static void failure(String operation, Object error, [StackTrace? stack]) {
    final code = error is GrpcError ? ' code=${error.code}' : '';
    _write(
      'ERROR',
      '$operation error=${error.runtimeType}$code'
          '${stack == null ? '' : ' stack=$stack'}',
    );
  }

  static void _write(String type, String message) {
    final line = format(type, DateTime.now(), message);
    output(line);
    try {
      _sink?.write(line);
    } catch (error) {
      output(
        format(
          'ERROR',
          DateTime.now(),
          'logging.write error=${error.runtimeType}',
        ),
      );
    }
  }

  static void close() {
    final sink = _sink;
    _sink = null;
    sink?.close();
  }
}
