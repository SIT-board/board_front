import 'package:board_front/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pumli/pumli.dart';

import 'data.dart';

Map<String, SvgPicture> _cache = {};

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
    final cached = _cache[widget.data.data];
    if (cached != null) return cached;

    return FutureBuilder<String>(
      future: PumliREST(serviceURL: GlobalObjects.storage.server.plantuml).getSVG(widget.data.data),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (_cache.length > 10) _cache = Map.fromEntries(_cache.entries.skip(_cache.length - 10));
          return _cache[widget.data.data] = SvgPicture.string(snapshot.data ?? '');
        }
        if (snapshot.hasError) return Text('${snapshot.error}');
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
