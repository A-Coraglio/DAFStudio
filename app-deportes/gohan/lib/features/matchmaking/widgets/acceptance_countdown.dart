import 'dart:async';

import 'package:flutter/material.dart';

/// Countdown for the acceptance phase. Backend enforces the timeout via
/// `ACCEPTANCE_TIMEOUT_SECONDS` and expires stale groups when the next
/// status poll runs. UI shows mm:ss so the 10-min window reads clearly.
class AcceptanceCountdown extends StatefulWidget {
  const AcceptanceCountdown({
    super.key,
    required this.since,
    this.seconds = 600,
  });

  final DateTime since;
  final int seconds;

  @override
  State<AcceptanceCountdown> createState() => _AcceptanceCountdownState();
}

class _AcceptanceCountdownState extends State<AcceptanceCountdown> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = DateTime.now()
        .toUtc()
        .difference(widget.since.toUtc())
        .inSeconds;
    final remaining = (widget.seconds - elapsed).clamp(0, widget.seconds);
    final low = remaining <= 60;
    return Text(
      _format(remaining),
      style: Theme.of(context).textTheme.displayLarge?.copyWith(
        color: low
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
