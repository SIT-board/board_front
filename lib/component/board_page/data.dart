import 'package:board_front/component/board/board.dart';
import 'package:board_front/interface/hash_map_data.dart';

/// 某一页的 model
class BoardPageViewModel extends HashMapData {
  String get title => map['title'];
  set title(String v) => map['title'] = v;
  int get pageId => map['pageId'];
  set pageId(int v) => map['pageId'] = v;
  BoardViewModel get board => BoardViewModel(map['board'] ??= <String, dynamic>{});
  BoardPageViewModel(super.map);

  factory BoardPageViewModel.createNew(int pageId) {
    return BoardPageViewModel({})
      ..title = '新页面$pageId'
      ..pageId = pageId;
  }
}

/// 所有页面
class BoardPageSetViewModel extends HashMapData {
  bool get memberReadOnly => map['memberReadOnly'] ??= true;
  set memberReadOnly(bool v) => map['memberReadOnly'] = v;

  List<int> get pageIdList => ((map['pageIdList'] ??= <int>[]) as List).cast<int>();

  BoardPageViewModel getPageById(int pageId) {
    final m = map['pageMap'] ??= <String, dynamic>{};
    return BoardPageViewModel(m[pageId.toString()]);
  }

  void addBoardPage(BoardPageViewModel model) {
    map['pageIdList'] = [...pageIdList, model.pageId];
    (map['pageMap'] ??= <String, dynamic>{})[model.pageId.toString()] = model.map;
  }

  BoardPageViewModel get currentPage => getPageById(currentPageId);

  void deletePage(int pageId) {
    assert(pageId != currentPageId);
    pageIdList.remove(pageId);
  }

  int get currentPageId => map['currentPageId'];
  set currentPageId(int v) {
    map['currentPageId'] = v;
    print('切换页面: $v');
  }

  int? get nextPageId {
    int idx = pageIdList.firstWhere((e) => e == currentPageId);
    final ids = pageIdList;
    if (!(0 <= (idx + 1) && (idx + 1) < ids.length)) return null;
    return pageIdList[idx + 1];
  }

  int? get prePageId {
    int idx = pageIdList.firstWhere((e) => e == currentPageId);
    final ids = pageIdList;
    if (!(0 <= (idx - 1) && (idx - 1) < ids.length)) return null;
    return pageIdList[idx - 1];
  }

  BoardPageSetViewModel(super.map);

  factory BoardPageSetViewModel.createNew() {
    return BoardPageSetViewModel({})
      ..addBoardPage(BoardPageViewModel.createNew(0))
      ..currentPageId = 0;
  }
}
