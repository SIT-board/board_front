import 'package:board_front/component/board/board.dart';
import 'package:flutter/material.dart';
import 'package:interactive_infinity_container/interactive_infinity_container.dart';

class ModelWidget extends StatefulWidget {
  final Model model;
  final ValueSetter<Model>? onTap;
  final void Function(List<String> path, dynamic value) onChanged;
  final VoidCallback? onTopButtonClick;
  const ModelWidget({
    Key? key,
    required this.model,
    this.onTap,
    required this.onChanged,
    this.onTopButtonClick,
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
      onTap: () {
        MyNotification().dispatch(context);
        widget.onTopButtonClick?.call();
      },
      child: const Icon(Icons.vertical_align_top_outlined),
    );
  }

  Widget buildResize() {
    return GestureDetector(
      child: const Icon(Icons.zoom_out_map),
      onPanUpdate: (d) {
        setState(() => modelCommon.size = modelCommon.constraints.constrain(modelCommon.size + d.delta));
        widget.onChanged(['common', 'size'], modelCommon.map['size']);
      },
    );
  }

  Widget buildRotate() {
    return GestureDetector(
      child: const Icon(Icons.rotate_left),
      onPanUpdate: (d) {
        setState(() => modelCommon.angle += (d.delta.dx + d.delta.dy) / 50);
        widget.onChanged(['common', 'angle'], modelCommon.angle);
      },
    );
  }

  Widget buildDelete() {
    return InkWell(
      child: const Icon(Icons.delete),
      onTap: () {
        setState(() => modelCommon.enable = false);
        widget.onChanged(['common', 'enable'], modelCommon.enable);
      },
    );
  }

  Widget withController({required Widget child}) {
    // 添加边界顺便约束
    child = Container(
      alignment: Alignment.center,
      constraints: modelCommon.constraints,
      height: modelCommon.size.height,
      width: modelCommon.size.width,
      child: child,
    );

    List<Widget> buildControllerWidgetList() => [
          // 上中
          Positioned(top: 0, left: 0, right: 0, child: buildTop()),
          // 左上
          Positioned(top: 0, left: 0, child: buildDrag()),
          // 右上
          Positioned(top: 0, right: 0, child: buildRotate()),
          Positioned(bottom: 0, right: 0, child: buildResize()),
          Positioned(left: 0, bottom: 0, child: buildDelete()),
        ];

    // 添加按钮stack
    child = Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Transform.rotate(angle: modelCommon.angle, child: child),
        if (modelCommon.editableState) ...buildControllerWidgetList(),
      ],
    );

    // 为stack添加边界
    child = Container(
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: Colors.blue),
      ),
      child: child,
    );
    return child;
  }

  @override
  Widget build(BuildContext context) {
    if (!modelCommon.enable) return Container();
    Widget modelWidget = ModelWidgetBuilder(widget.model).build();
    return withController(
      child: modelWidget,
    );
  }
}

class MyNotification extends Notification {}

class CanvasViewModelWidget extends StatefulWidget {
  final BoardViewModel viewModel;
  final TransformationController controller;
  final ValueSetter<Model>? onTap;
  final void Function(List<String> path, dynamic value) onChanged;
  const CanvasViewModelWidget({
    Key? key,
    required this.viewModel,
    required this.controller,
    this.onTap,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<CanvasViewModelWidget> createState() => _CanvasViewModelWidgetState();
}

class _CanvasViewModelWidgetState extends State<CanvasViewModelWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.viewModel.viewerTransform != null) widget.controller.value = widget.viewModel.viewerTransform!;
    widget.controller.addListener(() {
      widget.viewModel.viewerTransform = widget.controller.value;
      widget.onChanged(['viewerTransform'], widget.viewModel.map['viewerTransform']);
    });
    List<Model> models = widget.viewModel.models.entries.map((e) => e.value).toList();
    models.sort((a, b) => a.common.index - b.common.index);
    return NotificationListener<MyNotification>(
      onNotification: (notification) {
        setState(() {});
        return false;
      },
      child: InteractiveInfinityContainer(
        viewerTransformationController: widget.controller,
        minScale: 0.3,
        maxScale: 100,
        children: models.map((e) {
          final modelWidget = ModelWidget(
            model: e,
            onTap: widget.onTap,
            onChanged: (p, v) => widget.onChanged(['models', e.id, ...p], v),
            onTopButtonClick: () {
              List<int> indexList = widget.viewModel.models.entries.map((e) => e.value.common.index).toList();
              indexList.sort();
              e.common.index = indexList.last + 1;
            },
          );
          return Panel(
              widget: modelWidget,
              position: e.common.position,
              onMoved: (position) {
                e.common.position = position;
                widget.onChanged(['models', e.id, 'common', 'position'], e.common.map['position']);
              },
              onTap: () {
                if (e.common.editableState) e.common.editableState = false;
                models.forEach((e) => e.common.editableState = false);
                e.common.editableState = true;
                setState(() {});
              });
        }).toList(),
      ),
    );
  }
}
