import 'dart:math';

import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board.dart';
import 'package:board_front/util/transform.dart';
import 'package:flutter/material.dart';
import 'package:quds_popup_menu/quds_popup_menu.dart';

import 'board_page_event.dart';

class LongPressedMenu extends StatelessWidget {
  final Widget child;
  final BoardViewModel boardViewModel;
  final EventBus<BoardPageEventName> eventBus;
  const LongPressedMenu({
    Key? key,
    required this.child,
    required this.boardViewModel,
    required this.eventBus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var viewMatrix = Matrix4.identity();
    eventBus.subscribe(BoardPageEventName.viewCameraChange, (arg) => viewMatrix = arg as Matrix4);
    return GestureDetector(
      onLongPressStart: (d) {
        showQudsPopupMenu(
          context: context,
          startOffset: d.localPosition,
          endOffset: d.localPosition,
          items: [
            QudsPopupMenuItem(title: Text('清空画布'), onPressed: () {}),
            QudsPopupMenuSection(
              titleText: '添加模型',
              subItems: [
                QudsPopupMenuItem(
                    title: Text('矩形'),
                    onPressed: () {
                      boardViewModel.models.addModel(
                        Model({})
                          ..id = Random().nextInt(65536).toString()
                          ..common = (CommonModelData({})
                            ..position = Matrix4.inverted(viewMatrix).transformOffset(d.localPosition))
                          ..type = ModelType.rect
                          ..data = (RectModelData({})..fillColor = Colors.blue),
                      );
                      eventBus.publish(BoardPageEventName.refreshBoard);
                    }),
                QudsPopupMenuItem(
                    title: Text('直线'),
                    onPressed: () {
                      boardViewModel.models.addModel(
                        Model({})
                          ..id = Random().nextInt(65536).toString()
                          ..common = (CommonModelData({})
                            ..position = Matrix4.inverted(viewMatrix).transformOffset(d.localPosition)
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
                      eventBus.publish(BoardPageEventName.refreshBoard);
                    }),
                QudsPopupMenuItem(
                    title: Text('椭圆'),
                    onPressed: () {
                      boardViewModel.models.addModel(
                        Model({})
                          ..id = Random().nextInt(65536).toString()
                          ..common = (CommonModelData({})
                            ..position = Matrix4.inverted(viewMatrix).transformOffset(d.localPosition))
                          ..type = ModelType.oval
                          ..data = (OvalModelData({})..fillColor = Colors.blue),
                      );
                      eventBus.publish(BoardPageEventName.refreshBoard);
                    }),
                QudsPopupMenuItem(title: Text('文本框'), onPressed: () {}),
                QudsPopupMenuItem(title: Text('图像'), onPressed: () {}),
                QudsPopupMenuItem(title: Text('自由画板'), onPressed: () {}),
              ],
            ),
          ],
        );
      },
      child: child,
    );
  }
}
