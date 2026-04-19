import 'dart:async';

import 'package:flutter/material.dart';

/// Client-side countdown for the acceptance phase. Purely visual: the backend
/// doesn't enforce the timeout yet, so we just show the pressure — the user
/// can still accept/reject after 0.
class AcceptanceCountdown extends StatefulWidget {
  const AcceptanceCountdown({
    super.key,
    required this.since,
    this.seconds = 30,
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
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsed =
        DateTime.now().toUtc().difference(widget.since.toUtc()).inSeconds;
    final remaining = (widget.seconds - elapsed).clamp(0, widget.seconds);
    final low = remaining <= 10;
    return Text(
      '$remaining',
      style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: low
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
    );
  }
}
