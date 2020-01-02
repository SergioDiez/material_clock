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
  Animation<double> _xOutAnimation;
  Animation<double> _yOutAnimation;
  Animation<double> _xAnimation;
  Animation<double> _yAnimation;
  Animation<double> _angleAnimation;
  AnimationController _controller;
  bool _isAnimating;
  String _number;
  String _newNumber;

  static const int ANIMATION_DURATION_MS = 1200;

  @override
  void initState() {
    super.initState();
    _number = widget.numberDisplayed;
    print('$_number init');
    _isAnimating = true;
    _controller = AnimationController(
      duration: Duration(milliseconds: ANIMATION_DURATION_MS),
      vsync: this,
    );

    _xOutAnimation = Tween<double>(
      begin: widget.x,
      end: widget.x + 20,
    ).animate(CurvedAnimation(
        parent: _controller, curve: Interval(0.0, 0.35, curve: Curves.easeIn)))
      ..addListener(() {
        setState(() {
          _isAnimating = true;
        });
      });

    _yOutAnimation = Tween<double>(
      begin: widget.y,
      end: widget.y + 300,
    ).animate(CurvedAnimation(
        parent: _controller, curve: Interval(0.0, 0.35, curve: Curves.easeIn)))
      ..addListener(() {
        setState(() {
          _isAnimating = true;
        });
      });

    _xAnimation = Tween<double>(
      begin: -5,
      end: widget.x,
    ).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(0.35, 0.75, curve: Curves.easeOut)))
      ..addListener(() {
        setState(() {
          _isAnimating = false;
        });
      });

    _yAnimation = Tween<double>(
      begin: -100,
      end: widget.y,
    ).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(0.35, 0.75, curve: Curves.easeOut)))
      ..addListener(() {
        setState(() {});
      });

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
        parent: _controller, curve: Interval(0.45, 1.0, curve: Curves.ease)))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _number = _newNumber;
          });
        }
      });
  }

  @override
  void didUpdateWidget(AnimatedNumber oldWidget) {
    if (widget.numberDisplayed != oldWidget.numberDisplayed) {
      // TODO Update inner number
      setState(() {
        _newNumber = widget.numberDisplayed;
      });
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
    print('isAnimating: $_isAnimating');
    print(
        '_xOutAnimation: ${_xOutAnimation.value} _xAnimation: ${_xAnimation.value}');
    print(
        '_yOutAnimation: ${_yOutAnimation.value} _yAnimation: ${_yAnimation.value}');
    print('x: ${widget.x} y: ${widget.y}');
    return Positioned(
      right: _xOutAnimation.value != 45.0
          ? _xOutAnimation.value
          : _xAnimation.value,
      top: _yOutAnimation.value != 380.0
          ? _yOutAnimation.value
          : _yAnimation.value,
      child: Transform.rotate(
          angle: _angleAnimation.value * 2 * math.pi / 360,
          child: Text(_xOutAnimation.value != 45.0 ? _number : _newNumber)),
    );
  }
}
