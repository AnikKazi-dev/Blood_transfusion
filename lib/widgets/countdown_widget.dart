import 'dart:async';

import 'package:flutter/material.dart';

class CountdownWidget extends StatefulWidget {
  final String label;
  final Duration duration;
  final Function onDone;
  final Function onTick;
  const CountdownWidget(
      {required this.duration,
      required this.label,
      required this.onDone,
      required this.onTick,
      super.key});

  @override
  State<CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  Timer? _timer;

  void startTimer() {
    setState(() {
      Duration remainingTime = widget.duration;
      widget.onTick(remainingTime);
      remainingTime = remainingTime - const Duration(seconds: 1);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (remainingTime > Duration.zero) {
          widget.onTick(remainingTime);
          remainingTime = remainingTime - const Duration(seconds: 1);
        } else {
          timer.cancel();
          widget.onTick(null);
          widget.onDone();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: _timer == null || !_timer!.isActive ? startTimer : null,
        child: Text(widget.label));
  }
}
