// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum _Element {
  background,
  text,
  shadow,
  firstBlockColor,
  secondBlockColor,
  thirdBlockColor,
  fourthBlockColor,
}

final _lightTheme = {
  _Element.background: Color(0xFF81B3FE),
  _Element.text: Colors.white,
  _Element.shadow: Colors.black,
  _Element.firstBlockColor: Colors.amber,
  _Element.secondBlockColor: Colors.blueAccent,
  _Element.thirdBlockColor: Colors.greenAccent,
  _Element.fourthBlockColor: Colors.redAccent,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.white,
  _Element.shadow: Color(0xFF174EA6),
  _Element.firstBlockColor: Colors.deepPurple.shade900,
  _Element.secondBlockColor: Colors.lime.shade900,
  _Element.thirdBlockColor: Colors.indigo.shade900,
  _Element.fourthBlockColor: Colors.pink.shade900,
};

class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  double _separatorOpacity;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      _separatorOpacity = _separatorOpacity == 1 ? 0 : 1;
      // Update once per minute. If you want to update every second, use the
      // following code.
      /*_timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );*/
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  Widget _buildBlock(BuildContext context, Color color) {
    return Transform.rotate(
        angle: math.pi / 16,
        child: AnimatedContainer(
          duration: Duration(seconds: 1),
          curve: Curves.fastOutSlowIn,
          width: 140,
          height: 420,
          decoration: new BoxDecoration(color: color, boxShadow: [
            BoxShadow(
                color: Colors.black45,
                blurRadius: 6.0,
                spreadRadius: 0.0,
                offset: Offset(-2, 0))
          ]),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);

    final firstHourNumber = hour.substring(0, 1);
    final secondHourNumber = hour.substring(1);

    final minute = DateFormat('mm').format(_dateTime);

    final firstMinuteNumber = minute.substring(0, 1);
    final secondMinuteNumber = minute.substring(1);

    final fontSize = MediaQuery.of(context).size.width / 6.5;
    final defaultStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'Roboto',
      fontSize: fontSize,
      shadows: [
        Shadow(
          blurRadius: 3,
          color: colors[_Element.shadow],
          offset: Offset(0, 0),
        ),
      ],
    );

    return Container(
      color: colors[_Element.background],
      child: Center(
        child: DefaultTextStyle(
          style: defaultStyle,
          child: Stack(
            children: <Widget>[
              Positioned(
                  left: -25,
                  top: -80,
                  child:
                      _buildBlock(context, colors[_Element.firstBlockColor])),
              Positioned(
                  left: 110,
                  top: -80,
                  child:
                      _buildBlock(context, colors[_Element.secondBlockColor])),
              Positioned(
                  left: 210,
                  top: -80,
                  child:
                      _buildBlock(context, colors[_Element.thirdBlockColor])),
              Positioned(
                  left: 310,
                  top: -80,
                  child:
                      _buildBlock(context, colors[_Element.fourthBlockColor])),
              Positioned(left: 40, top: 80, child: Text(firstHourNumber)),
              Positioned(left: 130, top: 80, child: Text(secondHourNumber)),
              Positioned(
                  left: 200,
                  top: 75,
                  child: AnimatedOpacity(
                      duration: Duration(milliseconds: 350),
                      opacity: _separatorOpacity,
                      child: Text(':'))),
              Positioned(right: 125, top: 80, child: Text(firstMinuteNumber)),
              Positioned(right: 25, top: 80, child: Text(secondMinuteNumber)),
              Positioned(
                  right: 10,
                  bottom: 25,
                  child: Text(
                    widget.model.weatherString,
                    style: TextStyle(fontSize: 10),
                  )),
              Positioned(
                  right: 40,
                  bottom: 25,
                  child: Text(
                    widget.model.temperatureString,
                    style: TextStyle(fontSize: 10),
                  )),
              Positioned(
                  right: 10,
                  bottom: 10,
                  child: Text(
                    widget.model.location,
                    style: TextStyle(fontSize: 7),
                  )),
            ],
            overflow: Overflow.clip,
          ),
        ),
      ),
    );
  }
}
