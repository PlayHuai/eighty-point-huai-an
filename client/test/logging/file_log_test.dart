@TestOn('vm')
library;

import 'dart:io';

import 'package:eighty_point_huai_an/src/logging/log_sink_io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

void main() {
  for (final platform in [TargetPlatform.iOS, TargetPlatform.windows]) {
    test('$platform uses its user-specific log directory', () async {
      final directory = Directory.systemTemp.createTempSync('huaian-user-log-');
      final previous = PathProviderPlatform.instance;
      final previousPlatform = debugDefaultTargetPlatformOverride;
      final paths = _UserPaths(directory.path);
      PathProviderPlatform.instance = paths;
      debugDefaultTargetPlatformOverride = platform;
      addTearDown(() {
        PathProviderPlatform.instance = previous;
        debugDefaultTargetPlatformOverride = previousPlatform;
        directory.deleteSync(recursive: true);
      });
      final sink = await openLogSink();
      sink.write('platform=$platform');
      sink.close();
      final base = platform == TargetPlatform.iOS ? 'Library' : 'Support';
      final separator = Platform.pathSeparator;
      expect(
        File(
          '${directory.path}$separator$base${separator}Logs${separator}huaian-80.log',
        ).readAsStringSync(),
        'platform=$platform\n',
      );
      expect(paths.libraryCalls, platform == TargetPlatform.iOS ? 1 : 0);
      expect(paths.supportCalls, platform == TargetPlatform.windows ? 1 : 0);
    });
  }

  test('each launch creates current log and retains exactly ten histories', () {
    final directory = Directory.systemTemp.createTempSync('huaian-log-test-');
    addTearDown(() => directory.deleteSync(recursive: true));
    final unrelated = File(
      '${directory.path}${Platform.pathSeparator}keep.txt',
    );
    unrelated.writeAsStringSync('keep');
    for (var launch = 0; launch < 15; launch++) {
      final sink = FileLogSink.open(directory);
      sink.write('launch=$launch');
      sink.close();
    }

    final path = '${directory.path}${Platform.pathSeparator}huaian-80.log';
    expect(File(path).readAsStringSync(), 'launch=14\n');
    for (var suffix = 0; suffix < 10; suffix++) {
      expect(
        File('$path.$suffix').readAsStringSync(),
        'launch=${13 - suffix}\n',
      );
    }
    expect(File('$path.10').existsSync(), isFalse);
    expect(directory.listSync().length, 12);
    expect(unrelated.readAsStringSync(), 'keep');
  });

  test('writes are visible immediately, without closing the sink', () {
    final directory = Directory.systemTemp.createTempSync('huaian-log-flush-');
    addTearDown(() => directory.deleteSync(recursive: true));
    final sink = FileLogSink.open(directory);
    addTearDown(sink.close);
    sink.write('first');
    sink.write('second');
    expect(
      File('${directory.path}${Platform.pathSeparator}huaian-80.log')
          .readAsStringSync(),
      'first\nsecond\n',
    );
  });

  test('initialization errors are surfaced, not silently ignored', () {
    final directory = Directory.systemTemp.createTempSync('huaian-log-fail-');
    addTearDown(() => directory.deleteSync(recursive: true));
    final file = File(
      '${directory.path}${Platform.pathSeparator}not-a-directory',
    )..writeAsStringSync('data');
    expect(
      () => FileLogSink.open(Directory(file.path)),
      throwsA(isA<FileSystemException>()),
    );
  });
}

class _UserPaths extends PathProviderPlatform {
  _UserPaths(this.root);

  final String root;
  int libraryCalls = 0;
  int supportCalls = 0;

  @override
  Future<String?> getLibraryPath() async {
    libraryCalls++;
    return '$root${Platform.pathSeparator}Library';
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    supportCalls++;
    return '$root${Platform.pathSeparator}Support';
  }
}
