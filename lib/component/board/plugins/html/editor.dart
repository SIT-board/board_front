import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board.dart';
import 'package:board_front/component/board/board_event.dart';
import 'package:flutter/material.dart';

import 'data.dart';

class HtmlModelEditor extends StatelessWidget {
  final Model model;
  final EventBus<BoardEventName> eventBus;
  const HtmlModelEditor({
    Key? key,
    required this.model,
    required this.eventBus,
  }) : super(key: key);
  void refreshModel() => eventBus.publish(BoardEventName.refreshModel, model.id);
  void saveState() => eventBus.publish(BoardEventName.saveState);
  HtmlModelData get modelData => HtmlModelData(model.data);

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    controller.text = modelData.html;
    controller.addListener(() {
      modelData.html = controller.text;
      refreshModel();
    });
    return TextField(
      maxLines: null,
      controller: controller,
    );
  }
}
