import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secureblood/providers/timer_provider.dart';

class TimerWidget extends StatefulWidget {
  const TimerWidget({super.key});

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  Duration _remainingTime = const Duration(minutes: 15);
  Timer? _timer;
  Color _backgroundColor = Colors.green.shade100;
  late TimerProvider? timerProvider;

  void initTimer() {
    timerProvider ??= Provider.of<TimerProvider>(context, listen: false);

    if (timerProvider!.startTime == null) {
      return;
    }

    _timer?.cancel();

// get the difference between the current time and the start time
    _remainingTime = timerProvider!.startTime!
        .add(const Duration(minutes: 15))
        .difference(DateTime.now());

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > Duration.zero) {
        if (mounted) {
          setState(() {
            _remainingTime = _remainingTime - const Duration(seconds: 1);
          });
        }

        if (_remainingTime.inMinutes < 5) {
          _backgroundColor = Colors.red.shade400;
        }
      } else {
        _timer?.cancel();
      }
    });
  }

  formatDurationtoMinuteSecond(Duration d) {
    List<String> stringList = d.toString().split(":");
    stringList.removeAt(0);
    return stringList.join(":").split(".").first;
  }

  @override
  void initState() {
    super.initState();
    timerProvider = Provider.of<TimerProvider>(context, listen: false);

    timerProvider!.addListener(() => initTimer());

    if (timerProvider!.startTime != null) {
      initTimer();
    }
  }

  @override
  void dispose() {
    timerProvider?.removeListener(() => initTimer());
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(seconds: _remainingTime.inSeconds),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: _backgroundColor,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              formatDurationtoMinuteSecond(_remainingTime),
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          const Baseline(
              baseline: 25,
              baselineType: TextBaseline.alphabetic,
              child: Text("verbleibend"))
        ],
      ),
    );
  }
}
