import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyValueNotifier<T> extends ChangeNotifier implements ValueListenable<T> {
  @override
  T value;

  MyValueNotifier(this.value);

  Widget buildWidget({required ValueWidgetBuilder<T> builder}) {
    return ValueListenableBuilder<T>(
      valueListenable: this,
      builder: builder,
    );
  }

  @override
  String toString() => '${describeIdentity(this)}($value)';
}
