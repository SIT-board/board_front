import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'data.dart';

class MarkdownModelWidget extends StatelessWidget {
  final MarkdownModelData data;
  const MarkdownModelWidget({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Markdown(data: data.markdown);
  }
}
