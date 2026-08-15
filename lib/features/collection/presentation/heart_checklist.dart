import 'dart:math' as math;

import 'package:flutter/material.dart';

class HeartChecklist extends StatefulWidget {
  const HeartChecklist({
    super.key,
    required this.value,
    required this.semanticLabel,
    this.onChanged,
    this.color = const Color(0xFFFF5B89),
  });

  final bool value;
  final String semanticLabel;
  final ValueChanged<bool>? onChanged;
  final Color color;

  @override
  State<HeartChecklist> createState() => _HeartChecklistState();
}

class _HeartChecklistState extends State<HeartChecklist>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
    value: widget.value ? 1 : 0,
  );

  @override
  void didUpdateWidget(HeartChecklist oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.value && widget.value) {
      if (MediaQuery.disableAnimationsOf(context)) {
        _controller.value = 1;
      } else {
        _controller.forward(from: 0);
      }
    } else if (oldWidget.value && !widget.value) {
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _heartScale(double progress) {
    if (!widget.value) return 1;
    if (progress <= .25) return 1.2 * Curves.easeOut.transform(progress / .25);
    if (progress <= .5) {
      return 1.2 - .2 * Curves.easeInOut.transform((progress - .25) / .25);
    }
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onChanged != null;
    return Semantics(
      label: widget.semanticLabel,
      checked: widget.value,
      enabled: enabled,
      button: true,
      child: SizedBox.square(
        dimension: 50,
        child: InkResponse(
          onTap: enabled ? () => widget.onChanged!(!widget.value) : null,
          radius: 26,
          customBorder: const CircleBorder(),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final progress = _controller.value;
              final celebrationProgress = (progress * 2).clamp(0.0, 1.0);
              return Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  if (widget.value && celebrationProgress < 1)
                    CustomPaint(
                      size: const Size.square(50),
                      painter: _CelebrationPainter(
                        color: widget.color,
                        progress: celebrationProgress,
                      ),
                    ),
                  Transform.scale(
                    scale: _heartScale(progress),
                    child: CustomPaint(
                      size: const Size(30, 30),
                      painter: _HeartPainter(
                        color: enabled
                            ? widget.color
                            : widget.color.withValues(alpha: .45),
                        filled: widget.value,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HeartPainter extends CustomPainter {
  const _HeartPainter({
    required this.color,
    required this.filled,
  });

  final Color color;
  final bool filled;

  Path _heartPath(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, size.height * .88);
    path.cubicTo(
      size.width * .39,
      size.height * .78,
      size.width * .08,
      size.height * .57,
      size.width * .08,
      size.height * .30,
    );
    path.cubicTo(
      size.width * .08,
      size.height * .05,
      size.width * .39,
      0,
      size.width / 2,
      size.height * .22,
    );
    path.cubicTo(
      size.width * .61,
      0,
      size.width * .92,
      size.height * .05,
      size.width * .92,
      size.height * .30,
    );
    path.cubicTo(
      size.width * .92,
      size.height * .57,
      size.width * .61,
      size.height * .78,
      size.width / 2,
      size.height * .88,
    );
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      _heartPath(size),
      Paint()
        ..color = color
        ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_HeartPainter oldDelegate) =>
      color != oldDelegate.color || filled != oldDelegate.filled;
}

class _CelebrationPainter extends CustomPainter {
  const _CelebrationPainter({required this.color, required this.progress});

  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final scale = 1.4 * Curves.easeOut.transform(progress);
    final opacity = progress < .5 ? 1.0 : 2 * (1 - progress);
    final paint = Paint()
      ..color = color.withValues(alpha: opacity.clamp(0, 1))
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var index = 0; index < 6; index++) {
      final angle = -math.pi * .75 + index * (math.pi * 1.5 / 5);
      final direction = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        center + direction * (18 * scale),
        center + direction * (24 * scale),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_CelebrationPainter oldDelegate) =>
      color != oldDelegate.color || progress != oldDelegate.progress;
}
