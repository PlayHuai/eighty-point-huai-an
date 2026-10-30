import 'dart:ui';

import 'package:eighty_point_huai_an/src/ui/components/card_visual.dart';
import 'package:eighty_point_huai_an/src/ui/components/table_cards.dart';
import 'package:eighty_point_huai_an/src/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const cards = ['hearts:5:0', 'spades:14:1'];

  Widget app(Widget child) => MaterialApp(
    theme: AppTheme.dark,
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('private bottom cards are hidden until tap or hover', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        const SizedBox(
          width: 260,
          child: BottomCardsPanel(cards: cards, publiclyRevealed: false),
        ),
      ),
    );
    expect(find.byType(CardBack), findsNWidgets(2));
    expect(find.byType(CardVisual), findsNothing);
    await tester.tap(find.byKey(const ValueKey('bottom-cards-panel')));
    await tester.pump();
    expect(find.byType(CardVisual), findsNWidgets(2));
    await tester.tap(find.byKey(const ValueKey('bottom-cards-panel')));
    await tester.pump();
    expect(find.byType(CardVisual), findsNothing);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(
      tester.getCenter(find.byKey(const ValueKey('bottom-cards-panel'))),
    );
    await tester.pump();
    expect(find.byType(CardVisual), findsNWidgets(2));
    await mouse.moveTo(Offset.zero);
    await tester.pump();
    expect(find.byType(CardVisual), findsNothing);
    await mouse.removePointer();
  });

  testWidgets('public bottom stays face up without interaction', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        const SizedBox(
          width: 260,
          child: BottomCardsPanel(cards: cards, publiclyRevealed: true),
        ),
      ),
    );
    expect(find.byType(CardVisual), findsNWidgets(2));
    await tester.tap(find.byKey(const ValueKey('bottom-cards-panel')));
    await tester.pump();
    expect(find.byType(CardBack), findsNothing);
  });

  for (final width in [320.0, 1440.0]) {
    testWidgets('hand selection and hidden cards fit $width', (tester) async {
      await tester.binding.setSurfaceSize(Size(width, 400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final selected = <String>[];
      await tester.pumpWidget(
        app(
          SizedBox(
            height: 150,
            child: TableHand(
              cards: cards,
              selected: const {},
              hiddenCount: 0,
              onSelect: selected.add,
            ),
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('hand-card-spades:14:1')));
      expect(selected, ['spades:14:1']);
      await tester.pumpWidget(
        app(
          const SizedBox(
            height: 150,
            child: TableHand(
              cards: [],
              selected: {},
              hiddenCount: 25,
              onSelect: null,
            ),
          ),
        ),
      );
      expect(find.byType(CardBack), findsNWidgets(25));
      expect(find.byType(CardVisual), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
