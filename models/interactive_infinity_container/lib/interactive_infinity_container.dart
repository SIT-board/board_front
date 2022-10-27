library interactive_infinity_container;

import 'package:flutter/material.dart';

import 'infinity_stack.dart';

class Panel {
  Offset position;
  final Widget widget;
  final ValueSetter<Offset>? onMoved;
  Panel({
    this.position = const Offset(0, 0),
    required this.widget,
    this.onMoved,
  });
}

class PanelWidget extends StatefulWidget {
  final Panel panel;
  const PanelWidget({
    Key? key,
    required this.panel,
  }) : super(key: key);

  @override
  State<PanelWidget> createState() => _PanelWidgetState();
}

class _PanelWidgetState extends State<PanelWidget> {
  @override
  Widget build(BuildContext context) {
    final e = widget.panel;
    Widget result = e.widget;
    result = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: (d) {
        setState(() => e.position = e.position + d.delta);
        if (widget.panel.onMoved != null) widget.panel.onMoved!(e.position);
      },
      child: result,
    );
    result = Positioned(
      left: e.position.dx,
      top: e.position.dy,
      child: result,
    );
    return result;
  }
}

class InteractiveInfinityContainer extends StatelessWidget {
  final List<Panel> children;
  final TransformationController? viewerTransformationController;
  final double maxScale;
  final double minScale;
  const InteractiveInfinityContainer({
    Key? key,
    this.maxScale = 2.5,
    this.minScale = 0.8,
    required this.children,
    this.viewerTransformationController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: InteractiveViewer(
        minScale: minScale,
        maxScale: maxScale,
        transformationController: viewerTransformationController,
        boundaryMargin: const EdgeInsets.all(double.infinity),
        child: InfinityStack(
          children: children.map((e) => PanelWidget(panel: e)).toList(),
        ),
      ),
    );
  }
}
