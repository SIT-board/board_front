import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:json_model_undo_redo/json_model_undo_redo.dart';

import '../../util/keyboard.dart';
import 'board_body.dart';
import 'data.dart';
import 'title.dart';

class BoardPage extends StatefulWidget {
  final BoardPageSetViewModel pageSetViewModel;
  const BoardPage({
    Key? key,
    required this.pageSetViewModel,
  }) : super(key: key);

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  final keyBoardFocusNode = FocusNode();
  final eventBus = EventBus<BoardEventName>();
  late final undoRedoManager = UndoRedoManager(widget.pageSetViewModel.map);

  @override
  void initState() {
    eventBus.subscribe(BoardEventName.saveState, (arg) {
      undoRedoManager.store();
    });
    eventBus.subscribe(BoardEventName.refreshBoard, (arg) => setState(() {}));
    super.initState();
  }

  void gotoNextPage() {
    int? id = widget.pageSetViewModel.nextPageId;
    if (id == null) {
      EasyLoading.showToast('已经是最后一页了');
      return;
    }
    setState(() => widget.pageSetViewModel.currentPageId = id);
  }

  void gotoPrePage() {
    int? id = widget.pageSetViewModel.prePageId;
    if (id == null) {
      EasyLoading.showToast('已经是第一页了');
      return;
    }
    setState(() => widget.pageSetViewModel.currentPageId = id);
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
      onDeletePage: (int pageId) {
        setState(() {
          widget.pageSetViewModel.deletePage(pageId);
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
                  undoRedoManager.undo();
                  setState(() {});
                  eventBus.publish(BoardEventName.onBoardTap);
                },
          icon: const Icon(Icons.undo)),
      IconButton(
          onPressed: !undoRedoManager.canRedo
              ? null
              : () {
                  undoRedoManager.redo();
                  setState(() {});
                  eventBus.publish(BoardEventName.onBoardTap);
                },
          icon: const Icon(Icons.redo)),
      IconButton(
        onPressed: () {
          print(widget.pageSetViewModel.map);
        },
        icon: Icon(Icons.add),
      ),
    ];
  }

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
        body: BoardBodyWidget(
          eventBus: eventBus,
          boardViewModel: widget.pageSetViewModel.currentPage.board,
        ),
      ),
    );
  }
}
