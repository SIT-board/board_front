import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import 'data.dart';

class HtmlModelWidget extends StatelessWidget {
  final HtmlModelData data;
  const HtmlModelWidget({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(data.html);
  }
}
