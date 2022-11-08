import 'package:flutter/material.dart';

Future<String?> showModifyTextDialog(BuildContext context, {String text = ''}) {
  TextEditingController controller = TextEditingController()..text = text;
  return showDialog<String>(
    context: context,
    builder: (context) {
      return Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('修改文字', style: Theme.of(context).textTheme.headline5),
            TextField(controller: controller),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('确定'),
            ),
          ],
        ),
      );
    },
  );
}
