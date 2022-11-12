library json_field_modifier;

class FieldModifier {
  final dynamic data;
  FieldModifier(this.data);
  static dynamic _get(
    dynamic data,
    List<dynamic> path,
    int deep, [
    bool autoCreateParent = false, // 是否自动创建父结点
  ]) {
    if (deep >= path.length) return data;
    final key = path[deep];
    var value = (data is List && key is! int) ? data[int.parse(key.toString())] : data[key];
    if (autoCreateParent && value == null && deep < path.length) {
      value = <String, dynamic>{};
      data[key] = value;
    }
    return _get(value, path, deep + 1, autoCreateParent);
  }

  dynamic get(List<dynamic> path) => _get(data, path, 0);
  dynamic operator [](dynamic path) {
    if (path is List) {
      return get(path);
    } else {
      return get(path.toString().split('.'));
    }
  }

  static void _set(dynamic data, List<dynamic> path, dynamic value) {
    final parent = _get(data, path.sublist(0, path.length - 1), 0, true);
    final key = path.last;
    if (parent is List && key is! int) {
      parent[int.parse(key.toString())] = value;
    } else {
      parent[key] = value;
    }
  }

  void set(List<dynamic> path, dynamic value) => _set(data, path, value);
  void operator []=(dynamic path, dynamic value) {
    if (path is List) {
      set(path, value);
    } else {
      set(path.toString().split('.'), value);
    }
  }

  void _remove(List<dynamic> path) {
    final parent = _get(data, path.sublist(0, path.length - 1), 0);
    final lastPath = path.last;
    if (parent is Map) {
      parent.remove(lastPath);
      return;
    }
    if (parent is List) {
      final idx = lastPath is int ? lastPath : int.parse(lastPath.toString());
      parent.removeAt(idx);
      return;
    }
  }

  void remove(dynamic path) {
    if (path is List) {
      _remove(path);
      return;
    }
    _remove(path.toString().split('.'));
  }

  bool contains(List<dynamic> path) {
    final parent = _get(data, path.sublist(0, path.length - 1), 0);
    final lastPath = path.last;
    if (parent is Map) return parent.containsKey(lastPath);
    if (parent is List) {
      final idx = lastPath is int ? lastPath : int.parse(lastPath.toString());
      return 0 <= idx && idx < parent.length;
    }
    return false;
  }

  List<List<dynamic>> getPathList({
    // 是否包含列表元素的序号，即是否继续深搜List对象
    bool containListIndex = false,
  }) {
    List<List<dynamic>> result = [];

    List<dynamic> stack = [];
    void visit(dynamic m) {
      if (m is Map) {
        for (final e in m.keys) {
          stack.add(e);
          visit(m[e]);
          stack.removeLast();
        }
      }
      if (containListIndex && m is List) {
        for (final e in m.asMap().entries) {
          stack.add(e.key);
          visit(e.value);
          stack.removeLast();
        }
      }

      // 到达叶子节点
      // 若containListIndex && m is! Map && m is! List是叶子
      // 若!containListIndex && m is! Map是叶子
      // 即(containListIndex && m is! Map && m is! List) || !containListIndex && m is! Map 是叶子
      // 设为(p&&q&&r)||(!p&&q)
      final p = containListIndex, q = m is! Map, r = m is! List;
      if ((p && q && r) || (!p && q)) result.add(stack.toList());
    }

    visit(data);
    return result;
  }
}
