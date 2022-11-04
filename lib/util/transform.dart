import 'package:flutter/material.dart' show Offset;
import 'package:vector_math/vector_math_64.dart';

extension Matrix4TransformUtil on Matrix4 {
  Offset transformOffset(Offset o) {
    final v = transform3(Vector3(o.dx, o.dy, 0));
    return Offset(v.x, v.y);
  }
}
