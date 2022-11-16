import 'package:board_front/global.dart';
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
  late String plantUmlServiceUrl = GlobalObjects.storage.server.plantuml;

  @override
  Widget build(BuildContext context) {
    if (widget.data.data.isEmpty) return const Center(child: Text('未设置PlantUML'));
    return FutureBuilder<String>(
      future: PumliREST(serviceURL: plantUmlServiceUrl).getSVG(widget.data.data),
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
