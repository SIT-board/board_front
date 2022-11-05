library json_diff_patcher;

import 'dart:convert';

import 'package:json_field_modifier/json_field_modifier.dart';

class JsonPatchUpdate {
  dynamic source;
  dynamic target;
  JsonPatchUpdate(this.source, this.target);

  /// 求逆
  JsonPatchUpdate inverse() => JsonPatchUpdate(target, source);

  Map<String, dynamic> toJson() => {'source': source, 'target': target};

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class JsonPatch {
  Map<String, dynamic> add;
  Map<String, dynamic> remove;
  Map<String, JsonPatchUpdate> update;
  JsonPatch({
    this.add = const {},
    this.remove = const {},
    this.update = const {},
  });

  // 求逆
  JsonPatch inverse() {
    return JsonPatch(
      add: remove,
      remove: add,
      update: update.map((key, value) => MapEntry(key, value.inverse())),
    );
  }

  bool isEmpty() {
    return add.isEmpty && remove.isEmpty && update.isEmpty;
  }

  Map<String, dynamic> toJson() => {'add': add, 'remove': remove, 'update': update};
  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

/// json差分补丁器
class JsonDiffPatcher {
  Map<dynamic, dynamic> source;
  JsonDiffPatcher(this.source);

  /// 实际上source + patch = target
  JsonPatch diff(dynamic target) {
    final sfm = FieldModifier(source);
    final tfm = FieldModifier(target);
    final sourcePath = sfm.getPathList(containListIndex: false).map((e) => e.join('.')).toSet();
    final targetPath = tfm.getPathList(containListIndex: false).map((e) => e.join('.')).toSet();
    // 新增元素
    final addPath = targetPath.toSet();
    addPath.removeAll(sourcePath);
    // 删除元素
    final removePath = sourcePath.toSet();
    removePath.removeAll(targetPath);
    // 更新元素
    final intersectionPath = sourcePath.intersection(targetPath);
    intersectionPath.where((path) => sfm[path] != tfm[path]);
    return JsonPatch(
      add: Map.fromEntries(addPath.map((e) => MapEntry(e, tfm[e]))),
      remove: Map.fromEntries(removePath.map((e) => MapEntry(e, sfm[e]))),
      update: Map.fromEntries(intersectionPath.map((e) => MapEntry(e, JsonPatchUpdate(sfm[e], tfm[e]))).where((e) {
        final s = jsonEncode(e.value.source), t = jsonEncode(e.value.target);
        return s != t;
      })),
    );
  }

  void applyPatch(JsonPatch patch) {
    final fm = FieldModifier(source);
    for (final updateItem in patch.update.entries) {
      fm[updateItem.key] = updateItem.value.target;
    }
    for (final removeItem in patch.remove.entries) {
      fm.remove(removeItem.key);
    }
    for (final addItem in patch.add.entries) {
      fm[addItem.key] = addItem.value;
    }
  }
}
