import 'package:flutter/material.dart';

import 'data.dart';

class LineModelWidget extends StatelessWidget {
  final LineModelData data;
  const LineModelWidget({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(
      thickness: data.thickness,
      color: data.color,
    );
  }
}
