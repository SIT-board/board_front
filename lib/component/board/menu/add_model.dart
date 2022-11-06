import 'dart:math';

import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board.dart';
import 'package:board_front/component/board/board_event.dart';
import 'package:board_front/util/transform.dart';
import 'package:flutter/material.dart';
import 'package:quds_popup_menu/quds_popup_menu.dart';

QudsPopupMenuBase buildAddModelMenu({
  required EventBus<BoardEventName> eventBus,
  required BoardViewModel boardViewModel,
  required Offset offset,
}) {
  Offset position = Matrix4.inverted(boardViewModel.viewerTransform).transformOffset(offset);
  return QudsPopupMenuSection(
    titleText: '添加模型',
    subItems: [
      QudsPopupMenuItem(
          title: Text('矩形'),
          onPressed: () {
            boardViewModel.addModel(
              Model({})
                ..id = Random().nextInt(65536).toString()
                ..common = (CommonModelData({})..position = position)
                ..type = ModelType.rect
                ..data = (RectModelData({})..fillColor = Colors.blue),
            );
            eventBus.publish(BoardEventName.refreshBoard);
          }),
      QudsPopupMenuItem(
          title: Text('直线'),
          onPressed: () {
            boardViewModel.addModel(
              Model({})
                ..id = Random().nextInt(65536).toString()
                ..common = (CommonModelData({})
                  ..position = position
                  ..constraints = const BoxConstraints(
                    minWidth: 0,
                    maxWidth: double.maxFinite,
                    minHeight: 60,
                    maxHeight: 60,
                  )
                  ..size = const Size(100, 60))
                ..type = ModelType.line
                ..data = (LineModelData({})),
            );
            eventBus.publish(BoardEventName.refreshBoard);
          }),
      QudsPopupMenuItem(
          title: Text('椭圆'),
          onPressed: () {
            boardViewModel.addModel(
              Model({})
                ..id = Random().nextInt(65536).toString()
                ..common = (CommonModelData({})..position = position)
                ..type = ModelType.oval
                ..data = (OvalModelData({})..fillColor = Colors.blue),
            );
            eventBus.publish(BoardEventName.refreshBoard);
          }),
      QudsPopupMenuItem(
          title: Text('文本框'),
          onPressed: () {
            boardViewModel.addModel(
              Model({})
                ..id = Random().nextInt(65536).toString()
                ..common = (CommonModelData({})..position = position)
                ..type = ModelType.text
                ..data = (TextModelData({})..content = '新建文本框'),
            );
            eventBus.publish(BoardEventName.refreshBoard);
          }),
      QudsPopupMenuItem(
        title: Text('图像'),
        onPressed: () {
          boardViewModel.addModel(
            Model({})
              ..id = Random().nextInt(65536).toString()
              ..common = (CommonModelData({})..position = position)
              ..type = ModelType.image
              ..data = (ImageModelData({})
                ..url = 'https://tse2-mm.cn.bing.net/th/id/OIP-C.7HET4jnvBD-VqPcPQCSO-QHaSw?pid=ImgDet&rs=1'),
          );
          eventBus.publish(BoardEventName.refreshBoard);
        },
      ),
      QudsPopupMenuItem(
          title: Text('自由画板'),
          onPressed: () {
            boardViewModel.addModel(
              Model({})
                ..id = Random().nextInt(65536).toString()
                ..common = (CommonModelData({})..position = position)
                ..type = ModelType.freeStyle
                ..data = (FreeStyleModelData({})),
            );
            eventBus.publish(BoardEventName.refreshBoard);
          }),
    ],
  );
}
