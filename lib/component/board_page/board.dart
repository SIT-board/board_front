import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board.dart';
import 'package:board_front/component/board/board_event.dart';
import 'package:board_front/component/board/menu/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:json_model_undo_redo/json_model_undo_redo.dart';

import 'data.dart';
import 'keyboard.dart';
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
  final keyBoardFocusNode = FocusNode();
  late BoardMenu boardMenu;
  UndoRedoManager get undoRedoManager => widget.undoRedoManager;
  BoardViewModel get currentPageBoardViewModel => widget.pageSetViewModel.currentPage.board;
  bool showEditor = false;
  Model? selectedModel;
  double s = 0.5;
  @override
  void initState() {
    eventBus.subscribe(BoardEventName.refreshBoard, onRefreshBoardEvent);
    eventBus.subscribe(BoardEventName.onModelTap, (arg) {
      setState(() => showEditor = true);
      selectedModel = arg as Model;
    });
    eventBus.subscribe(BoardEventName.onBoardTap, (arg) {
      setState(() => showEditor = false);
    });

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
      boardViewModelGetter: () => currentPageBoardViewModel,
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

  void gotoNextPage() {
    int? id = widget.pageSetViewModel.nextPageId;
    if (id == null) {
      EasyLoading.showToast('已经是最后一页了');
      return;
    }
    setState(() => widget.pageSetViewModel.currentPageId = id);
    undoRedoManager.store();
  }

  void gotoPrePage() {
    int? id = widget.pageSetViewModel.prePageId;
    if (id == null) {
      EasyLoading.showToast('已经是第一页了');
      return;
    }
    setState(() => widget.pageSetViewModel.currentPageId = id);
    undoRedoManager.store();
  }

  Widget buildTitle() {
    return BoardTitle(
      currentPageId: widget.pageSetViewModel.currentPageId,
      pageIdList: widget.pageSetViewModel.pageIdList,
      pageNameMap: Map.fromEntries(
          widget.pageSetViewModel.pageIdList.map((id) => MapEntry(id, widget.pageSetViewModel.getPageById(id).title))),
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
    );
  }

  List<Widget> buildActions() {
    return [
      IconButton(
        onPressed: !undoRedoManager.canUndo
            ? null
            : () {
                setState(() {});
              },
        icon: const Icon(Icons.undo),
      ),
      IconButton(
        onPressed: !undoRedoManager.canRedo
            ? null
            : () {
                setState(() {});
              },
        icon: const Icon(Icons.redo),
      ),
    ];
  }

  Widget buildPhone() {
    return Column(
      children: [
        Expanded(
          flex: ((1 - s) * 100).toInt(),
          child: BoardViewModelWidget(
            // 视口变换控制器
            controller: controller,
            viewModel: currentPageBoardViewModel,
            eventBus: eventBus,
          ),
        ),
        GestureDetector(
          onPanUpdate: (d) {
            final size = context.size!;
            setState(() => s -= d.delta.dy / size.height);
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              color: Colors.black12,
            ),
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
        Expanded(
          flex: ((1 - s) * 100).toInt(),
          child: BoardViewModelWidget(
            // 视口变换控制器
            controller: controller,
            viewModel: currentPageBoardViewModel,
            eventBus: eventBus,
          ),
        ),
        GestureDetector(
          onPanUpdate: (d) {
            final size = context.size!;
            setState(() => s -= d.delta.dx / size.width);
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              color: Colors.black12,
            ),
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

  Widget body = Container();

  @override
  Widget build(BuildContext context) {
    return BoardKeyMapping(
      focusNode: keyBoardFocusNode,
      onKeyDown: (key, pressedKeySet) {
        final cb = {
          LogicalKeyboardKey.pageDown: gotoNextPage,
          LogicalKeyboardKey.pageUp: gotoPrePage,
          LogicalKeyboardKey.keyC: () {
            if (!pressedKeySet.contains(LogicalKeyboardKey.control)) return;
            print('复制对象');
          },
          LogicalKeyboardKey.keyV: () {
            if (!pressedKeySet.contains(LogicalKeyboardKey.control)) return;
            print('粘贴对象');
          },
        };
        cb[key]?.call();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: buildTitle(),
          actions: buildActions(),
        ),
        body: buildPhone(),
      ),
    );
  }
}
