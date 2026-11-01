import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/cases.dart';
import 'support/real_environment.dart';

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const catalogPath = String.fromEnvironment('AUTO_TEST_CATALOG');
  const selectedPath = String.fromEnvironment('AUTO_TEST_SELECTION');
  const roundPath = String.fromEnvironment('AUTO_TEST_ROUND');
  if ([
    catalogPath,
    selectedPath,
    roundPath,
    apiEndpointValue,
    websocketEndpointValue,
  ].any((value) => value.isEmpty)) {
    throw StateError(
      'Explicit catalog, selection, round and both endpoints are required.',
    );
  }
  final selected = File(selectedPath)
      .readAsLinesSync()
      .map((line) => RegExp(r'^([A-Z]+-\d+)\b').firstMatch(line)?.group(1))
      .whereType<String>()
      .toSet();
  final rows = File(catalogPath)
      .readAsLinesSync()
      .skip(1)
      .where((line) => line.trim().isNotEmpty)
      .map((line) => line.split('\t'))
      .toList();
  final ids = rows.map((row) => row.first).toSet();
  if (selected.isEmpty || !ids.containsAll(selected)) {
    throw StateError(
      'Empty selection or unknown case IDs: ${selected.difference(ids)}',
    );
  }
  final directory = Directory(roundPath)..createSync(recursive: true);
  var serverUnavailable = false;
  for (final row in rows.where((row) => selected.contains(row.first))) {
    final id = row[0];
    final title = row[1];
    final state = row[2];
    final issue = Directory('${directory.path}\\issues\\$title-$id');
    testWidgets('$id $title', (tester) async {
      final environment = RealEnvironment(tester);
      String status = 'FAIL';
      Object? failure;
      StackTrace? failureStack;
      try {
        if (state != 'READY' || serverUnavailable) {
          status = state == 'TODO' ? 'TODO' : 'BLOCKED';
          issue.createSync(recursive: true);
          File('${issue.path}\\issue.txt').writeAsStringSync(
            '$id\t$title\n$status\n${serverUnavailable ? '服务不可用，停止执行后续用例，需先修复环境。' : row[4]}\n',
          );
        } else {
          final body = realCases[id];
          if (body == null)
            throw StateError('READY case has no implementation: $id');
          await body(environment);
          await tester.pump();
          final flutterError = tester.takeException();
          if (flutterError != null) throw flutterError;
          status = 'PASS';
        }
      } catch (error, stack) {
        failure = error;
        failureStack = stack;
        issue.createSync(recursive: true);
        File('${issue.path}\\issue.txt').writeAsStringSync(
          '$id\t$title\nFAIL\nAPI_ENDPOINT=$apiEndpointValue\n'
          'WEBSOCKET_ENDPOINT=$websocketEndpointValue\n'
          '${row[4]}\n$error\n$stack\n${environment.trace}',
        );
        try {
          await environment.screenshot('${issue.path}\\page.png');
        } catch (captureError) {
          File(
            '${issue.path}\\issue.txt',
          ).writeAsStringSync('\n截图失败：$captureError\n', mode: FileMode.append);
        }
        final http = HttpClient()
          ..connectionTimeout = const Duration(seconds: 5);
        try {
          final response = await (await http.getUrl(
            Uri.parse('http://${apiEndpoint.host}:8080/healthz'),
          )).close().timeout(const Duration(seconds: 5));
          serverUnavailable = response.statusCode != HttpStatus.noContent;
          await response.drain<void>();
        } catch (healthError) {
          serverUnavailable = true;
          File(
            '${issue.path}\\issue.txt',
          ).writeAsStringSync('\n健康检查失败：$healthError\n', mode: FileMode.append);
        } finally {
          http.close(force: true);
        }
      } finally {
        try {
          await environment.close();
        } catch (cleanupError, cleanupStack) {
          status = 'FAIL';
          failure ??= cleanupError;
          failureStack ??= cleanupStack;
          issue.createSync(recursive: true);
          File('${issue.path}\\issue.txt').writeAsStringSync(
            '$id\t$title\n清理失败：$cleanupError\n$cleanupStack\n',
            mode: FileMode.append,
          );
        }
        File('${directory.path}\\results.tsv')
            .writeAsStringSync('$id\t$title\t$status\n', mode: FileMode.append);
        if (status == 'PASS') {
          File('${directory.path}\\passed_case.txt')
              .writeAsStringSync('$title-$id\n', mode: FileMode.append);
        }
      }
      if (failure != null) Error.throwWithStackTrace(failure, failureStack!);
    }, timeout: const Timeout(Duration(minutes: 15)));
  }
}
