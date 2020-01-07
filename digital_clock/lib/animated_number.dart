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
    with TickerProviderStateMixin {
  Animation<double> _xOutAnimation;
  Animation<double> _yOutAnimation;
  Animation<double> _xInAnimation;
  Animation<double> _yInAnimation;
  Animation<double> _angleAnimation;
  AnimationController _inAnimationController;
  AnimationController _outAnimationController;
  String _displayedNumber;

  static const int IN_ANIMATION_DURATION_MS = 3100;
  static const int OUT_ANIMATION_DURATION_MS = 650;

  @override
  void initState() {
    super.initState();
    _displayedNumber = widget.numberDisplayed;
    createOutAnimation();
    createInAnimation();

    runInAnimation();
  }

  void createOutAnimation() {
    _outAnimationController = AnimationController(
      duration: Duration(milliseconds: OUT_ANIMATION_DURATION_MS),
      vsync: this,
    );
    _xOutAnimation = Tween<double>(
      begin: widget.x,
      end: widget.x - 15,
    ).animate(CurvedAnimation(
      parent: _outAnimationController,
      curve: Interval(0.0, 1.0, curve: Curves.easeIn),
    ));
    _yOutAnimation = Tween<double>(
      begin: widget.y,
      end: widget.y + 230,
    ).animate(CurvedAnimation(
      parent: _outAnimationController,
      curve: Interval(0.0, 1.0, curve: Curves.easeIn),
    ));
  }

  void createInAnimation() {
    _inAnimationController = AnimationController(
      duration: Duration(milliseconds: IN_ANIMATION_DURATION_MS),
      vsync: this,
    );
    _xInAnimation = Tween<double>(
      begin: widget.x + 15,
      end: widget.x,
    ).animate(CurvedAnimation(
        parent: _inAnimationController,
        curve: Interval(0.0, 0.3, curve: Curves.ease)))
      ..addListener(() {
        setState(() {});
      });
    _yInAnimation = Tween<double>(
      begin: -100,
      end: widget.y,
    ).animate(CurvedAnimation(
        parent: _inAnimationController,
        curve: Interval(0.0, 0.3, curve: Curves.ease)));

    _angleAnimation = TweenSequence(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(-20.0),
        weight: 35.0,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: -20.0, end: -2.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 20.0,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.0, end: 7.0)
            .chain(CurveTween(curve: Curves.ease)),
        weight: 20.0,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 7.0, end: -4.5)
            .chain(CurveTween(curve: Curves.ease)),
        weight: 15.0,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: -4.5, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 10.0,
      ),
    ]).animate(CurvedAnimation(
        parent: _inAnimationController,
        curve: Interval(0.0, 1.0, curve: Curves.decelerate)))
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void didUpdateWidget(AnimatedNumber oldWidget) {
    if (widget.numberDisplayed != oldWidget.numberDisplayed) {
      runOutAnimation();
      runInAnimation();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _inAnimationController.dispose();
    _outAnimationController.dispose();
    super.dispose();
  }

  Future<void> runOutAnimation() async {
    try {
      _outAnimationController.reset();
      await _outAnimationController.forward().whenComplete(() {
        setState(() {
          _displayedNumber = widget.numberDisplayed;
        });
        runInAnimation();
      });
    } on TickerCanceled {}
  }

  Future<void> runInAnimation() async {
    try {
      _inAnimationController.reset();
      await _inAnimationController.forward().orCancel;
    } on TickerCanceled {}
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _outAnimationController.isAnimating
          ? _xOutAnimation.value
          : _xInAnimation.value,
      top: _outAnimationController.isAnimating
          ? _yOutAnimation.value
          : _yInAnimation.value,
      child: Transform.rotate(
          angle: _angleAnimation.value * 2 * math.pi / 360,
          child: Text(_displayedNumber)),
    );
  }
}
