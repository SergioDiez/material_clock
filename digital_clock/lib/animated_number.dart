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
      begin: widget.x,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Interval(0.0, 1.0)))
      ..addListener(() {
        setState(() {});
      });

    _angleAnimation = TweenSequence(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.0, end: 7.0)
            .chain(CurveTween(curve: Curves.ease)),
        weight: 40.0,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 7.0, end: -3.0)
            .chain(CurveTween(curve: Curves.ease)),
        weight: 35.0,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: -3.0, end: 0.0)
            .chain(CurveTween(curve: Curves.ease)),
        weight: 25.0,
      ),
    ]).animate(_controller);
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
      right: widget.x,
      top: widget.y,
      child: Transform.rotate(
          angle: _angleAnimation.value * 2 * math.pi / 360,
          child: Text(widget.numberDisplayed)),
    );
  }
}
