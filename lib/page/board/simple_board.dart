import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board_event.dart';
import 'package:board_front/component/board_page/board_body.dart';
import 'package:board_front/component/board_page/data.dart';
import 'package:board_front/component/board_page/title.dart';
import 'package:board_front/util/keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:json_model_undo_redo/json_model_undo_redo.dart';
import 'package:board_front/component/board_page/plugins/plugins.dart';

class SimpleBoardPage extends StatefulWidget {
  const SimpleBoardPage({Key? key}) : super(key: key);

  @override
  State<SimpleBoardPage> createState() => _SimpleBoardPageState();
}

class _SimpleBoardPageState extends State<SimpleBoardPage> {
  final keyBoardFocusNode = FocusNode();
  final eventBus = EventBus<BoardEventName>();

  late var pageSetViewModel = BoardPageSetViewModel.createNew();
  late var undoRedoManager = UndoRedoManager(pageSetViewModel.map);

  void _saveState(arg) => undoRedoManager.store();
  void _refreshBoard(arg) => setState(() {});
  final pluginManager = BoardModelPluginManager(
    initialPlugins: [
      RectModelPlugin(),
      LineModelPlugin(),
      OvalModelPlugin(),
      SvgModelPlugin(),
      FreeStyleModelPlugin(),
      HtmlModelPlugin(),
      MarkdownModelPlugin(),
      SubBoardModelPlugin(),
    ],
  );

  @override
  void initState() {
    eventBus.subscribe(BoardEventName.saveState, _saveState);
    eventBus.subscribe(BoardEventName.refreshBoard, _refreshBoard);
    super.initState();
  }

  @override
  void dispose() {
    eventBus.unsubscribe(BoardEventName.saveState, _saveState);
    eventBus.unsubscribe(BoardEventName.refreshBoard, _refreshBoard);
    super.dispose();
  }

  void gotoNextPage() {
    int? id = pageSetViewModel.nextPageId;
    if (id == null) {
      EasyLoading.showToast('已经是最后一页了');
      return;
    }
    setState(() => pageSetViewModel.currentPageId = id);
  }

  void gotoPrePage() {
    int? id = pageSetViewModel.prePageId;
    if (id == null) {
      EasyLoading.showToast('已经是第一页了');
      return;
    }
    setState(() => pageSetViewModel.currentPageId = id);
  }

  Widget buildTitle() {
    return BoardTitle(
      currentPageId: pageSetViewModel.currentPageId,
      pageIdList: pageSetViewModel.pageIdList,
      pageNameMap: Map.fromEntries(pageSetViewModel.pageIdList
          .map((id) => MapEntry(id, pageSetViewModel.getPageById(id).title))),
      onChangeTitle: (title) {
        setState(() => pageSetViewModel.currentPage.title = title);
        undoRedoManager.store();
      },
      onSwitchPage: (int value) {
        setState(() => pageSetViewModel.currentPageId = value);
        undoRedoManager.store();
      },
      onAddPage: () {
        setState(() {
          final newPageId = pageSetViewModel.pageIdList.last + 1;
          pageSetViewModel
              .addBoardPage(BoardPageViewModel.createNew(newPageId));
          pageSetViewModel.currentPageId = newPageId;
        });
        undoRedoManager.store();
      },
      onDeletePage: (int pageId) {
        setState(() {
          pageSetViewModel.deletePage(pageId);
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
      PopupMenuButton(itemBuilder: (context) {
        return [
          PopupMenuItem(
              child: const Text('项目信息'),
              onTap: () {
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('项目信息',
                                  style: Theme.of(context).textTheme.headline5),
                              Text('页数：${pageSetViewModel.pageIdList.length}'),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('关闭')),
                                ],
                              ),
                            ],
                          ),
                        );
                      });
                });
              })
        ];
      }),
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
          boardViewModel: pageSetViewModel.currentPage.board,
          pluginManager: pluginManager,
        ),
      ),
    );
  }
}
