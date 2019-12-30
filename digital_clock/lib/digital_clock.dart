// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;
import 'package:digital_clock/animated_number.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum _Element {
  background,
  text,
  shadow,
}

final _colors = [
  Colors.amber,
  Colors.red,
  Colors.indigo,
  Colors.purple,
  Colors.blue,
  Colors.orange,
  Colors.lime,
  Colors.pink,
  Colors.green,
];

final _lightTheme = {
  _Element.background: Color(0xFF81B3FE),
  _Element.text: Colors.white,
  _Element.shadow: Colors.black,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.white,
  _Element.shadow: Color(0xFF174EA6),
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
  String _firstHourNumber;
  Color _firstLayerColor;
  String _secondHourNumber;
  Color _secondLayerColor;
  String _firstMinuteNumber;
  Color _thirdLayerColor;
  String _secondMinuteNumber;
  Color _fourthLayerColor;

  @override
  void initState() {
    super.initState();
    _updateTime();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.dispose();
    super.dispose();
  }

  void _updateTime() {
    DateTime currentTime = DateTime.now();
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);

    final firstHourNumber = hour.substring(0, 1);
    final secondHourNumber = hour.substring(1);

    final minute = DateFormat('mm').format(_dateTime);

    final firstMinuteNumber = minute.substring(0, 1);
    final secondMinuteNumber = minute.substring(1);

    Color newFirstLayerColor;
    if (firstHourNumber != _firstHourNumber) {
      newFirstLayerColor = _getColor(_firstLayerColor);
      setState(() {
        _firstHourNumber = firstHourNumber;
        _firstLayerColor = newFirstLayerColor;
      });
    }
    Color secondHourLayerColor;
    if (secondHourNumber != _secondHourNumber) {
      secondHourLayerColor = _getColor(_secondLayerColor);
      setState(() {
        _secondHourNumber = secondHourNumber;
        _secondLayerColor = secondHourLayerColor;
      });
    }
    Color firstMinuteLayerColor;
    if (firstMinuteNumber != _firstMinuteNumber) {
      firstMinuteLayerColor = _getColor(_thirdLayerColor);
      setState(() {
        _firstMinuteNumber = firstMinuteNumber;
        _thirdLayerColor = firstMinuteLayerColor;
      });
    }
    Color secondMinuteLayerColor;
    if (secondMinuteNumber != _secondMinuteNumber) {
      secondMinuteLayerColor = _getColor(_fourthLayerColor);
      setState(() {
        _secondMinuteNumber = secondMinuteNumber;
        _fourthLayerColor = secondMinuteLayerColor;
      });
    }

    setState(() {
      _dateTime = currentTime;
      _separatorOpacity = _separatorOpacity == 1 ? 0 : 1;
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  Color _getColor(Color currentColor) {
    math.Random random = new math.Random();
    int position = random.nextInt(_colors.length);
    Color nextColor = _colors[position];
    _colors.removeAt(position);
    if (currentColor != null) {
      _colors.add(currentColor);
    }
    return nextColor;
  }

  Container _getWeatherEmoji(WeatherCondition weatherCondition) {
    var text;
    switch (weatherCondition) {
      case WeatherCondition.sunny:
        text = '☀️';
        break;
      case WeatherCondition.windy:
        text = '💨';
        break;
      case WeatherCondition.rainy:
        text = '🌧';
        break;
      case WeatherCondition.snowy:
        text = '❄️';
        break;
      case WeatherCondition.foggy:
        text = '🌫';
        break;
      case WeatherCondition.cloudy:
        text = '🌥';
        break;
      case WeatherCondition.thunderstorm:
        text = '🌩';
        break;
    }

    return Container(
      margin: EdgeInsets.only(right: 4.0),
      child: Text(text,
          style: TextStyle(
            fontSize: 12,
          )),
    );
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
                  child: _buildBlock(context, _firstLayerColor)),
              Positioned(
                  left: 110,
                  top: -80,
                  child: _buildBlock(context, _secondLayerColor)),
              Positioned(
                  left: 210,
                  top: -80,
                  child: _buildBlock(context, _thirdLayerColor)),
              Positioned(
                  left: 310,
                  top: -80,
                  child: _buildBlock(context, _fourthLayerColor)),
              Positioned(left: 40, top: 80, child: Text(_firstHourNumber)),
              Positioned(left: 130, top: 80, child: Text(_secondHourNumber)),
              Positioned(
                  left: 200,
                  top: 75,
                  child: AnimatedOpacity(
                      duration: Duration(milliseconds: 350),
                      opacity: _separatorOpacity,
                      child: Text(':'))),
              Positioned(right: 125, top: 80, child: Text(_firstMinuteNumber)),
              AnimatedNumber(
                  x: 25, y: 80, numberDisplayed: _secondMinuteNumber),
              Positioned(
                  right: 10,
                  bottom: 25,
                  child: Row(
                    children: <Widget>[
                      _getWeatherEmoji(widget.model.weatherCondition),
                      Text(
                        widget.model.temperatureString,
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
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
