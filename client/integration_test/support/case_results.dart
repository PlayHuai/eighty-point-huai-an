import 'dart:io';

import 'package:integration_test/common.dart';

void reconcileFrameworkFailures(
  Directory directory,
  Iterable<Failure> failures,
) {
  if (failures.isEmpty) return;
  final results = File('${directory.path}\\results.tsv');
  final rows = results.existsSync()
      ? results.readAsLinesSync().map((line) => line.split('\t')).toList()
      : <List<String>>[];
  for (final failure in failures) {
    final id = RegExp(r'^([A-Z]+-\d+)\b')
        .firstMatch(failure.methodName)
        ?.group(1);
    final matches = rows.where((row) => row.length == 3 && row[0] == id);
    final String issueName;
    final String heading;
    if (matches.isNotEmpty) {
      final row = matches.single;
      row[2] = 'FAIL';
      issueName = '${row[1]}-${row[0]}';
      heading = '${row[0]}\t${row[1]}';
    } else {
      issueName = 'Environment-framework-failed-ENV-RUN';
      heading = 'ENV-001\tFlutter framework or screenshot walkthrough failure';
    }
    final issue = Directory('${directory.path}\\issues\\$issueName')
      ..createSync(recursive: true);
    File('${issue.path}\\issue.txt').writeAsStringSync(
      '$heading\nFAIL\n${failure.methodName}\n${failure.details}\n',
      mode: FileMode.append,
    );
  }
  if (results.existsSync()) {
    results.copySync('${directory.path}\\results.before-framework.tsv');
    final passed = File('${directory.path}\\passed_case.txt');
    if (passed.existsSync()) {
      passed.copySync('${directory.path}\\passed_case.before-framework.txt');
    }
    results.writeAsStringSync(
      '${rows.map((row) => row.join('\t')).join('\n')}\n',
    );
    passed.writeAsStringSync(
      rows
          .where((row) => row[2] == 'PASS')
          .map((row) => '${row[1]}-${row[0]}\n')
          .join(),
    );
  }
}
