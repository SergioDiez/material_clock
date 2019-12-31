import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedNumber extends StatefulWidget {
  const AnimatedNumber({Key key, this.x, this.y, this.numberDisplayed})
      : super(key: key);

  final double x;
  final double y;
  final String numberDisplayed;

  @override
  _AnimatedNumberState createState() => _AnimatedNumberState();
}

class _AnimatedNumberState extends State<AnimatedNumber>
    with SingleTickerProviderStateMixin {
  Animation<double> _xAnimation;
  Animation<double> _yAnimation;
  Animation<double> _angleAnimation;
  AnimationController _controller;
  double _angle = 0;

  static const int ANIMATION_DURATION_MS = 750;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: ANIMATION_DURATION_MS),
      vsync: this,
    );
    _xAnimation = Tween<double>(
      begin: -5,
      end: widget.x,
    ).animate(CurvedAnimation(
        parent: _controller, curve: Interval(0.0, 0.6, curve: Curves.ease)))
      ..addListener(() {
        setState(() {});
      });
    _yAnimation = Tween<double>(
      begin: -100,
      end: widget.y,
    ).animate(CurvedAnimation(
        parent: _controller, curve: Interval(0.0, 0.6, curve: Curves.easeOut)));

    _angleAnimation = TweenSequence(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: -9.0, end: -2.0)
            .chain(CurveTween(curve: Curves.ease)),
        weight: 75.0,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.0, end: 7.0)
            .chain(CurveTween(curve: Curves.ease)),
        weight: 10.0,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 7.0, end: -3.0)
            .chain(CurveTween(curve: Curves.ease)),
        weight: 7.5,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: -3.0, end: 0.0)
            .chain(CurveTween(curve: Curves.ease)),
        weight: 7.5,
      ),
    ]).animate(CurvedAnimation(
        parent: _controller, curve: Interval(0.0, 1.0, curve: Curves.ease)))
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void didUpdateWidget(AnimatedNumber oldWidget) {
    if (widget.numberDisplayed != oldWidget.numberDisplayed) {
      runAnimation();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> runAnimation() async {
    print('Running animation brah');
    try {
      _controller.reset();
      await _controller.forward().orCancel;
    } on TickerCanceled {}
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: _xAnimation.value,
      top: _yAnimation.value,
      child: Transform.rotate(
          angle: _angleAnimation.value * 2 * math.pi / 360,
          child: Text(widget.numberDisplayed)),
    );
  }
}
