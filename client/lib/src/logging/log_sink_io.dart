import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'log_sink.dart';

Future<LogSink> openLogSink() async {
  final base = defaultTargetPlatform == TargetPlatform.iOS
      ? await getLibraryDirectory()
      : await getApplicationSupportDirectory();
  final ready = ReceivePort();
  try {
    await Isolate.spawn(
      _fileLogWorker,
      [ready.sendPort, '${base.path}${Platform.pathSeparator}Logs'],
    );
    final result = await ready.first;
    if (result is SendPort) return _QueuedFileLogSink(result);
    throw StateError('File log sink initialization failed ($result)');
  } finally {
    ready.close();
  }
}

void _fileLogWorker(List<Object> arguments) {
  final ready = arguments[0] as SendPort;
  late final FileLogSink sink;
  try {
    sink = FileLogSink.open(Directory(arguments[1] as String));
  } catch (error) {
    ready.send('error=${error.runtimeType}');
    return;
  }

  final commands = ReceivePort();
  ready.send(commands.sendPort);
  commands.listen((message) {
    if (message == null) {
      sink.close();
      commands.close();
    } else if (message is String) {
      sink.write(message);
    }
  });
}

class _QueuedFileLogSink implements LogSink {
  _QueuedFileLogSink(this._commands);

  final SendPort _commands;
  bool _closed = false;

  @override
  void write(String line) {
    if (!_closed) _commands.send(line);
  }

  @override
  void close() {
    if (_closed) return;
    _closed = true;
    _commands.send(null);
  }
}

class FileLogSink implements LogSink {
  FileLogSink._(this._file);

  static const fileName = 'huaian-80.log';
  final RandomAccessFile _file;

  static FileLogSink open(Directory directory) {
    directory.createSync(recursive: true);
    final path = '${directory.path}${Platform.pathSeparator}$fileName';
    final oldest = File('$path.9');
    if (oldest.existsSync()) oldest.deleteSync();
    for (var index = 8; index >= 0; index--) {
      final previous = File('$path.$index');
      if (previous.existsSync()) previous.renameSync('$path.${index + 1}');
    }
    final current = File(path);
    if (current.existsSync()) current.renameSync('$path.0');
    return FileLogSink._(current.openSync(mode: FileMode.writeOnly));
  }

  @override
  void write(String line) {
    _file.writeStringSync('$line\n');
    _file.flushSync();
  }

  @override
  void close() => _file.closeSync();
}
