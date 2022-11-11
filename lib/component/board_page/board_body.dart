import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board.dart';
import 'package:board_front/component/board/board_event.dart';
import 'package:flutter/material.dart';
import 'package:platform_widget/platform_widget.dart';

import 'menu/menu.dart';

class BoardBodyWidget extends StatefulWidget {
  final BoardViewModel boardViewModel;
  final EventBus<BoardEventName> eventBus;

  const BoardBodyWidget({
    Key? key,
    required this.boardViewModel,
    required this.eventBus,
  }) : super(key: key);

  @override
  State<BoardBodyWidget> createState() => _BoardBodyWidgetState();
}

class _BoardBodyWidgetState extends State<BoardBodyWidget> {
  BoardViewModel get currentPageBoardViewModel => widget.boardViewModel;
  bool showEditor = false;
  Model? selectedModel;
  double s = 0.5;

  EventBus<BoardEventName> get eventBus => widget.eventBus;
  late final boardMenu;

  @override
  void initState() {
    eventBus.subscribe(BoardEventName.onModelTap, (arg) {
      setState(() => showEditor = true);
      selectedModel = currentPageBoardViewModel.getModelById(arg as int);
    });
    eventBus.subscribe(BoardEventName.onBoardTap, (arg) {
      setState(() => showEditor = false);
    });
    boardMenu = BoardMenu(
      context: context,
      boardViewModelGetter: () => currentPageBoardViewModel,
      eventBus: eventBus,
    );
    super.initState();
  }

  Widget buildBoardView() {
    return BoardViewModelWidget(
      // 视口变换控制器
      viewModel: currentPageBoardViewModel,
      eventBus: eventBus,
    );
  }

  Widget buildPhone() {
    return Column(
      children: [
        Expanded(flex: ((1 - s) * 100).toInt(), child: buildBoardView()),
        if (showEditor)
          GestureDetector(
            onPanUpdate: (d) {
              final size = context.size!;
              setState(() => s -= d.delta.dy / size.height);
            },
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.black26), color: Colors.black12),
              height: 5,
            ),
          ),
        if (showEditor)
          Expanded(
            flex: (s * 100).toInt(),
            child: SingleChildScrollView(
              child: ModelWidgetBuilder(model: selectedModel!, eventBus: eventBus).buildModelEditorWidget(),
            ),
          ),
      ],
    );
  }

  Widget buildDesktop() {
    return Row(
      children: [
        Expanded(flex: ((1 - s) * 100).toInt(), child: buildBoardView()),
        if (showEditor)
          GestureDetector(
            onPanUpdate: (d) {
              final size = context.size!;
              setState(() => s -= d.delta.dx / size.width);
            },
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.black26), color: Colors.black12),
              width: 5,
            ),
          ),
        if (showEditor)
          Expanded(
            flex: (s * 100).toInt(),
            child: SingleChildScrollView(
              child: ModelWidgetBuilder(model: selectedModel!, eventBus: eventBus).buildModelEditorWidget(),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MyPlatformWidget(
      desktopOrWebBuilder: (ctx) => buildDesktop(),
      mobileBuilder: (ctx) => buildPhone(),
    );
  }
}
