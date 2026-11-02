import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/common.dart';

import '../../integration_test/support/case_results.dart';

void main() {
  late Directory directory;
  setUp(() {
    directory = Directory.systemTemp.createTempSync('huai-case-results-');
    File('${directory.path}\\results.tsv').writeAsStringSync(
      'GAME-030\tFull match\tPASS\nGAME-031\tHistory\tPASS\n',
    );
    File('${directory.path}\\passed_case.txt')
        .writeAsStringSync('Full match-GAME-030\nHistory-GAME-031\n');
  });
  tearDown(() => directory.deleteSync(recursive: true));

  test('late framework errors override PASS while preserving raw evidence', () {
    reconcileFrameworkFailures(directory, [
      Failure('GAME-030 Full match', 'Unable to load dealer marker'),
    ]);
    expect(
      File('${directory.path}\\results.tsv').readAsStringSync(),
      'GAME-030\tFull match\tFAIL\nGAME-031\tHistory\tPASS\n',
    );
    expect(
      File('${directory.path}\\results.before-framework.tsv')
          .readAsStringSync(),
      contains('GAME-030\tFull match\tPASS'),
    );
    expect(
      File('${directory.path}\\passed_case.txt').readAsStringSync(),
      'History-GAME-031\n',
    );
    expect(
      File('${directory.path}\\issues\\Full match-GAME-030\\issue.txt')
          .readAsStringSync(),
      contains('Unable to load dealer marker'),
    );
  });

  test('walkthrough failures create explicit environment evidence', () {
    reconcileFrameworkFailures(directory, [
      Failure('UI reference capture', 'Unable to capture reference'),
    ]);
    expect(
      File(
        '${directory.path}\\issues\\Environment-framework-failed-ENV-RUN\\issue.txt',
      ).readAsStringSync(),
      contains('Unable to capture reference'),
    );
  });
}
