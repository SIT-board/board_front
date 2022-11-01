import 'package:board_front/util/value.dart';
import 'package:flutter/material.dart';

class FreeStylePathModelData {
  MyValueNotifier<List<Offset>> points = MyValueNotifier([]);

  MyValueNotifier<Color> color = MyValueNotifier(Colors.red);
}

class FreeStyleModelData {
  MyValueNotifier<List<FreeStylePathModelData>> pathList = MyValueNotifier([]);
}
