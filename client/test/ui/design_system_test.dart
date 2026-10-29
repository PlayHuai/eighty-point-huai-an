import 'package:eighty_point_huai_an/src/ui/components/card_visual.dart';
import 'package:eighty_point_huai_an/src/ui/components/design_icon.dart';
import 'package:eighty_point_huai_an/src/ui/responsive_breakpoints.dart';
import 'package:eighty_point_huai_an/src/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
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

  testWidgets('card visual composes level, red-five, and trump marks', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 44,
              child: CardVisual(
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
    );

    expect(find.text('级牌'), findsOneWidget);
    expect(find.text('红五'), findsOneWidget);
    expect(find.byType(TrumpCorner), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
