import 'dart:async';

import 'package:flutter/material.dart';

/// Big live "mm:ss" counter that ticks every second from [since].
class QueueTimer extends StatefulWidget {
  const QueueTimer({super.key, required this.since});

  final DateTime since;

  @override
  State<QueueTimer> createState() => _QueueTimerState();
}

class _QueueTimerState extends State<QueueTimer> {
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

  String _format(Duration d) {
    final mm = d.inMinutes.toString().padLeft(2, '0');
    final ss = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = DateTime.now().toUtc().difference(widget.since.toUtc());
    return Text(
      _format(elapsed.isNegative ? Duration.zero : elapsed),
      style: Theme.of(context).textTheme.displayMedium,
    );
  }
}
