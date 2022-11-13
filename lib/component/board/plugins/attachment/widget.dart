import 'package:flutter/material.dart';

import 'data.dart';

class AttachmentModelWidget extends StatelessWidget {
  final AttachmentModelData data;
  const AttachmentModelWidget({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.url.isEmpty) return const Center(child: Text('未上传附件'));
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.attachment),
          Text('附件：${data.name}'),
        ],
      ),
    );
  }
}
