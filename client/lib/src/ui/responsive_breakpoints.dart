import 'package:flutter/widgets.dart';

enum ResponsiveSize { compact, medium, expanded }

typedef ResponsiveWidgetBuilder =
    Widget Function(
      BuildContext context,
      BoxConstraints constraints,
      ResponsiveSize size,
    );

abstract final class ResponsiveBreakpoints {
  static const compactMaxWidth = 600.0;
  static const mediumMaxWidth = 1024.0;

  static ResponsiveSize fromWidth(double width) => switch (width) {
    < compactMaxWidth => ResponsiveSize.compact,
    <= mediumMaxWidth => ResponsiveSize.medium,
    _ => ResponsiveSize.expanded,
  };
}

class ResponsiveLayoutBuilder extends StatelessWidget {
  const ResponsiveLayoutBuilder({required this.builder, super.key});

  final ResponsiveWidgetBuilder builder;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => builder(
      context,
      constraints,
      ResponsiveBreakpoints.fromWidth(constraints.maxWidth),
    ),
  );
}
