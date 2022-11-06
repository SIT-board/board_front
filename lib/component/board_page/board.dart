import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board.dart';
import 'package:board_front/component/board/board_event.dart';
import 'package:board_front/component/board/menu/menu.dart';
import 'package:board_front/util/color_picker.dart';
import 'package:flutter/material.dart';
import 'package:json_model_undo_redo/json_model_undo_redo.dart';

import 'data.dart';
import 'title.dart';

class BoardPage extends StatefulWidget {
  final BoardPageSetViewModel pageSetViewModel;
  final UndoRedoManager undoRedoManager;
  BoardPage({
    Key? key,
    required this.pageSetViewModel,
  })  : undoRedoManager = UndoRedoManager(pageSetViewModel.map),
        super(key: key);

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  final eventBus = EventBus<BoardEventName>();
  final controller = TransformationController();

  late BoardMenu boardMenu;
  UndoRedoManager get undoRedoManager => widget.undoRedoManager;
  BoardViewModel get vm => widget.pageSetViewModel.currentPage.board;
  @override
  void initState() {
    eventBus.subscribe(BoardEventName.refreshBoard, onRefreshBoardEvent);
    BoardEventName.values.toSet()
      ..removeAll([
        BoardEventName.onModelMoving,
        BoardEventName.onModelResizing,
        BoardEventName.onModelRotating,
        BoardEventName.onViewportChanged,
      ])
      ..forEach(
        (e) => eventBus.subscribe(e, (arg) {
          undoRedoManager.store();
        }),
      );
    boardMenu = BoardMenu(
      context: context,
      boardViewModelGetter: () => vm,
      eventBus: eventBus,
    );
    super.initState();
  }

  void onRefreshBoardEvent(arg) {
    final patch = undoRedoManager.store();
    if (patch.isEmpty()) return;
    setState(() {});
    print('画布刷新: $patch');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: BoardTitle(
          currentPageId: widget.pageSetViewModel.currentPageId,
          pageIdList: widget.pageSetViewModel.pageIdList,
          pageNameMap: Map.fromEntries(widget.pageSetViewModel.pageIdList
              .map((id) => MapEntry(id, widget.pageSetViewModel.getPageById(id).title))),
          onChangeTitle: (title) {
            setState(() => widget.pageSetViewModel.currentPage.title = title);
            undoRedoManager.store();
          },
          onSwitchPage: (int value) {
            setState(() => widget.pageSetViewModel.currentPageId = value);
            undoRedoManager.store();
          },
          onAddPage: () {
            setState(() {
              final newPageId = widget.pageSetViewModel.pageIdList.last + 1;
              widget.pageSetViewModel.addBoardPage(BoardPageViewModel.createNew(newPageId));
              widget.pageSetViewModel.currentPageId = newPageId;
            });
            undoRedoManager.store();
          },
        ),
        actions: [
          IconButton(
            onPressed: !undoRedoManager.canUndo
                ? null
                : () {
                    print(undoRedoManager.undo());
                    setState(() {});
                  },
            icon: Icon(Icons.undo),
          ),
          IconButton(
            onPressed: !undoRedoManager.canRedo
                ? null
                : () {
                    print(undoRedoManager.redo());
                    setState(() {});
                  },
            icon: Icon(Icons.redo),
          ),
        ],
        leading: IconButton(
            onPressed: () {
              print(vm.map);
              showBoardColorPicker(context);
            },
            icon: Icon(Icons.arrow_back)),
      ),
      body: BoardViewModelWidget(
        // 视口变换控制器
        controller: controller,
        viewModel: vm,
        eventBus: eventBus,
      ),
    );
  }
}
