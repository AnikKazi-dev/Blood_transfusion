import 'package:flutter/material.dart';

class TimerProvider with ChangeNotifier {
  DateTime? _startTime;

  DateTime? get startTime => _startTime;

  void setStartTime(DateTime value) {
    _startTime = value;
    notifyListeners();
  }

  void reset() {
    _startTime = null;
    notifyListeners();
  }
}
