import 'json_storage.dart';

class ImageListStorageKeys {
  static const _namespace = '/image';
  static const items = '$_namespace/items';
}

class ImageItem {
  final String name;
  final String rawUrl;
  final String thumbnailUrl;
  final DateTime ts;

  ImageItem({
    required this.name,
    required this.rawUrl,
    required this.thumbnailUrl,
    required this.ts,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'rawUrl': rawUrl,
        'thumbnailUrl': thumbnailUrl,
        'ts': ts.millisecondsSinceEpoch,
      };
  factory ImageItem.fromJson(Map<String, dynamic> json) {
    return ImageItem(
      name: json['name'],
      rawUrl: json['rawUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      ts: DateTime.fromMillisecondsSinceEpoch(json['ts']),
    );
  }
}

class ImageListStorage extends JsonStorage {
  ImageListStorage(super.prefs);

  /// 添加一个记录
  ImageItem addItem({
    required String name,
    required String rawUrl,
    required String thumbnailUrl,
  }) {
    final oldItems = items;
    oldItems.removeWhere((e) => e.name == name);
    oldItems.sort((a, b) => a.ts.difference(b.ts).inMilliseconds);
    final item = ImageItem(
      name: name,
      rawUrl: rawUrl,
      thumbnailUrl: thumbnailUrl,
      ts: DateTime.now(),
    );
    _items = [item, ...oldItems];
    return item;
  }

  /// 清空历史记录
  void clear() => _items = [];

  /// 获取历史记录
  List<ImageItem> get items {
    return getModelList<ImageItem>(
          ImageListStorageKeys.items,
          (p0) => ImageItem.fromJson(p0),
        ) ??
        [];
  }

  set _items(List<ImageItem> v) {
    return setModelList<ImageItem>(ImageListStorageKeys.items, v, (p0) => p0.toJson());
  }
}
