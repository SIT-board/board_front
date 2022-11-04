import 'package:flutter/material.dart';

import 'data.dart';

class OvalModelWidget extends StatelessWidget {
  final OvalModelData data;
  const OvalModelWidget({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        decoration: BoxDecoration(color: data.fillColor),
      ),
    );
  }
}
