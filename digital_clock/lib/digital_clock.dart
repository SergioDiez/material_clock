// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:digital_clock/animated_number.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _lightColors = [
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

final _darkColors = [
  Colors.red.shade900,
  Colors.indigo.shade900,
  Colors.purple.shade900,
  Colors.deepOrange.shade900,
  Colors.blueGrey.shade800,
  Colors.blue.shade900,
  Colors.lime.shade900,
  Colors.pink.shade900,
  Colors.green.shade900,
];

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
    setState(() {
      _firstHourNumber = '';
      _secondHourNumber = '';
      _firstMinuteNumber = '';
      _secondMinuteNumber = '';
    });
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
    Window window = WidgetsBinding.instance.window;
    final themeColors = window.platformBrightness == Brightness.dark
        ? _darkColors
        : _lightColors;
    math.Random random = new math.Random();
    int position = random.nextInt(themeColors.length);
    Color nextColor = themeColors[position];
    themeColors.removeAt(position);
    if (currentColor != null) {
      themeColors.add(currentColor);
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

  Widget _buildBlock(BuildContext context, Color color, String displayedNumber,
      {int animationDelay = 0}) {
    return AnimatedContainer(
      duration: Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
      child: Center(
        child: AnimatedNumber(
          numberDisplayed: displayedNumber,
          animationDelay: animationDelay,
        ),
      ),
      constraints: BoxConstraints.expand(),
      decoration: new BoxDecoration(color: color, boxShadow: [
        BoxShadow(
            color: Colors.black45,
            blurRadius: 6.0,
            spreadRadius: 0.0,
            offset: Offset(-2, 0))
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth / 6;
    final defaultStyle = TextStyle(
      color: Colors.white,
      fontFamily: 'Roboto',
      fontSize: fontSize,
      shadows: [
        Shadow(
          blurRadius: 3,
          color: Colors.black45,
          offset: Offset(0, 0),
        ),
      ],
    );

    return Container(
      color: Colors.indigoAccent,
      child: DefaultTextStyle(
        style: defaultStyle,
        child: Stack(
          children: <Widget>[
            Row(
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: _buildBlock(
                      context, _firstLayerColor, _firstHourNumber,
                      animationDelay: 375),
                ),
                Flexible(
                  flex: 1,
                  child: _buildBlock(
                      context, _secondLayerColor, _secondHourNumber,
                      animationDelay: 250),
                ),
                Flexible(
                  flex: 1,
                  child: _buildBlock(
                      context, _thirdLayerColor, _firstMinuteNumber,
                      animationDelay: 125),
                ),
                Flexible(
                  flex: 1,
                  child: _buildBlock(
                      context, _fourthLayerColor, _secondMinuteNumber),
                ),
              ],
            ),
            Center(
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 350),
                opacity: _separatorOpacity,
                child: Padding(
                    padding: EdgeInsets.only(bottom: fontSize / 8),
                    child: Text(
                      ':',
                    )),
              ),
            ),
            Positioned(
                right: 10,
                bottom: 25,
                child: Row(
                  children: <Widget>[
                    _getWeatherEmoji(widget.model.weatherCondition),
                    Text(
                      widget.model.temperatureString,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                )),
            Positioned(
                right: 10,
                bottom: 10,
                child: Text(
                  widget.model.location,
                  style: TextStyle(fontSize: 9),
                )),
          ],
          overflow: Overflow.clip,
        ),
      ),
    );
  }
}
