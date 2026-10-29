import 'dart:ui' as ui;

import 'package:eighty_point_huai_an/src/ui/components/card_visual.dart';
import 'package:eighty_point_huai_an/src/ui/components/design_icon.dart';
import 'package:eighty_point_huai_an/src/ui/responsive_breakpoints.dart';
import 'package:eighty_point_huai_an/src/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dark theme uses the design token palette and typography', () {
    final theme = AppTheme.dark;

    expect(theme.scaffoldBackgroundColor, DarkTokens.bgBase);
    expect(theme.colorScheme.primary, DarkTokens.goldPrimary);
    expect(theme.textTheme.headlineMedium?.fontSize, DarkTokens.fontSizeL2);
    expect(DarkTokens.spacingS6, 32);
  });

  test('responsive breakpoints keep the specified boundary behavior', () {
    expect(
      ResponsiveBreakpoints.fromWidth(599),
      ResponsiveSize.compact,
    );
    expect(
      ResponsiveBreakpoints.fromWidth(600),
      ResponsiveSize.medium,
    );
    expect(
      ResponsiveBreakpoints.fromWidth(1024),
      ResponsiveSize.medium,
    );
    expect(
      ResponsiveBreakpoints.fromWidth(1025),
      ResponsiveSize.expanded,
    );
  });

  test('icon paths select the approved 32px state naming per icon', () {
    const login = DesignIcon(name: DesignIconName.login, enabled: true);
    const settings = DesignIcon(name: DesignIconName.settings, enabled: false);
    const back = DesignIcon(name: DesignIconName.back, enabled: true);

    expect(login.assetPath, 'assets/icons/ic_login/32xenabled.svg');
    expect(settings.assetPath, 'assets/icons/ic_settings/32xdisabled.svg');
    expect(back.assetPath, 'assets/icons/ic_back/state=enabled.svg');
  });

  test('all nested icon state assets are bundled', () async {
    for (final name in DesignIconName.values) {
      for (final enabled in [true, false]) {
        final icon = DesignIcon(name: name, enabled: enabled);
        await rootBundle.load(icon.assetPath);
      }
    }
  });

  testWidgets('card indicators remain visible at compact and desktop sizes', (
    tester,
  ) async {
    for (final width in [44.0, 120.0]) {
      final boundaryKey = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: RepaintBoundary(
                key: boundaryKey,
                child: SizedBox(
                  width: width,
                  child: const CardVisual(
                    rank: CardRank.five,
                    suit: CardSuit.hearts,
                    isLevelCard: true,
                    isRedFive: true,
                    trumpSuit: CardSuit.hearts,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(boundaryKey),
      );
      final boundaryRect = tester.getRect(find.byKey(boundaryKey));
      final image = await boundary.toImage();
      final pixels = (await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!;

      Color pixelAt(Offset globalPosition) {
        final x = (globalPosition.dx - boundaryRect.left).floor();
        final y = (globalPosition.dy - boundaryRect.top).floor();
        final offset = (y * image.width + x) * 4;
        return Color.fromARGB(
          pixels.getUint8(offset + 3),
          pixels.getUint8(offset),
          pixels.getUint8(offset + 1),
          pixels.getUint8(offset + 2),
        );
      }

      Rect badgeRect(Finder marker) => tester.getRect(
        find.descendant(of: marker, matching: find.byType(Container)).first,
      );

      final rankRect = tester.getRect(find.text('5'));
      final levelRect = badgeRect(find.byType(LevelCardHighlight));
      final redFiveRect = badgeRect(find.byType(RedFiveHighlight));
      final trumpRect = badgeRect(find.byType(TrumpCorner));

      for (final marker in [levelRect, redFiveRect, trumpRect]) {
        expect(rankRect.overlaps(marker), isFalse);
      }
      expect(levelRect.overlaps(redFiveRect), isFalse);
      expect(levelRect.overlaps(trumpRect), isFalse);
      expect(redFiveRect.overlaps(trumpRect), isFalse);

      expect(
        pixelAt(Offset(levelRect.left + 1, levelRect.center.dy)),
        DarkTokens.goldDark,
      );
      expect(
        pixelAt(Offset(redFiveRect.left + 1, redFiveRect.center.dy)),
        DarkTokens.redAccent,
      );
      expect(
        pixelAt(Offset(trumpRect.left + 1, trumpRect.center.dy)),
        DarkTokens.goldPrimary,
      );

      var rankPixelCount = 0;
      for (var y = rankRect.top.floor(); y < rankRect.bottom.ceil(); y++) {
        for (var x = rankRect.left.floor(); x < rankRect.right.ceil(); x++) {
          if (pixelAt(Offset(x + 0.5, y + 0.5)) == DarkTokens.suitRed) {
            rankPixelCount++;
          }
        }
      }
      expect(rankPixelCount, greaterThan(0));
      expect(find.text('级牌'), findsOneWidget);
      expect(find.text('红五'), findsOneWidget);
      expect(find.byType(TrumpCorner), findsOneWidget);
      expect(tester.takeException(), isNull);

      image.dispose();
    }
  });
}
