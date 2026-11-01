import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'log_sink.dart';

Future<LogSink> openLogSink() async {
  final base = defaultTargetPlatform == TargetPlatform.iOS
      ? await getLibraryDirectory()
      : await getApplicationSupportDirectory();
  return FileLogSink.open(
    Directory('${base.path}${Platform.pathSeparator}Logs'),
  );
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
