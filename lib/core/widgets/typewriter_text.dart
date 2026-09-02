import 'package:flutter/material.dart';

/// 글자를 하나씩 흘려 보여주는 텍스트.
///
/// 앱이 말을 거는 느낌을 만든다. 타이핑 도중 줄바꿈 위치가 바뀌면 글자가
/// 튀어 보이므로, 완성된 문장을 투명하게 깔아 자리를 미리 잡아 둔다.
class TypewriterText extends StatefulWidget {
  const TypewriterText({
    required this.text,
    this.style,
    this.textAlign,
    this.charDelay = const Duration(milliseconds: 55),
    this.startDelay = Duration.zero,
    this.onCompleted,
    super.key,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  /// 글자 하나당 걸리는 시간.
  final Duration charDelay;

  /// 첫 글자가 나오기 전 뜸.
  final Duration startDelay;

  final VoidCallback? onCompleted;

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<int> _visibleChars;
  bool _notified = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this)
      ..addStatusListener(_handleStatus);
    _retarget();
    _start();
  }

  /// 문장이 바뀌면 처음부터 다시 친다.
  /// 같은 자리에 다른 문장이 오면 State 가 재사용되므로 여기서 맞춰 줘야 한다.
  @override
  void didUpdateWidget(TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text == widget.text) return;
    _notified = false;
    _controller.reset();
    _retarget();
    _start();
  }

  void _retarget() {
    _controller.duration = widget.charDelay * widget.text.length;
    _visibleChars = StepTween(
      begin: 0,
      end: widget.text.length,
    ).animate(_controller);
  }

  Future<void> _start() async {
    if (widget.startDelay > Duration.zero) {
      await Future<void>.delayed(widget.startDelay);
      if (!mounted) return;
    }
    _controller.forward();
  }

  void _handleStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || _notified) return;
    _notified = true;
    widget.onCompleted?.call();
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_handleStatus)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: 0,
          child: Text(
            widget.text,
            style: widget.style,
            textAlign: widget.textAlign,
          ),
        ),
        // 자리표시자와 같은 폭을 차지해야 textAlign 이 의도대로 먹는다.
        // 자기 폭에만 맞추면 가운데 정렬이 왼쪽 정렬처럼 보인다.
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _visibleChars,
            builder: (context, _) => Text(
              // 애니메이션 값이 문장 길이를 넘지 않게 한 번 더 막는다.
              widget.text.substring(
                0,
                _visibleChars.value.clamp(0, widget.text.length),
              ),
              style: widget.style,
              textAlign: widget.textAlign,
            ),
          ),
        ),
      ],
    );
  }
}

/// 타이핑이 끝난 뒤 아래에서 부드럽게 올라오는 래퍼.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({
    required this.visible,
    required this.child,
    this.duration = const Duration(milliseconds: 280),
    super.key,
  });

  final bool visible;
  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: visible ? Offset.zero : const Offset(0, 0.15),
      duration: duration,
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: duration,
        curve: Curves.easeOut,
        child: child,
      ),
    );
  }
}
