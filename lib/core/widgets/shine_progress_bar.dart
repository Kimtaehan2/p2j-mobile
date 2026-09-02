import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 빛나는 진행률 바.
///
/// 채워진 부분 위로 옅은 노랑 줄무늬가 계속 흘러간다. 정지된 막대는 그냥
/// 수치지만, 흐르는 줄무늬는 지금도 쌓이고 있다는 느낌을 준다.
/// 성취를 보여주는 게 이 앱의 핵심이라 여기에만 쓴다.
class ShineProgressBar extends StatefulWidget {
  const ShineProgressBar({
    required this.value,
    this.height = 10,
    this.trackColor = AppColors.espressoFill,
    this.fillColor = AppColors.gold,
    this.stripeColor = AppColors.goldPale,
    this.glow = false,
    super.key,
  });

  /// 0.0 ~ 1.0.
  final double value;
  final double height;
  final Color trackColor;
  final Color fillColor;
  final Color stripeColor;

  /// 채운 만큼 빛을 흘릴지. 어두운 바탕에서만 보인다.
  final bool glow;

  @override
  State<ShineProgressBar> createState() => _ShineProgressBarState();
}

class _ShineProgressBarState extends State<ShineProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clamped = widget.value.clamp(0.0, 1.0);
    final radius = BorderRadius.circular(widget.height / 2);

    return SizedBox(
      height: widget.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            // 채움에서 새어 나오는 빛을 자르지 않는다.
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: radius,
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: widget.height,
                  child: ColoredBox(color: widget.trackColor),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 360),
                curve: Curves.easeOutCubic,
                width: constraints.maxWidth * clamped,
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: radius,
                  boxShadow: clamped == 0 || !widget.glow
                      ? null
                      : [
                          BoxShadow(
                            color: widget.fillColor.withValues(alpha: 0.45),
                            blurRadius: 14,
                          ),
                        ],
                ),
                child: ClipRRect(
                  borderRadius: radius,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) => CustomPaint(
                      painter: _StripePainter(
                        phase: _controller.value,
                        fillColor: widget.fillColor,
                        stripeColor: widget.stripeColor,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 기울어진 줄무늬를 그리고 매 프레임 옆으로 민다.
class _StripePainter extends CustomPainter {
  const _StripePainter({
    required this.phase,
    required this.fillColor,
    required this.stripeColor,
  });

  /// 0.0 ~ 1.0. 한 주기가 줄무늬 하나 폭만큼 이동한다.
  final double phase;
  final Color fillColor;
  final Color stripeColor;

  static const double _stripeWidth = 9;
  static const double _gap = 11;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = fillColor);

    const period = _stripeWidth + _gap;
    final shift = phase * period;
    final paint = Paint()..color = stripeColor;

    // 45도로 기울이면 높이만큼 x 가 밀리므로 그만큼 왼쪽에서부터 그린다.
    for (var x = -size.height - period; x < size.width + period; x += period) {
      final left = x + shift;
      final path = Path()
        ..moveTo(left, size.height)
        ..lineTo(left + size.height, 0)
        ..lineTo(left + size.height + _stripeWidth, 0)
        ..lineTo(left + _stripeWidth, size.height)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_StripePainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.fillColor != fillColor ||
      oldDelegate.stripeColor != stripeColor;
}
