import 'package:flutter/material.dart';

import 'data.dart';

class TextModelWidget extends StatelessWidget {
  final TextModelData data;
  const TextModelWidget({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(data.content);
  }
}
