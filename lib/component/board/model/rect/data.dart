import 'package:board_front/util/value.dart';
import 'package:flutter/material.dart';

class RectModelData {
  MyValueNotifier<Color?> fillColor = MyValueNotifier(null);
  MyValueNotifier<Color?> borderColor = MyValueNotifier(null);
  MyValueNotifier<double?> borderWidth = MyValueNotifier(null);
}
