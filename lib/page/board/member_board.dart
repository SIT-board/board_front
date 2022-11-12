import 'dart:async';
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

class MemberBoardPage extends StatefulWidget {
  final String roomId;
  const MemberBoardPage({Key? key, required this.roomId}) : super(key: key);

  @override
  State<MemberBoardPage> createState() => _MemberBoardPageState();
}

class _MemberBoardPageState extends State<MemberBoardPage> {
  final keyBoardFocusNode = FocusNode();
  final eventBus = EventBus<BoardEventName>();

  final BoardPageSetViewModel pageSetViewModel = BoardPageSetViewModel.createNew();
  late final UndoRedoManager undoRedoManager;
  bool _hasModel = false;

  String? filePath;
  Timer? _timer;

  late final String _ownerUserId;
  late final memberBoardNode = MemberBoardNode(
    node: BoardUserNode(
      mqttServer: GlobalObjects.storage.server.mqttHost,
      mqttPort: GlobalObjects.storage.server.mqttPort,
      roomId: widget.roomId,
      userNodeId: const Uuid().v4(),
    ),
    model: pageSetViewModel.map,
    onModelRefresh: (message) {
      undoRedoManager = UndoRedoManager(pageSetViewModel.map);
      setState(() {
        _hasModel = true;
        _ownerUserId = message.publisher;
      });

      // 收到了模型数据，可以开始监听了
      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        memberBoardNode.broadcastSyncPatch(beforeSend: (patch) {
          // 无论什么时候都不把member的视角数据广播出去
          patch.removeWhere((type, key, value) {
            return key.contains('viewerTransform') || key.contains('currentPageId');
          });
        });
      });
      // 每3秒钟轮询一次在线列表检查主持人是否存在
      // 如果不存在，那么退出会议
      Timer.periodic(const Duration(seconds: 2), (timer) {
        if (!memberBoardNode.node.onlineList.contains(_ownerUserId)) {
          timer.cancel();
          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('会议已结束'),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('退出会议'),
                    ),
                  ],
                ),
              );
            },
          ).then((value) {
            Navigator.of(context).pop();
          });
        }
      });
    },
    onModelChangeBefore: (patch) {
      // 非只读模式需要删除一些视角信息
      if (!pageSetViewModel.memberReadOnly) {
        // 删除owner的视角数据
        patch.removeWhere((type, key, value) {
          return key.contains('viewerTransform') || key.contains('currentPageId');
        });
      }
    },
    onModelChanged: (patch) => setState(() {}),
  );

  void _saveState(arg) => undoRedoManager.store();
  void _refreshBoard(arg) => setState(() {});
  @override
  void initState() {
    memberBoardNode.node.connect().then((value) async {
      // 发起白板数据请求
      memberBoardNode.requestBoardModel();

      // 等待五秒
      await Future.delayed(const Duration(seconds: 5));

      // 还是没收到模型数据
      if (!_hasModel) {
        EasyLoading.showError('房间号有误');
        if (!mounted) return;
        Navigator.of(context).pop();
      }
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
    memberBoardNode.node.disconnect();
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
      onTap: () => eventBus.publish(BoardEventName.onBoardTap),
    );
  }

  List<Widget> buildActions() {
    return [
      IconButton(
        onPressed: () => showJoinDialog(context, memberBoardNode.node, _ownerUserId),
        icon: const Icon(Icons.people),
      ),
      IconButton(
          onPressed: !undoRedoManager.canUndo || pageSetViewModel.memberReadOnly
              ? null
              : () {
                  undoRedoManager.undo();
                  setState(() {});
                  eventBus.publish(BoardEventName.onBoardTap);
                },
          icon: const Icon(Icons.undo)),
      IconButton(
          onPressed: !undoRedoManager.canRedo || pageSetViewModel.memberReadOnly
              ? null
              : () {
                  undoRedoManager.redo();
                  setState(() {});
                  eventBus.publish(BoardEventName.onBoardTap);
                },
          icon: const Icon(Icons.redo)),
      PopupMenuButton(itemBuilder: (context) {
        return [
          PopupMenuItem(onTap: saveAsFile, child: const Text('保存')),
          PopupMenuItem(
            child: const Text('另存为'),
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
              child: const Text('项目信息'),
              onTap: () {
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
              })
        ];
      }),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasModel) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text('正在进入房间...'),
          ],
        ),
      );
    }
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
        body: AbsorbPointer(
          absorbing: pageSetViewModel.memberReadOnly,
          child: BoardBodyWidget(
            eventBus: eventBus,
            boardViewModel: pageSetViewModel.currentPage.board,
          ),
        ),
      ),
    );
  }
}
