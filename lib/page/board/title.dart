import 'package:flutter/material.dart';
import 'package:quds_popup_menu/quds_popup_menu.dart';

class BoardTitle extends StatelessWidget {
  const BoardTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (d) {
        print(d);
        final position = d.globalPosition;
        showQudsPopupMenu(
          context: context,
          startOffset: position,
          endOffset: position,
          items: <QudsPopupMenuBase>[
            QudsPopupMenuItem(
              title: Text('修改标题'),
              onPressed: () {},
            ),
            QudsPopupMenuDivider(),
            QudsPopupMenuItem(
              title: Text('添加新页'),
              onPressed: () {},
            ),
            QudsPopupMenuSection(
              titleText: '切换页面',
              subItems: List.generate(100, (i) {
                return QudsPopupMenuItem(
                  title: Text('第$i页'),
                  onPressed: () {},
                );
              }),
            ),
          ],
        );
      },
      child: Text('点击修改页面标题'),
    );
  }
}
