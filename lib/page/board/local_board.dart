import 'dart:convert';
import 'dart:io';

import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board_event.dart';
import 'package:board_front/component/board_page/board_body.dart';
import 'package:board_front/component/board_page/data.dart';
import 'package:board_front/component/board_page/title.dart';
import 'package:board_front/util/keyboard.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:json_model_undo_redo/json_model_undo_redo.dart';

class LocalBoardPage extends StatefulWidget {
  const LocalBoardPage({Key? key}) : super(key: key);

  @override
  State<LocalBoardPage> createState() => _LocalBoardPageState();
}

class _LocalBoardPageState extends State<LocalBoardPage> {
  final keyBoardFocusNode = FocusNode();
  final eventBus = EventBus<BoardEventName>();
  final pageSetViewModel = BoardPageSetViewModel.createNew();
  late var undoRedoManager = UndoRedoManager(pageSetViewModel.map);
  String? filePath;
  void _saveState(arg) => undoRedoManager.store();
  void _refreshBoard(arg) => setState(() {});
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
      pageNameMap: Map.fromEntries(
          pageSetViewModel.pageIdList.map((id) => MapEntry(id, pageSetViewModel.getPageById(id).title))),
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
          pageSetViewModel.addBoardPage(BoardPageViewModel.createNew(newPageId));
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
            child: Text('打开本地文件'),
            onTap: () async {
              final result = await FilePicker.platform.pickFiles(
                dialogTitle: '打开一个白板工程文件',
                type: FileType.custom,
                allowedExtensions: ['sbp'],
              );
              String? path = result?.files.single.path;
              if (path == null) return;
              final content = (jsonDecode(File(path).readAsStringSync()) as Map).cast<String, dynamic>();
              // 解析成功
              filePath = path;
              pageSetViewModel.map.clear();
              pageSetViewModel.map.addAll(content);
              undoRedoManager = UndoRedoManager(pageSetViewModel.map);
              setState(() {});
            },
          ),
          PopupMenuItem(
            child: Text('保存'),
            onTap: () async {
              filePath ??= await FilePicker.platform.saveFile(
                dialogTitle: '保存白板工程',
                fileName: '${DateFormat('yyyyMMdd_hhmmss').format(DateTime.now())}.sbp',
              );
              if (filePath == null) return;
              File(filePath!).writeAsStringSync(pageSetViewModel.toJsonString());
              EasyLoading.showSuccess('保存成功');
            },
          ),
          PopupMenuItem(
            child: Text('另存为'),
            onTap: () async {
              final otherPath = await FilePicker.platform.saveFile(
                dialogTitle: '保存白板工程',
                fileName: '${DateFormat('yyyyMMdd_hhmmss').format(DateTime.now())}.sbp',
              );
              if (otherPath == null) return;
              filePath = otherPath;
              File(filePath!).writeAsStringSync(pageSetViewModel.toJsonString());
              EasyLoading.showSuccess('保存成功');
            },
          ),
          PopupMenuItem(
              child: Text('项目信息'),
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
                              Text('项目信息', style: Theme.of(context).textTheme.headline5),
                              Text('页数：${pageSetViewModel.pageIdList.length}'),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: Text('关闭')),
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
        ),
      ),
    );
  }
}
