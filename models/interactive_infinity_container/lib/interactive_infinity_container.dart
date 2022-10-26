library interactive_infinity_container;

import 'package:flutter/material.dart';

import 'infinity_stack.dart';

class InteractiveInfinityContainer extends StatelessWidget {
  final List<Widget> children;
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
    return InteractiveViewer(
      minScale: minScale,
      maxScale: maxScale,
      transformationController: viewerTransformationController,
      boundaryMargin: const EdgeInsets.all(double.infinity),
      child: InfinityStack(children: children.map((e) => Positioned(top: 0, left: 0, child: e)).toList()),
    );
  }
}
