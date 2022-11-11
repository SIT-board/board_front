import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board_event.dart';
import 'package:board_front/component/board_page/board_body.dart';
import 'package:board_front/component/board_page/data.dart';
import 'package:board_front/component/board_page/title.dart';
import 'package:board_front/global.dart';
import 'package:board_front/util/keyboard.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:json_model_sync/json_model_sync.dart';
import 'package:json_model_undo_redo/json_model_undo_redo.dart';
import 'package:uuid/uuid.dart';

class OwnerBoardPage extends StatefulWidget {
  const OwnerBoardPage({Key? key}) : super(key: key);

  @override
  State<OwnerBoardPage> createState() => _OwnerBoardPageState();
}

class _OwnerBoardPageState extends State<OwnerBoardPage> {
  final keyBoardFocusNode = FocusNode();
  final eventBus = EventBus<BoardEventName>();

  late var pageSetViewModel = BoardPageSetViewModel.createNew();
  late var undoRedoManager = UndoRedoManager(pageSetViewModel.map);
  String? filePath;
  int lastSaveStorePtr = -1;
  Timer? _timer;
  late final ownerBoardNode = OwnerBoardNode(
    node: BoardUserNode(
      roomId: const Uuid().v4(),
      userNodeId: const Uuid().v4(),
    ),
    model: pageSetViewModel.map,
  );

  void _saveState(arg) => undoRedoManager.store();
  void _refreshBoard(arg) => setState(() {});
  @override
  void initState() {
    ownerBoardNode.node.connect().then((value) {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        ownerBoardNode.broadcastSyncPatch();
      });
    });
    eventBus.subscribe(BoardEventName.saveState, _saveState);
    eventBus.subscribe(BoardEventName.refreshBoard, _refreshBoard);
    super.initState();
  }

  @override
  void dispose() {
    eventBus.unsubscribe(BoardEventName.saveState, _saveState);
    eventBus.unsubscribe(BoardEventName.refreshBoard, _refreshBoard);
    _timer?.cancel();
    ownerBoardNode.node.disconnect();
    super.dispose();
  }

  Future<void> saveAsFile() async {
    filePath ??= await FilePicker.platform.saveFile(
      dialogTitle: '保存白板工程',
      fileName: '${DateFormat('yyyyMMdd_hhmmss').format(DateTime.now())}.sbp',
    );
    if (filePath == null) return;
    File(filePath!).writeAsStringSync(pageSetViewModel.toJsonString());
    EasyLoading.showSuccess('保存成功');
    GlobalObjects.storage.recentlyUsed.addItem(filePath!);
    lastSaveStorePtr = undoRedoManager.currentPtr;
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
          onPressed: () {
            final screenHeight = MediaQuery.of(context).size.height;
            showDialog(
                context: context,
                builder: (context) {
                  final n = ownerBoardNode.node;
                  return Dialog(
                    child: Container(
                      height: screenHeight * 0.6,
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('参与人数：${n.onlineList.length}', style: Theme.of(context).textTheme.headline5),
                              ElevatedButton(
                                  onPressed: () async {
                                    await Clipboard.setData(ClipboardData(text: n.roomId));
                                    EasyLoading.showSuccess('白板ID已复制到剪切板');
                                  },
                                  child: const Text('复制白板ID')),
                            ],
                          ),
                          Expanded(
                            child: ListView(
                              children: n.onlineList.map((e) {
                                return ListTile(
                                  title: Text(n.getUsernameByUserId(e)),
                                  trailing: e == n.userNodeId ? Text('自己') : null,
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
          },
          icon: Icon(Icons.people)),
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
              GlobalObjects.storage.recentlyUsed.addItem(filePath!);
              pageSetViewModel.map.clear();
              pageSetViewModel.map.addAll(content);
              undoRedoManager = UndoRedoManager(pageSetViewModel.map);
              setState(() {});
            },
          ),
          PopupMenuItem(child: Text('保存'), onTap: saveAsFile),
          PopupMenuItem(
            child: Text('另存为'),
            onTap: () async {
              final otherPath = await FilePicker.platform.saveFile(
                dialogTitle: '保存白板工程',
                fileName: '${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.sbp',
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
      child: WillPopScope(
        onWillPop: () async {
          // 已经保存过了
          if (lastSaveStorePtr == undoRedoManager.currentPtr) return true;
          return await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('保存并退出？', style: Theme.of(context).textTheme.headline5),
                          ElevatedButton(
                              onPressed: () async {
                                await saveAsFile();
                                if (!mounted) return;
                                Navigator.of(context).pop(true);
                              },
                              child: Text('保存')),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text('不保存'),
                          ),
                        ],
                      ),
                    );
                  }) ==
              true;
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
      ),
    );
  }
}
