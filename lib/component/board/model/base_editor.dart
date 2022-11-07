import 'package:flutter/material.dart';

class ModelAttributeItem extends StatelessWidget {
  final String title;
  final Widget child;

  const ModelAttributeItem({
    Key? key,
    required this.title,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Text(title),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: child,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ModelAttributeSection extends StatelessWidget {
  final String title;
  final List<ModelAttributeItem> items;

  const ModelAttributeSection({
    Key? key,
    required this.title,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headline5),
          ...items,
          Divider(),
        ],
      ),
    );
  }
}

class ModelAttribute extends StatelessWidget {
  final List<ModelAttributeSection> children;
  const ModelAttribute({
    Key? key,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: children);
  }
}
