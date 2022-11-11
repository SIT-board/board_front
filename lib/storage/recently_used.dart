import 'json_storage.dart';

class RecentlyUsedListStorageKeys {
  static const _namespace = '/recently_used';
  static const items = '$_namespace/items';
}

class RecentlyUsedItem {
  final String name;
  final DateTime ts;

  RecentlyUsedItem({
    required this.name,
    required this.ts,
  });

  Map<String, dynamic> toJson() => {'name': name, 'ts': ts.millisecondsSinceEpoch};
  factory RecentlyUsedItem.fromJson(Map<String, dynamic> json) {
    return RecentlyUsedItem(
      name: json['name'],
      ts: DateTime.fromMillisecondsSinceEpoch(json['ts']),
    );
  }
}

class RecentlyUsedListStorage extends JsonStorage {
  RecentlyUsedListStorage(super.prefs);

  /// 添加一个记录
  RecentlyUsedItem addItem(String name) {
    final oldItems = items;
    oldItems.removeWhere((e) => e.name == name);
    oldItems.sort((a, b) => a.ts.difference(b.ts).inMilliseconds);
    final item = RecentlyUsedItem(name: name, ts: DateTime.now());
    _items = [item, ...oldItems];
    return item;
  }

  /// 清空历史记录
  void clear() => _items = [];

  /// 获取历史记录
  List<RecentlyUsedItem> get items {
    return getModelList<RecentlyUsedItem>(
          RecentlyUsedListStorageKeys.items,
          (p0) => RecentlyUsedItem.fromJson(p0),
        ) ??
        [];
  }

  set _items(List<RecentlyUsedItem> v) {
    return setModelList<RecentlyUsedItem>(RecentlyUsedListStorageKeys.items, v, (p0) => p0.toJson());
  }
}
