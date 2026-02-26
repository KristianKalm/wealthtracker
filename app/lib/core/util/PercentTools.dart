import 'package:flutter/material.dart';

double getPercent(double previous, double current) {
  if (current == previous) return 0.0;
  if (current >= 0 && previous <= 0) return 100.0;
  if (current <= 0 && previous >= 0) return -100.0;
  double percent = (current - previous) / previous * 100;
  if (current < 0) {
    percent = percent * -1;
  }
  return percent;
}

Color getArrowColor(num value) {
  if (value == 0) {
    return Colors.grey;
  } else if (value > 0) {
    return Colors.green;
  } else {
    return Colors.red;
  }
}
