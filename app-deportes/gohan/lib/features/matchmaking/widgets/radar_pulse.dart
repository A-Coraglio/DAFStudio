import 'package:flutter/material.dart';

/// Expanding concentric circles behind [child] — gives the queue screen a
/// "scanning" feel instead of a static timer.
class RadarPulse extends StatefulWidget {
  const RadarPulse({super.key, required this.child, this.size = 220});

  final Widget child;
  final double size;

  @override
  State<RadarPulse> createState() => _RadarPulseState();
}

class _RadarPulseState extends State<RadarPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Stack(
          alignment: Alignment.center,
          children: [
            for (var i = 0; i < 3; i++)
              _ring(color, (_ctrl.value + i / 3) % 1.0),
            child!,
          ],
        ),
        child: Center(child: widget.child),
      ),
    );
  }

  Widget _ring(Color color, double progress) {
    return Container(
      width: widget.size * progress,
      height: widget.size * progress,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: (1 - progress) * .4),
          width: 2,
        ),
      ),
    );
  }
}
