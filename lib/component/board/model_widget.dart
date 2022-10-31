import 'package:flutter/material.dart';
import 'package:interactive_infinity_container/interactive_infinity_container.dart';

import 'base_model_widget.dart';
import 'model.dart';

class ModelWidget extends StatefulWidget {
  final Model model;
  final ValueSetter<Model>? onTap;
  final void Function(List<String> path, dynamic value) onChanged;
  const ModelWidget({
    Key? key,
    required this.model,
    this.onTap,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<ModelWidget> createState() => _ModelWidgetState();
}

/// 角落按钮直径
const _floatingActionDiameter = 18.0;

/// 悬浮按钮
class _FloatingActionIcon extends StatelessWidget {
  const _FloatingActionIcon({
    Key? key,
    required this.iconData,
    this.onTap,
  }) : super(key: key);

  final IconData iconData;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      clipBehavior: Clip.hardEdge,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: _floatingActionDiameter,
          width: _floatingActionDiameter,
          child: Center(
            child: Icon(iconData, color: Colors.blue, size: 12),
          ),
        ),
      ),
    );
  }
}

class _ModelWidgetState extends State<ModelWidget> {
  bool showEditor = true;

  CommonModelData get modelCommon => widget.model.common;

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

    // 添加按钮stack
    child = Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Transform.rotate(angle: modelCommon.angle, child: child),
        if (showEditor) Positioned(top: 0, right: 0, child: buildRotate()),
        if (showEditor) Positioned(bottom: 0, right: 0, child: buildResize()),
        if (showEditor) Positioned(left: 0, bottom: 0, child: buildDelete()),
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

class CanvasViewModelWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (viewModel.viewerTransform != null) controller.value = viewModel.viewerTransform!;
    controller.addListener(() {
      viewModel.viewerTransform = controller.value;
      onChanged(['viewerTransform'], viewModel.map['viewerTransform']);
    });
    return InteractiveInfinityContainer(
      viewerTransformationController: controller,
      minScale: 0.3,
      maxScale: 100,
      children: viewModel.models.entries.map((e) {
        final widget = ModelWidget(
          model: e.value,
          onTap: onTap,
          onChanged: (p, v) => onChanged(['models', e.key, ...p], v),
        );
        return Panel(
          widget: widget,
          position: e.value.common.position,
          onMoved: (position) {
            e.value.common.position = position;
            onChanged(['models', e.key, 'common', 'position'], e.value.common.map['position']);
          },
        );
      }).toList(),
    );
  }
}
