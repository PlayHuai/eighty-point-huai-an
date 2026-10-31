import 'dart:async';

import 'package:eighty_point_huai_an/src/api/lobby_models.dart';
import 'package:eighty_point_huai_an/src/api/player_models.dart';
import 'package:eighty_point_huai_an/src/ui/create_room_dialog.dart';
import 'package:eighty_point_huai_an/src/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _hall = LobbyHall(
  id: 'ordinary',
  name: '普通大厅',
  minimumPoints: 0,
  maximumPoints: 9999,
  multiplier: 1,
);

const _statistics = PlayerStatistics(
  totalGames: 0,
  wins: 0,
  losses: 0,
  points: 800,
  rank: '青铜',
);

Finder _key(String name) => find.byKey(ValueKey('create-room-$name'));

Finder get _panel => find.descendant(
  of: find.byType(AlertDialog),
  matching: find.byWidgetPredicate(
    (widget) => widget is Material && widget.type == MaterialType.card,
  ),
);

Future<void> _openDialog(
  WidgetTester tester, {
  LobbyHall hall = _hall,
  AsyncValue<PlayerStatistics?> statistics = const AsyncData(_statistics),
  Future<void> Function(String, String, bool, int)? onCreate,
  VoidCallback? onRetryStatistics,
  double textScale = 1,
  Size? surfaceSize = const Size(1440, 900),
}) async {
  await tester.binding.setSurfaceSize(surfaceSize);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (_) => CreateRoomDialog(
                hall: hall,
                statistics: statistics,
                onRetryStatistics: onRetryStatistics ?? () {},
                onCreate: onCreate ?? (_, _, _, _) async {},
              ),
            ),
            child: const Text('打开'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('打开'));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final (family, asset) in [
      ('Inter', 'assets/fonts/Inter/Inter.ttf'),
      ('NotoSansSC', 'assets/fonts/NotoSansSC/NotoSansSC.ttf'),
    ]) {
      await (FontLoader(family)..addFont(rootBundle.load(asset))).load();
    }
  });

  testWidgets('desktop panel matches design width, group gaps, and actions', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _openDialog(tester);
    await tester.tap(_key('private'));
    await tester.pumpAndSettle();

    final dialog = tester.getRect(_panel);
    final password = tester.getRect(_key('password'));
    final pointsLabel = tester.getRect(find.text('最低准入积分门槛'));
    final points = tester.getRect(_key('minimum-points'));
    final spectatorsLabel = tester.getRect(find.text('是否允许观战'));
    final hint = tester.getRect(find.text('房间门槛须 ≤ 当前大厅上限：9999 分。'));
    final cancel = tester.getRect(find.widgetWithText(OutlinedButton, '取消'));
    final create = tester.getRect(find.widgetWithText(FilledButton, '创建'));

    expect(dialog.width, 520);
    expect(dialog.center, const Offset(720, 450));
    expect(password.left - dialog.left, DarkTokens.spacingS5);
    expect(pointsLabel.top - password.bottom, DarkTokens.spacingS5);
    expect(points.top - pointsLabel.bottom, DarkTokens.spacingS2);
    expect(spectatorsLabel.top - hint.bottom, DarkTokens.spacingS5);
    expect(cancel.width, create.width);
    expect(create.left - cancel.right, DarkTokens.spacingS3);
    expect(cancel.height, DarkTokens.spacingS5 * 2);
    expect(create.height, cancel.height);
    expect(find.text('私密房间'), findsOneWidget);
    expect(find.text('入场密码'), findsOneWidget);
    expect(find.byTooltip('关闭'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final (size, textScale) in [
    (const Size(320, 568), 1.0),
    (const Size(390, 320), 1.0),
    (const Size(1440, 900), 2.0),
  ]) {
    testWidgets(
      'dialog stays usable at $size with text scale $textScale',
      (tester) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await _openDialog(tester, textScale: textScale, surfaceSize: size);
        await tester.ensureVisible(_key('private'));
        await tester.tap(_key('private'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(_key('password'));
        await tester.enterText(_key('password'), 'secret');
        await tester.ensureVisible(_key('minimum-points'));
        await tester.enterText(_key('minimum-points'), '100');
        await tester.ensureVisible(_key('spectators'));
        await tester.tap(_key('spectators'));
        await tester.pumpAndSettle();

        final dialog = tester.getRect(_panel);
        expect(dialog.left, greaterThanOrEqualTo(DarkTokens.spacingS4));
        expect(
          dialog.right,
          lessThanOrEqualTo(size.width - DarkTokens.spacingS4),
        );
        expect(dialog.bottom, lessThanOrEqualTo(size.height));
        final cancel = find.widgetWithText(OutlinedButton, '取消');
        expect(cancel.hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(cancel);
        await tester.pumpAndSettle();
        expect(find.byType(CreateRoomDialog), findsNothing);
      },
      variant: TargetPlatformVariant({
        TargetPlatform.iOS,
        TargetPlatform.windows,
      }),
    );
  }

  testWidgets('keyboard insets leave a scrollable form and visible actions', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(null);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await _openDialog(tester, surfaceSize: null);
    await tester.tap(_key('private'));
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    await tester.pumpAndSettle();
    await tester.ensureVisible(_key('password'));
    await tester.enterText(_key('password'), 'secret');
    await tester.ensureVisible(_key('minimum-points'));
    await tester.enterText(_key('minimum-points'), '100');
    await tester.pumpAndSettle();

    expect(
      tester.getBottomRight(_panel).dy,
      lessThanOrEqualTo(844 - 320 - DarkTokens.spacingS4),
    );
    expect(
      find.widgetWithText(OutlinedButton, '取消').hitTestable(),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('public rooms do not submit a hidden private password', (
    tester,
  ) async {
    final calls = <(String, String, bool, int)>[];
    await _openDialog(
      tester,
      onCreate: (name, password, spectators, points) async {
        calls.add((name, password, spectators, points));
      },
    );
    expect(_key('password'), findsNothing);
    await tester.enterText(_key('name'), ' 测试房间 ');
    await tester.tap(_key('private'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, '创建'))
          .onPressed,
      isNull,
    );
    await tester.enterText(_key('password'), 'secret');
    await tester.tap(_key('private'));
    await tester.pumpAndSettle();
    await tester.enterText(_key('minimum-points'), '100');
    await tester.ensureVisible(_key('spectators'));
    await tester.tap(_key('spectators'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '创建'));
    await tester.pumpAndSettle();
    expect(calls, [('测试房间', '', true, 100)]);
  });

  testWidgets('invalid or unaffordable points show inline errors', (
    tester,
  ) async {
    await _openDialog(tester);
    await tester.enterText(_key('name'), '测试房间');
    for (final (input, message) in [
      ('-1', '最低准入积分必须是非负整数。'),
      ('abc', '最低准入积分必须是非负整数。'),
      ('10000', '最低准入积分不能超过当前大厅上限（9999 分）。'),
      ('1200', '当前积分 800，不满足 1200 的门槛要求。'),
    ]) {
      await tester.enterText(_key('minimum-points'), input);
      await tester.pumpAndSettle();
      expect(find.text(message), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, '创建'))
            .onPressed,
        isNull,
      );
    }
    await tester.enterText(_key('minimum-points'), '800');
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, '创建'))
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('pending submission prevents duplicate actions and dismissal', (
    tester,
  ) async {
    final pending = Completer<void>();
    var calls = 0;
    await _openDialog(
      tester,
      onCreate: (_, _, _, _) {
        calls++;
        return pending.future;
      },
    );
    await tester.enterText(_key('name'), '测试房间');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '创建'));
    await tester.pump();
    expect(calls, 1);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, '创建中…'))
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<IconButton>(
            find.byWidgetPredicate(
              (widget) => widget is IconButton && widget.tooltip == '关闭',
            ),
          )
          .onPressed,
      isNull,
    );
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(CreateRoomDialog), findsOneWidget);
    pending.complete();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('关闭'));
    await tester.pumpAndSettle();
    expect(find.byType(CreateRoomDialog), findsNothing);
  });

  testWidgets('friend rooms retain invitation-only settings', (tester) async {
    final calls = <(String, String, bool, int)>[];
    await _openDialog(
      tester,
      hall: const LobbyHall(
        id: friendRoomHallId,
        name: '好友房',
        minimumPoints: 0,
        maximumPoints: 0,
        multiplier: 1,
      ),
      onCreate: (name, password, spectators, points) async {
        calls.add((name, password, spectators, points));
      },
    );
    expect(find.byType(Switch), findsNothing);
    expect(_key('minimum-points'), findsNothing);
    await tester.enterText(_key('name'), '好友局');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '创建'));
    await tester.pumpAndSettle();
    expect(calls, [('好友局', '', false, 0)]);
  });

  testWidgets('statistics failures are visible and can be retried', (
    tester,
  ) async {
    var retries = 0;
    await _openDialog(
      tester,
      statistics: AsyncError(StateError('offline'), StackTrace.current),
      onRetryStatistics: () => retries++,
    );
    final retry = find.text('当前积分加载失败，点击重试；准入以服务端为准。');
    await tester.ensureVisible(retry);
    await tester.tap(retry);
    expect(retries, 1);
  });
}
