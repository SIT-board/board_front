import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board.dart';
import 'package:board_front/component/interactive_infinity_layout/interactive_infinity_layout.dart';
import 'package:board_front/util/menu.dart';
import 'package:flutter/material.dart';

import 'board_event.dart';

class ModelWidget extends StatefulWidget {
  final Model model;
  final EventBus<BoardEventName> eventBus;
  final Widget Function(Model, EventBus<BoardEventName>) Function(String type) modelWidgetBuilderBuilder;

  const ModelWidget({
    Key? key,
    required this.model,
    required this.eventBus,
    required this.modelWidgetBuilderBuilder,
  }) : super(key: key);

  @override
  State<ModelWidget> createState() => _ModelWidgetState();
}

class _ModelWidgetState extends State<ModelWidget> {
  CommonModelData get modelCommon => widget.model.common;
  int get modelId => widget.model.id;
  void saveState() => widget.eventBus.publish(BoardEventName.saveState);
  Widget buildDrag() {
    return const Icon(Icons.drag_indicator);
  }

  Widget buildTop() {
    return InkWell(
      onTap: () {
        widget.eventBus.publish(BoardEventName.onModelBringToFront, modelId);
        saveState();
      },
      child: const Icon(Icons.vertical_align_top_outlined),
    );
  }

  Widget buildBottom() {
    return InkWell(
      onTap: () {
        widget.eventBus.publish(BoardEventName.onModelBringToBack, modelId);
        saveState();
      },
      child: const Icon(Icons.vertical_align_bottom_outlined),
    );
  }

  Widget buildResize() {
    return GestureDetector(
      child: const Icon(Icons.zoom_out_map),
      onPanUpdate: (d) {
        setState(() => modelCommon.size = modelCommon.constraints.constrain(modelCommon.size + d.delta));
        widget.eventBus.publish(BoardEventName.onModelResizing, modelId);
      },
      onPanEnd: (d) {
        widget.eventBus.publish(BoardEventName.onModelResized, modelId);
        saveState();
      },
    );
  }

  Widget buildRotate() {
    return GestureDetector(
      child: const Icon(Icons.rotate_left),
      onPanUpdate: (d) {
        setState(() => modelCommon.angle += (d.delta.dx + d.delta.dy) / 50);
        widget.eventBus.publish(BoardEventName.onModelRotating, modelId);
      },
      onPanEnd: (d) {
        widget.eventBus.publish(BoardEventName.onModelRotated, modelId);
        saveState();
      },
    );
  }

  Widget buildDelete() {
    return InkWell(
      child: const Icon(Icons.delete),
      onTap: () {
        widget.eventBus.publish(BoardEventName.onModelDeleted, modelId);
        widget.eventBus.publish(BoardEventName.onBoardTap);
        saveState();
      },
    );
  }

  Widget withController({required Widget child}) {
    List<Widget> buildControllerWidgetList() => [
          // 上中
          Positioned(top: 0, left: 0, right: 0, child: buildTop()),
          Positioned(bottom: 0, left: 0, right: 0, child: buildBottom()),
          // 左上
          Positioned(top: 0, left: 0, child: buildDrag()),
          // 右上
          Positioned(top: 0, right: 0, child: buildRotate()),
          Positioned(bottom: 0, right: 0, child: buildResize()),
          Positioned(left: 0, bottom: 0, child: buildDelete()),
        ];
    if (modelCommon.editableState) {
      // 为stack添加边界
      child = Container(
        decoration: BoxDecoration(
          border: Border.all(width: 2, color: Colors.blue),
        ),
        child: child,
      );
    }
    // 添加按钮stack
    child = Stack(
      fit: StackFit.loose,
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          height: modelCommon.size.bottomRight(Offset.zero).distance,
          width: modelCommon.size.bottomRight(Offset.zero).distance,
        ),
        Stack(
          children: [
            SizedBox.fromSize(size: modelCommon.size, child: child),
            if (modelCommon.editableState) ...buildControllerWidgetList(),
          ],
        )
      ],
    );

    child = Transform.rotate(angle: modelCommon.angle, child: child);

    return child;
  }

  /// 模型的局部刷新
  void onModelRefresh(arg) {
    if (arg != widget.model.id) return;
    if (!mounted) return;
    setState(() {});
  }

  @override
  void initState() {
    widget.eventBus.subscribe(BoardEventName.refreshModel, onModelRefresh);
    super.initState();
  }

  @override
  void dispose() {
    widget.eventBus.unsubscribe(BoardEventName.refreshModel, onModelRefresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!modelCommon.enable) return Container();
    // 添加边界和约束
    return withController(
      child: Container(
        constraints: modelCommon.constraints,
        child: widget.modelWidgetBuilderBuilder(widget.model.type)(widget.model, widget.eventBus),
      ),
    );
  }
}

class BoardViewModelWidget extends StatefulWidget {
  final BoardViewModel viewModel;
  final EventBus<BoardEventName> eventBus;
  final Widget Function(Model, EventBus<BoardEventName>) Function(String type) modelWidgetBuilderBuilder;

  const BoardViewModelWidget({
    Key? key,
    required this.viewModel,
    required this.eventBus,
    required this.modelWidgetBuilderBuilder,
  }) : super(key: key);

  @override
  State<BoardViewModelWidget> createState() => _BoardViewModelWidgetState();
}

class _BoardViewModelWidgetState extends State<BoardViewModelWidget> {
  final _controller = TransformationController();
  List<Model> get modelDataList => widget.viewModel.models;
  Model getModelById(int modelId) => widget.viewModel.getModelById(modelId);
  void saveState() => widget.eventBus.publish(BoardEventName.saveState);

  void _refreshBoard(arg) => setState(() {});
  void _onModelDeleted(int? modelId) {
    final e = getModelById(modelId!);
    setState(() => widget.viewModel.removeModel(e.id));
    saveState();
  }

  void _onModelTap(int? modelId) {
    final e = getModelById(modelId!);
    setState(() {
      modelDataList.forEach((e) => e.common.editableState = false);
      e.common.editableState = true;
    });
  }

  void _onModelBringToFront(int? modelId) {
    final e = getModelById(modelId!);
    List<int> indexList = widget.viewModel.models.map((e) => e.common.index).toList();
    // 置顶即设置索引为取最大数字+1
    indexList.sort();
    // 层叠关系变更
    setState(() => e.common.index = indexList.last + 1);
    saveState();
  }

  void _onModelBringToBack(int? modelId) {
    final e = getModelById(modelId!);
    List<int> indexList = widget.viewModel.models.map((e) => e.common.index).toList();
    // 置底即设置索引为取最小数字-1
    indexList.sort();
    // 层叠关系变更
    setState(() => e.common.index = indexList.first - 1);
    saveState();
  }

  void _onModelMoving(rawArgs) {
    final List arg = rawArgs as List;
    final int modelId = arg[0];
    final Offset target = arg[1];
    final e = getModelById(modelId);
    setState(() {
      modelDataList.forEach((e) => e.common.editableState = false);
      e.common.editableState = true;
      e.common.position = target;
    });
  }

  void _onModelMoved(arg) {
    // moving has refreshed, only save
    saveState();
  }

  @override
  void initState() {
    widget.eventBus
      ..subscribe(BoardEventName.refreshBoard, _refreshBoard)
      ..subscribe<int>(BoardEventName.onModelDeleted, _onModelDeleted)
      ..subscribe<int>(BoardEventName.onModelTap, _onModelTap)
      ..subscribe<int>(BoardEventName.onModelBringToFront, _onModelBringToFront)
      ..subscribe<int>(BoardEventName.onModelBringToBack, _onModelBringToBack)
      ..subscribe(BoardEventName.onModelMoving, _onModelMoving)
      ..subscribe(BoardEventName.onModelMoved, _onModelMoved);

    _controller.addListener(() {
      widget.viewModel.viewerTransform = _controller.value;
      widget.eventBus.publish(BoardEventName.onViewportChanged, _controller.value);
    });
    super.initState();
  }

  @override
  void dispose() {
    widget.eventBus
      ..unsubscribe(BoardEventName.refreshBoard, _refreshBoard)
      ..unsubscribe<int>(BoardEventName.onModelDeleted, _onModelDeleted)
      ..unsubscribe<int>(BoardEventName.onModelTap, _onModelTap)
      ..unsubscribe<int>(BoardEventName.onModelBringToFront, _onModelBringToFront)
      ..unsubscribe<int>(BoardEventName.onModelBringToBack, _onModelBringToBack)
      ..unsubscribe(BoardEventName.onModelMoving, _onModelMoving)
      ..unsubscribe(BoardEventName.onModelMoved, _onModelMoved);

    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.value = widget.viewModel.viewerTransform;
    // 按照层叠次序排序, index越大的越靠前
    List<Model> models = modelDataList;
    models.sort((a, b) => a.common.index - b.common.index);
    final layout = InteractiveInfinityLayout(
      viewerTransformationController: _controller,
      minScale: 0.3,
      maxScale: 100,
      children: models.map((e) {
        return Positioned(
          left: e.common.position.dx,
          top: e.common.position.dy,
          child: GestureDetector(
            onTap: () => widget.eventBus.publish(BoardEventName.onModelTap, e.id),
            onPanUpdate: (d) => widget.eventBus.publish(BoardEventName.onModelMoving, [
              e.id,
              e.common.position + d.delta,
            ]),
            onPanEnd: (d) => widget.eventBus.publish(BoardEventName.onModelMoved, e.id),
            onLongPressStart: (d) {
              // 坐标变换
              final globalPosition = d.globalPosition;
              final renderBox = context.findRenderObject()! as RenderBox;
              final boardLocalPosition = renderBox.globalToLocal(globalPosition);
              widget.eventBus.publish(BoardEventName.onModelMenu, [e.id, boardLocalPosition]);
            },
            child: ModelWidget(
              eventBus: widget.eventBus,
              model: e,
              modelWidgetBuilderBuilder: widget.modelWidgetBuilderBuilder,
            ),
          ),
        );
      }).toList(),
    );
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      child: layout,
      onTap: () {
        // 背景点击后取消所有模型的选中状态
        setState(() => modelDataList.forEach((e) => e.common.editableState = false));
        widget.eventBus.publish(BoardEventName.onBoardTap);
      },
    ).bindMenuEvent(onTrigger: (event) {
      widget.eventBus.publish(BoardEventName.onBoardMenu, event.localPosition);
    });
  }
}
