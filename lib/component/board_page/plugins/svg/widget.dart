import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'data.dart';

class SvgModelWidget extends StatelessWidget {
  final SvgModelData data;
  const SvgModelWidget({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.data.isEmpty) return const Center(child: Text('未设置SVG矢量图'));
    return SvgPicture.string(
      data.data,
      fit: data.fit,
      color: data.color,
    );
  }
}
