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
  @override
  Widget build(BuildContext context) {
    if (widget.data.data.isEmpty) return const Center(child: Text('未设置PlantUML'));
    return FutureBuilder<String>(
      future: PumliREST(serviceURL: 'http://192.168.2.118:8080').getSVG(widget.data.data),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SvgPicture.string(snapshot.data ?? '');
        }
        if (snapshot.hasError) return Text('${snapshot.error}');
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
