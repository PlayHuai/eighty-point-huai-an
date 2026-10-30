import 'package:eighty_point_huai_an/src/ui/components/card_visual.dart';
import 'package:eighty_point_huai_an/src/ui/components/design_icon.dart';
import 'package:eighty_point_huai_an/src/ui/responsive_breakpoints.dart';
import 'package:eighty_point_huai_an/src/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dark theme uses the design token palette and typography', () {
    final theme = AppTheme.dark;

    expect(theme.scaffoldBackgroundColor, DarkTokens.bgBase);
    expect(theme.colorScheme.primary, DarkTokens.goldPrimary);
    expect(theme.textTheme.headlineMedium?.fontSize, DarkTokens.fontSizeL2);
    expect(theme.textTheme.bodyMedium?.fontFamily, 'Inter');
    expect(theme.textTheme.bodyMedium?.fontFamilyFallback, ['NotoSansSC']);
    expect(DarkTokens.spacingS6, 32);
  });

  test(
    'design fonts and licenses are bundled for offline Web rendering',
    () async {
      for (final path in [
        'assets/fonts/Inter/Inter.ttf',
        'assets/fonts/Inter/OFL.txt',
        'assets/fonts/NotoSansSC/NotoSansSC.ttf',
        'assets/fonts/NotoSansSC/OFL.txt',
      ]) {
        expect((await rootBundle.load(path)).lengthInBytes, greaterThan(0));
      }
    },
  );

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

  test('all standard cards and jokers resolve to bundled artwork', () async {
    final standardSuits = CardSuit.values.where(
      (suit) => suit != CardSuit.joker,
    );
    final standardRanks = CardRank.values.where(
      (rank) => rank != CardRank.smallJoker && rank != CardRank.bigJoker,
    );

    for (final rank in standardRanks) {
      for (final suit in standardSuits) {
        final card = CardVisual(rank: rank, suit: suit);
        expect(
          card.assetPath,
          endsWith('${rank.assetName}_of_${suit.assetName}.png'),
        );
        await rootBundle.load(card.assetPath);
      }
    }
    for (final rank in [CardRank.smallJoker, CardRank.bigJoker]) {
      final card = CardVisual(rank: rank, suit: CardSuit.joker);
      expect(card.assetPath, 'assets/cards/${rank.assetName}.png');
      await rootBundle.load(card.assetPath);
    }
  });

  testWidgets('card artwork and indicators render at compact and desktop sizes', (
    tester,
  ) async {
    for (final width in [44.0, 120.0]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
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
      );
      await tester.pumpAndSettle();

      final image = tester.widget<Image>(
        find.descendant(
          of: find.byType(CardVisual),
          matching: find.byType(Image),
        ),
      );
      expect(
        (image.image as AssetImage).assetName,
        'assets/cards/5_of_hearts.png',
      );

      Rect badgeRect(Finder marker) => tester.getRect(
        find.descendant(of: marker, matching: find.byType(Container)).first,
      );

      final cardRect = tester.getRect(find.byType(CardVisual));
      final levelRect = badgeRect(find.byType(LevelCardHighlight));
      final redFiveRect = badgeRect(find.byType(RedFiveHighlight));
      final trumpRect = badgeRect(find.byType(TrumpCorner));

      expect(cardRect.contains(levelRect.topLeft), isTrue);
      expect(cardRect.contains(redFiveRect.bottomRight), isTrue);
      expect(cardRect.contains(trumpRect.bottomRight), isTrue);
      expect(levelRect.bottom, lessThanOrEqualTo(redFiveRect.top));
      expect(redFiveRect.bottom, lessThanOrEqualTo(trumpRect.top));
      expect(find.text('级牌'), findsOneWidget);
      expect(find.text('红五'), findsOneWidget);
      expect(find.byType(TrumpCorner), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
