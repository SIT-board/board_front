import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board.dart';
import 'package:board_front/component/board/board_event.dart';
import 'package:flutter/material.dart';

import 'data.dart';

class MarkdownModelEditor extends StatelessWidget {
  final Model model;
  final EventBus<BoardEventName> eventBus;
  const MarkdownModelEditor({
    Key? key,
    required this.model,
    required this.eventBus,
  }) : super(key: key);
  void refreshModel() => eventBus.publish(BoardEventName.refreshModel, model.id);
  void saveState() => eventBus.publish(BoardEventName.saveState);
  MarkdownModelData get modelData => MarkdownModelData(model.data);

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    controller.text = modelData.markdown;
    controller.addListener(() {
      modelData.markdown = controller.text;
      refreshModel();
    });
    return TextField(
      minLines: 100,
      maxLines: null,
      controller: controller,
    );
  }
}
