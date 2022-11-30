import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board.dart';
import 'package:board_front/component/board/board_event.dart';
import 'package:board_front/component/board_page/board_body.dart';
import 'package:board_front/component/board_page/plugins/plugins.dart';
import 'package:flutter/material.dart';

final plugins = BoardModelPluginManager(
  initialPlugins: [
    RectModelPlugin(),
    LineModelPlugin(),
    OvalModelPlugin(),
    SvgModelPlugin(),
    PlantUMLModelPlugin(),
    ImageModelPlugin(),
    AttachmentModelPlugin(),
    FreeStyleModelPlugin(),
    HtmlModelPlugin(),
    MarkdownModelPlugin(),
  ],
);

class SubBoardWidget extends StatefulWidget {
  final Model model;
  final EventBus<BoardEventName> eventBus;

  const SubBoardWidget({
    Key? key,
    required this.model,
    required this.eventBus,
  }) : super(key: key);

  @override
  State<SubBoardWidget> createState() => _SubBoardWidgetState();
}

class _SubBoardWidgetState extends State<SubBoardWidget> {
  final eventBus = EventBus<BoardEventName>();

  @override
  void initState() {
    eventBus.subscribe(BoardEventName.onBoardTap, (arg) {
      widget.eventBus.publish(BoardEventName.onModelTap, widget.model.id);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BoardBodyWidget(
      boardViewModel: BoardViewModel(widget.model.data),
      eventBus: eventBus,
      pluginManager: plugins,
    );
  }
}
