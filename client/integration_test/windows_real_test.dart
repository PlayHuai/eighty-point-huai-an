import 'dart:io';

import 'package:eighty_point_huai_an/src/ui/room_chat_screen.dart';
import 'package:eighty_point_huai_an/src/api/request_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/cases.dart';
import 'support/case_results.dart';
import 'support/real_environment.dart';

Future<void> main() async {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // Avoid racing the native Windows IME when replacing an already-focused field.
  setUp(binding.testTextInput.register);
  tearDown(binding.testTextInput.unregister);
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
  if (uiOutputPath.isNotEmpty) {
    testWidgets('UI reference capture: real account and feature screens', (
      tester,
    ) async {
      final environment = RealEnvironment(tester);
      try {
        await environment.registerForm();
        await environment.waitFor(
          () => !environment.auth!.isLoading,
          'UI reference registration',
        );
        await environment.visible(find.text('游戏大厅'));
        await environment.captureUi('大厅');
        await environment.tap(find.text('创建房间'));
        await environment.visible(
          find.byKey(const ValueKey('create-room-dialog')),
        );
        await environment.captureUi('创建房间弹窗');
        await environment.tap(
          find.byKey(const ValueKey('create-room-private')),
        );
        await environment.visible(
          find.byKey(const ValueKey('create-room-password')),
        );
        await environment.captureUi('创建房间-密码房弹窗');
        await environment.tap(find.text('取消'));
        await environment.tap(find.text('修改密码'));
        await environment.visible(
          find.byKey(const ValueKey('password-current')),
        );
        await environment.captureUi('修改密码弹窗');
        await environment.tap(find.text('取消'));
        await environment.tap(find.text('房间号加入'));
        await environment.visible(find.text('通过房间号加入'));
        await environment.captureUi('房间号加入弹窗');
        await environment.tap(find.text('取消'));
        await environment.tap(find.text('反馈'));
        await environment.visible(find.byTooltip('关闭反馈'));
        await environment.captureUi('反馈弹窗');
        await environment.tap(find.text('问题'));
        await environment.visible(find.text('建议'));
        await environment.captureUi('反馈-类型选择菜单');
        await environment.tap(find.text('建议').last);
        await environment.tap(find.byTooltip('关闭反馈'));
        await environment.tap(find.text('关于'));
        await environment.visible(find.text('更新记录'));
        await environment.captureUi('关于与版本信息');
        await environment.tap(find.text('关闭'));
        await realCases['FRIEND-001']!(environment);
        final sender = environment.users.last;
        final recipient = environment.users[environment.users.length - 2];
        await environment.api.sendPrivateMessage(
          accessToken: sender.token,
          peerUserId: recipient.id,
          body: 'UI参考消息，仅用于消息操作菜单截图。',
          requestId: createRequestId(),
        );
        await environment.tap(find.byTooltip('聊天'));
        await environment.visible(
          find.byWidgetPredicate(
            (widget) =>
                widget is TextField && widget.decoration?.hintText == '输入消息',
          ),
        );
        await environment.captureUi('好友聊天');
        await environment.visible(find.byTooltip('消息操作'));
        await environment.tap(find.byTooltip('消息操作'));
        await environment.visible(find.text('举报消息'));
        await environment.captureUi('好友聊天-消息操作菜单');
        await tester.tapAt(const Offset(1, 1));
        await tester.pumpAndSettle();
        await tester.pageBack();
        await tester.pumpAndSettle();
        await tester.pageBack();
        await tester.pumpAndSettle();
        final search = find.byWidgetPredicate(
          (widget) =>
              widget is TextField && widget.decoration?.labelText == '搜索玩家',
        );
        await tester.enterText(search, '');
        await environment.tap(find.byTooltip('搜索'));
        final requester = await environment.user();
        await environment.api.sendFriendRequest(
          accessToken: requester.token,
          userId: recipient.id,
          requestId: createRequestId(),
        );
        await environment.tap(find.text('好友申请'));
        await environment.visible(find.text(requester.session.nickname));
        await environment.captureUi('好友申请列表');
        await realCases['ROOM-001']!(environment);
        await environment.visible(find.text('站起'));
        await environment.captureUi('房间等待入座');
        await environment.tap(find.text('成员'));
        await environment.visible(find.text('房间成员'));
        await environment.captureUi('房间成员弹窗');
        await environment.tap(find.text('关闭'));
        await environment.tap(find.text('房间聊天'));
        await environment.visible(find.byType(RoomChatScreen));
        await environment.captureUi('房间聊天');
      } catch (error, stack) {
        final uiDirectory = Directory(uiOutputPath)
          ..createSync(recursive: true);
        File('${uiDirectory.path}\\capture-error.txt')
            .writeAsStringSync('$error\n$stack\n', mode: FileMode.append);
        rethrow;
      } finally {
        await environment.close();
      }
    }, timeout: const Timeout(Duration(minutes: 3)));
  }
  if (const bool.fromEnvironment('AUTO_TEST_UI_ONLY')) {
    if (uiOutputPath.isEmpty) {
      throw StateError('AUTO_TEST_UI_ONLY requires AUTO_TEST_UI.');
    }
    return;
  }
  tearDownAll(() {
    reconcileFrameworkFailures(directory, binding.failureMethodsDetails);
  });
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
    }, timeout: Timeout(Duration(minutes: id == 'PRACTICE-004' ? 120 : 30)));
  }
}
