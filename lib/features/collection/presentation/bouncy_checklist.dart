import 'package:flutter/material.dart';

class BouncyChecklist extends StatefulWidget {
  const BouncyChecklist({
    super.key,
    required this.value,
    required this.semanticLabel,
    this.onChanged,
    this.color = const Color(0xFF7B68EE),
  });

  final bool value;
  final String semanticLabel;
  final ValueChanged<bool>? onChanged;
  final Color color;

  @override
  State<BouncyChecklist> createState() => _BouncyChecklistState();
}

class _BouncyChecklistState extends State<BouncyChecklist>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
    value: widget.value ? 1 : 0,
  );

  @override
  void didUpdateWidget(BouncyChecklist oldWidget) {
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

  double _bounce(double progress) {
    if (progress <= .2) return -10 * (progress / .2);
    if (progress <= .25) return -10 + 10 * ((progress - .2) / .05);
    if (progress <= .35) return -5 * ((progress - .25) / .1);
    if (progress <= .6) return -5 + 5 * ((progress - .35) / .25);
    return 0;
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
        dimension: 44,
        child: InkResponse(
          onTap: enabled ? () => widget.onChanged!(!widget.value) : null,
          radius: 24,
          customBorder: const CircleBorder(),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final progress = _controller.value;
              final borderWidth = widget.value && progress < .9 ? 2.0 : 4.0;
              final fillProgress = widget.value
                  ? Curves.elasticOut.transform((progress * 2).clamp(0, 1))
                  : 0.0;
              final innerSize = 34 * fillProgress;
              final innerLift = progress < .5
                  ? -150 * (progress / .5)
                  : -150 + 150 * ((progress - .5) / .5);
              return Center(
                child: Transform.translate(
                  offset: Offset(0, _bounce(progress)),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: enabled
                            ? widget.color
                            : widget.color.withValues(alpha: .45),
                        width: borderWidth,
                      ),
                    ),
                    child: Center(
                      child: Transform.translate(
                        offset: Offset(
                          0,
                          widget.value && progress < 1 ? innerLift : 0,
                        ),
                        child: Container(
                          width: innerSize,
                          height: innerSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.color,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
