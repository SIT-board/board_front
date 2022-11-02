import 'dart:math';

import 'package:board_front/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

/// 显示颜色拾取器
/// 该颜色拾取器需要在颜色选择成功后自动记录到颜色历史记录中
Future<Color?> showBoardColorPicker(BuildContext context) async {
  final colorStorage = GlobalObjects.storage.color;
  var recentColorList = colorStorage.recentColorList;
  var pickerColor = HSVColor.fromAHSV(
    1.0,
    Random().nextDouble() * 360,
    Random().nextDouble() / 2 + 0.5,
    Random().nextDouble() / 2 + 0.5,
  ).toColor();

  final pickedColor = await showDialog<Color>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('颜色拾取器'),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: pickerColor,
          onColorChanged: (c) => pickerColor = c,
          hexInputBar: true,
          colorHistory: recentColorList,
          onHistoryChanged: (c) {},
          labelTypes: const [
            ColorLabelType.rgb,
            ColorLabelType.hsv,
            ColorLabelType.hex,
            ColorLabelType.hsl,
          ],
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('确定'),
          onPressed: () {
            Navigator.of(context).pop(pickerColor);
          },
        ),
      ],
    ),
  );
  // 没确定那就算了
  if (pickedColor == null) return null;
  // 表首为最新颜色
  recentColorList.remove(pickedColor);
  recentColorList.insert(0, pickedColor);
  // 越界限制
  if (recentColorList.length > 6) recentColorList = recentColorList.sublist(0, 6);
  colorStorage.recentColorList = recentColorList;
  return pickedColor;
}
