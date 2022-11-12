import 'package:flutter/material.dart';
import 'package:quds_popup_menu/quds_popup_menu.dart';

Future<String?> showModifyTitleDialog(BuildContext context, {String title = ''}) {
  TextEditingController controller = TextEditingController()..text = title;
  return showDialog<String>(
    context: context,
    builder: (context) {
      return Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('修改标题', style: Theme.of(context).textTheme.headline5),
            TextField(controller: controller),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('确定'),
            ),
          ],
        ),
      );
    },
  );
}

class BoardTitle extends StatelessWidget {
  final int currentPageId;
  final List<int> pageIdList;
  final Map<int, String> pageNameMap;

  final ValueSetter<String> onChangeTitle;
  final ValueSetter<int> onSwitchPage;
  final VoidCallback onAddPage;
  final ValueSetter<int> onDeletePage;
  final VoidCallback? onTap;
  const BoardTitle({
    Key? key,
    required this.currentPageId,
    required this.pageIdList,
    required this.pageNameMap,
    required this.onChangeTitle,
    required this.onSwitchPage,
    required this.onAddPage,
    required this.onDeletePage,
    this.onTap,
  }) : super(key: key);
  String get currentTitle => pageNameMap[currentPageId]!;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onTapUp: (d) {
        final position = d.globalPosition;
        showQudsPopupMenu(
          context: context,
          startOffset: position,
          endOffset: position,
          items: <QudsPopupMenuBase>[
            QudsPopupMenuItem(
              title: const Text('修改标题'),
              onPressed: () async {
                final modifiedTitle = await showModifyTitleDialog(context, title: currentTitle);
                if (modifiedTitle == null) return;
                onChangeTitle(modifiedTitle);
              },
            ),
            QudsPopupMenuDivider(),
            QudsPopupMenuItem(title: const Text('添加新页'), onPressed: onAddPage),
            QudsPopupMenuDivider(),
            ...pageIdList.map((pageId) {
              final title = pageNameMap[pageId]!;
              return QudsPopupMenuItem(
                title: Text(title),
                onPressed: () => onSwitchPage(pageId),
                trailing: pageId == currentPageId
                    ? null
                    : IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onDeletePage(pageId);
                        },
                        icon: Icon(Icons.delete),
                      ),
              );
            })
          ],
        );
      },
      child: Text(currentTitle),
    );
  }
}
