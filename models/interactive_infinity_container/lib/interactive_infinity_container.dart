library interactive_infinity_container;

import 'package:flutter/material.dart';

import 'infinity_stack.dart';

class InteractiveInfinityContainer extends StatelessWidget {
  final List<Widget> children;
  final TransformationController viewerTransformationController;
  const InteractiveInfinityContainer({
    Key? key,
    required this.children,
    required this.viewerTransformationController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: viewerTransformationController,
      boundaryMargin: const EdgeInsets.all(double.infinity),
      child: InfinityStack(children: children),
    );
  }
}
