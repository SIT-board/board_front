import 'package:board_front/interface/hash_map_data.dart';
import 'package:flutter/material.dart';

class PlantUMLModelData extends HashMapData {
  String get data => map['data'] ?? '';
  set data(String v) => map['data'] = v;

  PlantUMLModelData(super.map);
}
