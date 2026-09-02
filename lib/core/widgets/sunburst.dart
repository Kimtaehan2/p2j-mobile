import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 한 점에서 뻗어 나와 천천히 도는 빛살.
///
/// 트로피 뒤에 깔리는 방사형 배경과 같은 원리다. 성취를 축하하는 화면
/// 하나에만 쓴다. 여러 곳에 쓰면 눈이 쉴 곳이 없어진다.
class Sunburst extends StatefulWidget {
  const Sunburst({
    this.rayCount = 10,
    this.center = const Alignment(0, -0.15),
    this.rayColor = AppColors.goldRay,
    this.baseColor = AppColors.goldBase,
    this.glowColor = AppColors.goldLight,
    this.period = const Duration(seconds: 20),
    super.key,
  });

  /// 빛살 개수. 빛살과 사이가 번갈아 나오므로 실제 조각은 두 배다.
  final int rayCount;

  /// 빛이 모이는 지점. 큰 숫자 뒤에 오도록 잡는다.
  final Alignment center;

  final Color rayColor;
  final Color baseColor;
  final Color glowColor;

  /// 한 바퀴 도는 데 걸리는 시간.
  final Duration period;

  @override
  State<Sunburst> createState() => _SunburstState();
}

class _SunburstState extends State<Sunburst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: widget.baseColor),
        // 빛살은 옅게 깐다. 진하게 그리면 바람개비처럼 보이고
        // 그 위에 올라갈 숫자와 싸운다.
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _RayPainter(
              turns: _controller.value,
              rayCount: widget.rayCount,
              center: widget.center,
              rayColor: widget.rayColor.withValues(alpha: 0.4),
            ),
            child: const SizedBox.expand(),
          ),
        ),
        // 빛살이 시작하는 한 점을 덮어 없앤다. 광원이 뭉개져야 빛처럼 보인다.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: widget.center,
              radius: 0.85,
              colors: [
                widget.glowColor,
                widget.glowColor.withValues(alpha: 0),
              ],
              stops: const [0.05, 1],
            ),
          ),
        ),
      ],
    );
  }
}

class _RayPainter extends CustomPainter {
  const _RayPainter({
    required this.turns,
    required this.rayCount,
    required this.center,
    required this.rayColor,
  });

  final double turns;
  final int rayCount;
  final Alignment center;
  final Color rayColor;

  @override
  void paint(Canvas canvas, Size size) {
    final origin = center.alongSize(size);
    // 모서리까지 확실히 덮도록 대각선보다 길게 뻗는다.
    final radius = size.width + size.height;
    final sweep = math.pi / rayCount;

    canvas
      ..save()
      ..translate(origin.dx, origin.dy)
      ..rotate(turns * 2 * math.pi);

    final paint = Paint()..color = rayColor;
    final bounds = Rect.fromCircle(center: Offset.zero, radius: radius);
    for (var i = 0; i < rayCount; i++) {
      final path = Path()
        ..moveTo(0, 0)
        ..arcTo(bounds, i * 2 * sweep, sweep, false)
        ..close();
      canvas.drawPath(path, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_RayPainter oldDelegate) =>
      oldDelegate.turns != turns ||
      oldDelegate.rayCount != rayCount ||
      oldDelegate.rayColor != rayColor;
}
