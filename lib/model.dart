import 'dart:ui';

import 'package:flutter/gestures.dart';

enum ComponentType {
  text,
}

class TextComponentModel {
  final String content;
  final Color color;

  TextComponentModel(this.content, this.color);
}

class ComponentModel {
  final ComponentType type;
  final TextComponentModel meta;
  final Matrix4 transform;

  ComponentModel(this.type, this.meta, this.transform);
}

class CanvasViewModel {
  final Matrix4 viewerTransform;
  final List<ComponentModel> components;

  CanvasViewModel(this.viewerTransform, this.components);
}
