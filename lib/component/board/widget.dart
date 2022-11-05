import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board.dart';
import 'package:board_front/component/interactive_infinity_layout/interactive_infinity_layout.dart';
import 'package:flutter/material.dart';

import 'board_event.dart';

class ModelWidget extends StatefulWidget {
  final Model model;
  final VoidCallback? onTopButtonClick;
  final VoidCallback? onBottomButtonClick;
  final VoidCallback? onDeleteButtonClick;
  final EventBus<BoardEventName>? eventBus;
  const ModelWidget({
    Key? key,
    required this.model,
    this.onTopButtonClick,
    this.onBottomButtonClick,
    this.onDeleteButtonClick,
    this.eventBus,
  }) : super(key: key);

  @override
  State<ModelWidget> createState() => _ModelWidgetState();
}

class _ModelWidgetState extends State<ModelWidget> {
  CommonModelData get modelCommon => widget.model.common;

  Widget buildDrag() {
    return const Icon(Icons.drag_indicator);
  }

  Widget buildTop() {
    return InkWell(
      onTap: () => widget.onTopButtonClick?.call(),
      child: const Icon(Icons.vertical_align_top_outlined),
    );
  }

  Widget buildBottom() {
    return InkWell(
      onTap: () => widget.onBottomButtonClick?.call(),
      child: const Icon(Icons.vertical_align_bottom_outlined),
    );
  }

  Widget buildResize() {
    return GestureDetector(
      child: const Icon(Icons.zoom_out_map),
      onPanUpdate: (d) {
        setState(() => modelCommon.size = modelCommon.constraints.constrain(modelCommon.size + d.delta));
        widget.eventBus?.publish(BoardEventName.onModelResizing, widget.model);
      },
      onPanEnd: (d) {
        widget.eventBus?.publish(BoardEventName.onModelResized, widget.model);
      },
    );
  }

  Widget buildRotate() {
    return GestureDetector(
      child: const Icon(Icons.rotate_left),
      onPanUpdate: (d) {
        setState(() => modelCommon.angle += (d.delta.dx + d.delta.dy) / 50);
        widget.eventBus?.publish(BoardEventName.onModelRotating, widget.model);
      },
      onPanEnd: (d) {
        widget.eventBus?.publish(BoardEventName.onModelRotated, widget.model);
      },
    );
  }

  Widget buildDelete() {
    return InkWell(
      child: const Icon(Icons.delete),
      onTap: () => widget.onDeleteButtonClick?.call(),
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

  @override
  Widget build(BuildContext context) {
    if (!modelCommon.enable) return Container();
    Widget child = ModelWidgetBuilder(widget.model).build();
    // 添加边界和约束
    child = Container(
      alignment: Alignment.center,
      constraints: modelCommon.constraints,
      child: child,
    );
    return withController(
      child: child,
    );
  }
}

class BoardViewModelWidget extends StatefulWidget {
  final BoardViewModel viewModel;
  final TransformationController controller;
  final EventBus<BoardEventName>? eventBus;
  const BoardViewModelWidget({
    Key? key,
    required this.viewModel,
    required this.controller,
    this.eventBus,
  }) : super(key: key);

  @override
  State<BoardViewModelWidget> createState() => _BoardViewModelWidgetState();
}

class _BoardViewModelWidgetState extends State<BoardViewModelWidget> {
  List<Model> get modelDataList => widget.viewModel.models;

  Widget buildModelWidget(Model e) {
    return ModelWidget(
      eventBus: widget.eventBus,
      model: e,
      onTopButtonClick: () {
        List<int> indexList = widget.viewModel.models.map((e) => e.common.index).toList();
        // 置顶即设置索引为取最大数字+1
        indexList.sort();
        // 层叠关系变更
        setState(() => e.common.index = indexList.last + 1);
        widget.eventBus?.publish(BoardEventName.onModelBringToFront, e);
      },
      onBottomButtonClick: () {
        List<int> indexList = widget.viewModel.models.map((e) => e.common.index).toList();
        // 置底即设置索引为取最小数字-1
        indexList.sort();
        // 层叠关系变更
        setState(() => e.common.index = indexList.first - 1);
        widget.eventBus?.publish(BoardEventName.onModelBringToBack, e);
      },
      onDeleteButtonClick: () {
        setState(() => widget.viewModel.removeModel(e.id));
        widget.eventBus?.publish(BoardEventName.onModelDeleted, e);
      },
    );
  }

  void onModelWidgetTap(Model e) {
    setState(() {
      modelDataList.forEach((e) => e.common.editableState = false);
      e.common.editableState = true;
    });
    widget.eventBus?.publish(BoardEventName.onModelTap, e);
  }

  void onModelMove(Model e, Offset target) {
    setState(() {
      modelDataList.forEach((e) => e.common.editableState = false);
      e.common.editableState = true;
      e.common.position = target;
    });
    widget.eventBus?.publish(BoardEventName.onModelMoving, e);
  }

  @override
  Widget build(BuildContext context) {
    widget.controller.value = widget.viewModel.viewerTransform;
    widget.controller.addListener(() {
      widget.viewModel.viewerTransform = widget.controller.value;
      widget.eventBus?.publish(BoardEventName.onViewportChanged, widget.controller.value);
    });
    // 按照层叠次序排序, index越大的越靠前
    List<Model> models = modelDataList;
    models.sort((a, b) => a.common.index - b.common.index);
    final layout = InteractiveInfinityLayout(
      viewerTransformationController: widget.controller,
      minScale: 0.3,
      maxScale: 100,
      children: models.map((e) {
        return Positioned(
          left: e.common.position.dx,
          top: e.common.position.dy,
          child: GestureDetector(
            onTap: () => onModelWidgetTap(e),
            onPanUpdate: (d) => onModelMove(e, e.common.position + d.delta),
            onPanEnd: (d) => widget.eventBus?.publish(BoardEventName.onModelMoved, e),
            child: buildModelWidget(e),
          ),
        );
      }).toList(),
    );
    return GestureDetector(
      child: layout,
      onTap: () {
        // 背景点击后取消所有模型的选中状态
        setState(() {
          modelDataList.forEach((e) => e.common.editableState = false);
        });
        widget.eventBus?.publish(BoardEventName.onBoardTap);
      },
    );
  }
}
