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

import 'common.dart';

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
      mqttServer: GlobalObjects.storage.server.mqttHost,
      mqttPort: GlobalObjects.storage.server.mqttPort,
      roomId: const Uuid().v4(),
      // roomId: '123456',
      userNodeId: const Uuid().v4(),
    ),
    model: pageSetViewModel.map,
    onModelChanged: (patch) => setState(() {}),
  );

  void _saveState(arg) => undoRedoManager.store();
  void _refreshBoard(arg) => setState(() {});
  @override
  void initState() {
    ownerBoardNode.node.connect().then((value) {
      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
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
      dialogTitle: '??????????????????',
      fileName: '${DateFormat('yyyyMMdd_hhmmss').format(DateTime.now())}.sbp',
    );
    if (filePath == null) return;
    File(filePath!).writeAsStringSync(pageSetViewModel.toJsonString());
    EasyLoading.showSuccess('????????????');
    GlobalObjects.storage.recentlyUsed.addItem(filePath!);
    lastSaveStorePtr = undoRedoManager.currentPtr;
  }

  void gotoNextPage() {
    int? id = pageSetViewModel.nextPageId;
    if (id == null) {
      EasyLoading.showToast('????????????????????????');
      return;
    }
    setState(() => pageSetViewModel.currentPageId = id);
  }

  void gotoPrePage() {
    int? id = pageSetViewModel.prePageId;
    if (id == null) {
      EasyLoading.showToast('?????????????????????');
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

  Future<void> showBoardModeDialog() async {
    final n = ValueNotifier<bool>(pageSetViewModel.memberReadOnly);

    await showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('??????????????????', style: Theme.of(context).textTheme.headline5),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('???????????????'),
                    ValueListenableBuilder(
                      valueListenable: n,
                      builder: (context, thisValue, child) {
                        return Switch(
                            value: thisValue,
                            onChanged: (thatValue) {
                              n.value = thatValue;
                            });
                      },
                    ),
                  ],
                ),
                ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: Text('??????')),
              ],
            ),
          );
        });
    pageSetViewModel.memberReadOnly = n.value;
    n.dispose();
  }

  List<Widget> buildActions() {
    return [
      IconButton(
        onPressed: () => showJoinDialog(context, ownerBoardNode.node, ownerBoardNode.node.userNodeId),
        icon: const Icon(Icons.people),
      ),
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
            onTap: () => WidgetsBinding.instance.addPostFrameCallback((timeStamp) => showBoardModeDialog()),
            child: Text('??????????????????'),
          ),
          PopupMenuItem(
            child: const Text('??????????????????'),
            onTap: () async {
              final result = await FilePicker.platform.pickFiles(
                dialogTitle: '??????????????????????????????',
                type: FileType.custom,
                allowedExtensions: ['sbp'],
              );
              String? path = result?.files.single.path;
              if (path == null) return;
              final content = (jsonDecode(File(path).readAsStringSync()) as Map).cast<String, dynamic>();
              // ????????????
              filePath = path;
              GlobalObjects.storage.recentlyUsed.addItem(filePath!);
              pageSetViewModel.map.clear();
              pageSetViewModel.map.addAll(content);
              undoRedoManager = UndoRedoManager(pageSetViewModel.map);
              setState(() {});
            },
          ),
          PopupMenuItem(child: const Text('??????'), onTap: saveAsFile),
          PopupMenuItem(
            child: const Text('?????????'),
            onTap: () async {
              final otherPath = await FilePicker.platform.saveFile(
                dialogTitle: '??????????????????',
                fileName: '${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.sbp',
              );
              if (otherPath == null) return;
              filePath = otherPath;
              File(filePath!).writeAsStringSync(pageSetViewModel.toJsonString());
              EasyLoading.showSuccess('????????????');
            },
          ),
          PopupMenuItem(
              child: const Text('????????????'),
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
                              Text('????????????', style: Theme.of(context).textTheme.headline5),
                              Text('?????????${pageSetViewModel.pageIdList.length}'),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('??????')),
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
          // ??????????????????
          if (lastSaveStorePtr == undoRedoManager.currentPtr) return true;
          return await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('??????????????????', style: Theme.of(context).textTheme.headline5),
                          ElevatedButton(
                              onPressed: () async {
                                await saveAsFile();
                                if (!mounted) return;
                                Navigator.of(context).pop(true);
                              },
                              child: const Text('??????')),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('?????????'),
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
            pluginManager: defaultModelPluginManager,

          ),
        ),
      ),
    );
  }
}
