import 'package:board_front/util/value.dart';
import 'package:flutter/material.dart';

class TextModelData {
  MyValueNotifier<String> content = MyValueNotifier('');
  MyValueNotifier<Color?> color = MyValueNotifier(null);
}
