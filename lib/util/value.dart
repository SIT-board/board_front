import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyValueNotifier<T> {
  T value;
  late final _valueNotifier = ValueNotifier<T>(value);
  MyValueNotifier(this.value);

  Widget buildWidget({required ValueWidgetBuilder<T> builder}) {
    return ValueListenableBuilder<T>(
      valueListenable: _valueNotifier,
      builder: builder,
    );
  }

  void updateWidget() => _valueNotifier.value = value;

  @override
  String toString() => '${describeIdentity(this)}($value)';
}
