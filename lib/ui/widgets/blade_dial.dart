import 'dart:math';
import 'package:aeroflow/ui/interaction_lock.dart';
import 'package:flutter/material.dart';

class BladeDial extends StatefulWidget {
  final double value;
  final double max;
  final ValueChanged<double>? onChanged;
  final Color color;

  const BladeDial({
    super.key,
    required this.value,
    this.max = 90,
    this.onChanged,
    this.color = const Color(0xFF7A5FFF),
  });

  @override
  State<BladeDial> createState() => _BladeDialState();
}

class _BladeDialState extends State<BladeDial> {
  void _onPan(Offset localPosition, Size size) {
    if (widget.onChanged == null) return;
    final center = Offset(size.width / 2, size.height / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    var angle = atan2(dy, dx) * 180 / pi + 90;
    if (angle < 0) angle += 360;
    final mapped = (angle / 360 * widget.max).clamp(0.0, widget.max);
    widget.onChanged!(mapped);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = min(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,

          onPanStart: (_) {
            isInteractingNotifier.value = true;
          },

          onPanEnd: (_) {
            isInteractingNotifier.value = false;
          },

          onPanCancel: () {
            isInteractingNotifier.value = false;
          },

          onPanUpdate: (details) {
            _onPan(details.localPosition, Size(size, size));
          },

          onTapDown: (details) {
            isInteractingNotifier.value = true;

            _onPan(details.localPosition, Size(size, size));
          },

          onTapUp: (_) {
            isInteractingNotifier.value = false;
          },

          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _DialPainter(
                value: widget.value,
                max: widget.max,
                color: widget.color,
                disabled: widget.onChanged == null,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DialPainter extends CustomPainter {
  final double value;
  final double max;
  final Color color;
  final bool disabled;

  _DialPainter({
    required this.value,
    required this.max,
    required this.color,
    required this.disabled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final opacity = disabled ? 0.3 : 1.0;

    // Outer ring background
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFF21262D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );

    // Value arc
    final sweepAngle = (value / max) * 2 * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );

    // Glow
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      Paint()
        ..color = color.withValues(alpha: 0.15 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Tick marks
    for (int i = 0; i < 12; i++) {
      final tickAngle = (i / 12) * 2 * pi - pi / 2;
      final inner =
          center + Offset(cos(tickAngle), sin(tickAngle)) * (radius - 10);
      final outer =
          center + Offset(cos(tickAngle), sin(tickAngle)) * (radius - 6);
      canvas.drawLine(
        inner,
        outer,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.15)
          ..strokeWidth = 1,
      );
    }

    // Needle
    final needleAngle = (value / max) * 2 * pi - pi / 2;
    final needleEnd =
        center + Offset(cos(needleAngle), sin(needleAngle)) * (radius - 14);
    canvas.drawLine(
      center,
      needleEnd,
      Paint()
        ..color = color.withValues(alpha: opacity)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    // Center dot
    canvas.drawCircle(
      center,
      3,
      Paint()..color = color.withValues(alpha: opacity),
    );
  }

  @override
  bool shouldRepaint(covariant _DialPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.disabled != disabled;
  }
}
