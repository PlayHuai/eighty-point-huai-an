import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class DesignPanel extends StatelessWidget {
  const DesignPanel({
    required this.child,
    this.padding = const EdgeInsets.all(DarkTokens.spacingS4),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: DarkTokens.bgPanel,
      borderRadius: BorderRadius.circular(DarkTokens.radiusPanel),
    ),
    child: child,
  );
}
