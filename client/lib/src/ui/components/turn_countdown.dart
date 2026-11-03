import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class TurnCountdown extends StatefulWidget {
  const TurnCountdown({required this.deadline, this.serverTime, super.key});

  final DateTime deadline;
  final DateTime? serverTime;

  @override
  State<TurnCountdown> createState() => _TurnCountdownState();
}

class _TurnCountdownState extends State<TurnCountdown> {
  late Duration _offset;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _syncClock();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) setState(() {});
    });
  }

  void _syncClock() {
    _offset = widget.serverTime?.difference(DateTime.now()) ?? Duration.zero;
  }

  @override
  void didUpdateWidget(TurnCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.serverTime != oldWidget.serverTime) _syncClock();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final milliseconds = widget.deadline
        .difference(DateTime.now().add(_offset))
        .inMilliseconds;
    final seconds = math.max(0, (milliseconds / 1000).ceil());
    return Semantics(
      label: '本轮剩余 $seconds 秒，超时以服务端为准',
      child: Container(
        padding: const EdgeInsets.all(DarkTokens.spacingS1),
        decoration: BoxDecoration(
          border: Border.all(color: DarkTokens.goldPrimary),
          borderRadius: BorderRadius.circular(DarkTokens.radiusBadge),
        ),
        child: Text(
          '${seconds}s',
          style: const TextStyle(
            color: DarkTokens.goldBright,
            fontSize: DarkTokens.fontSizeL5,
          ),
        ),
      ),
    );
  }
}
