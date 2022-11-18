import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board.dart';
import 'package:board_front/component/board/board_event.dart';
import 'package:board_front/component/board/plugins/plugins.dart';
import 'package:flutter/material.dart';

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
  late final boardMenu = BoardMenu(
    context: context,
    boardViewModelGetter: () => currentPageBoardViewModel,
    eventBus: eventBus,
  );

  void _onBoardMenu(arg) {
    boardMenu.showBoardMenu(context, arg as Offset);
  }

  void _onModelMenu(arg) {
    final modelId = arg[0] as int;
    final pos = arg[1] as Offset;
    final model = currentPageBoardViewModel.getModelById(modelId);
    boardMenu.showModelMenu(context, pos, model);
  }

  void _onModelTap(arg) {
    setState(() => showEditor = true);
    selectedModel = currentPageBoardViewModel.getModelById(arg as int);
  }

  void _onBoardTap(arg) {
    setState(() => showEditor = false);
  }

  @override
  void initState() {
    eventBus.subscribe(BoardEventName.onModelTap, _onModelTap);
    eventBus.subscribe(BoardEventName.onBoardTap, _onBoardTap);
    eventBus.subscribe(BoardEventName.onBoardMenu, _onBoardMenu);
    eventBus.subscribe(BoardEventName.onModelMenu, _onModelMenu);
    super.initState();
  }

  @override
  void dispose() {
    eventBus.unsubscribe(BoardEventName.onModelTap, _onModelTap);
    eventBus.unsubscribe(BoardEventName.onBoardTap, _onBoardTap);
    eventBus.unsubscribe(BoardEventName.onBoardMenu, _onBoardMenu);
    eventBus.unsubscribe(BoardEventName.onModelMenu, _onModelMenu);
    super.dispose();
  }

  Widget buildBoardView() {
    return BoardViewModelWidget(
      // 视口变换控制器
      viewModel: currentPageBoardViewModel,
      eventBus: eventBus,
    );
  }

  Widget buildBody(Orientation orientation) {
    Widget buildHorizontalDivider() => GestureDetector(
          onPanUpdate: (d) {
            final size = context.size!;
            setState(() => s -= d.delta.dy / size.height);
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeRow,
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.black26), color: Colors.black12),
              height: 8,
            ),
          ),
        );
    Widget buildVerticalDivider() => GestureDetector(
          onPanUpdate: (d) {
            final size = context.size!;
            setState(() => s -= d.delta.dx / size.width);
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.black26), color: Colors.black12),
              width: 5,
            ),
          ),
        );
    return Flex(
      direction: {
        Orientation.landscape: Axis.horizontal,
        Orientation.portrait: Axis.vertical,
      }[orientation]!,
      children: [
        Expanded(flex: ((1 - s) * 100).toInt(), child: buildBoardView()),
        if (showEditor)
          {
            Orientation.landscape: buildVerticalDivider,
            Orientation.portrait: buildHorizontalDivider,
          }[orientation]!(),
        if (showEditor)
          Expanded(
            flex: (s * 100).toInt(),
            child: SingleChildScrollView(
              child: defaultModelPlugins.getPluginByModelType(selectedModel!.type).buildModelEditor(
                    selectedModel!,
                    eventBus,
                  ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        return buildBody(orientation);
      },
    );
  }
}
