import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pumli/pumli.dart';

import 'data.dart';

class PlantUMLModelWidget extends StatefulWidget {
  final PlantUMLModelData data;
  const PlantUMLModelWidget({Key? key, required this.data}) : super(key: key);

  @override
  State<PlantUMLModelWidget> createState() => _PlantUMLModelWidgetState();
}

class _PlantUMLModelWidgetState extends State<PlantUMLModelWidget> {
  Timer? _timer;
  String svgContent = '';
  String? errorMsg;
  @override
  void initState() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      PumliREST(serviceURL: 'http://192.168.2.118:8080').getSVG(widget.data.data).then((value) {
        svgContent = value;
        errorMsg = null;
        setState(() {});
      }).catchError((error) {
        errorMsg = '$error';
        setState(() {});
      }).ignore();
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (errorMsg != null) return Text('$errorMsg');
    if (svgContent.isEmpty) return const Center(child: Text('未设置PlantUML'));
    return SvgPicture.string(svgContent);
  }
}
