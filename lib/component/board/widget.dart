import 'package:board_front/component/board/board.dart';
import 'package:board_front/component/interactive_infinity_layout/interactive_infinity_layout.dart';
import 'package:flutter/material.dart';

class ModelWidget extends StatefulWidget {
  final Model model;
  final ValueSetter<Model>? onTap;
  final void Function(List<String> path, dynamic value) onChanged;
  final VoidCallback? onTopButtonClick;
  final VoidCallback? onBottomButtonClick;
  const ModelWidget({
    Key? key,
    required this.model,
    this.onTap,
    required this.onChanged,
    this.onTopButtonClick,
    this.onBottomButtonClick,
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

    // 添加按钮stack
    child = Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Transform.rotate(angle: modelCommon.angle, child: child),
        if (modelCommon.editableState) ...buildControllerWidgetList(),
      ],
    );

    if (modelCommon.editableState) {
      // 为stack添加边界
      child = Container(
        decoration: BoxDecoration(
          border: Border.all(width: 2, color: Colors.blue),
        ),
        child: child,
      );
    }
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
      height: modelCommon.size.height,
      width: modelCommon.size.width,
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
  final ValueSetter<Model>? onTap;
  final void Function(List<String> path, dynamic value) onChanged;
  const BoardViewModelWidget({
    Key? key,
    required this.viewModel,
    required this.controller,
    this.onTap,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<BoardViewModelWidget> createState() => _BoardViewModelWidgetState();
}

class _BoardViewModelWidgetState extends State<BoardViewModelWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.viewModel.viewerTransform != null) widget.controller.value = widget.viewModel.viewerTransform!;
    widget.controller.addListener(() {
      widget.viewModel.viewerTransform = widget.controller.value;
      // widget.onChanged(['viewerTransform'], widget.viewModel.map['viewerTransform']);
    });
    // 按照层叠次序排序, index越大的越靠前
    List<Model> models = widget.viewModel.models.entries.map((e) => e.value).toList();
    models.sort((a, b) => a.common.index - b.common.index);
    return InteractiveInfinityLayout(
      viewerTransformationController: widget.controller,
      minScale: 0.3,
      maxScale: 100,
      children: models.map((e) {
        Widget child = ModelWidget(
          model: e,
          onTap: widget.onTap,
          onChanged: (p, v) => widget.onChanged(['models', e.id, ...p], v),
          onTopButtonClick: () {
            List<int> indexList = widget.viewModel.models.entries.map((e) => e.value.common.index).toList();
            indexList.sort();
            // 层叠关系变更
            setState(() => e.common.index = indexList.last + 1);
          },
          onBottomButtonClick: () {
            List<int> indexList = widget.viewModel.models.entries.map((e) => e.value.common.index).toList();
            indexList.sort();
            // 层叠关系变更
            setState(() => e.common.index = indexList.first - 1);
          },
        );
        child = GestureDetector(
          onTap: () {
            setState(() {
              models.forEach((e) => e.common.editableState = false);
              e.common.editableState = true;
            });
          },
          onPanUpdate: (d) {
            setState(() {
              models.forEach((e) => e.common.editableState = false);
              e.common.editableState = true;
              e.common.position += d.delta;
            });
          },
          child: child,
        );
        return Positioned(
          left: e.common.position.dx,
          top: e.common.position.dy,
          child: child,
        );
      }).toList(),
    );
  }
}
