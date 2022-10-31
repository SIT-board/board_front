class FieldModifier {
  final dynamic data;
  FieldModifier(this.data);
  static dynamic _get(dynamic data, List<dynamic> path, int deep) {
    if (deep >= path.length) return data;
    final key = path[deep];
    final value = (data is List && key is! int) ? data[int.parse(key.toString())] : data[key];
    return _get(value, path, deep + 1);
  }

  dynamic get(List<dynamic> path) => _get(data, path, 0);
  dynamic operator [](List<dynamic> path) => get(path);

  static void _set(dynamic data, List<dynamic> path, dynamic value) {
    final parent = _get(data, path.sublist(0, path.length - 1), 0);
    final key = path.last;
    if (parent is List && key is! int) {
      parent[int.parse(key.toString())] = value;
    } else {
      parent[key] = value;
    }
  }

  void set(List<dynamic> path, dynamic value) => _set(data, path, value);
  void operator []=(List<dynamic> path, dynamic value) => set(path, value);

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

  List<List<dynamic>> get pathList {
    List<List<dynamic>> result = [];
    List<dynamic> stack = [];
    void visit(dynamic m) {
      if (m is Map) {
        for (final e in m.keys) {
          stack.add(e);
          visit(m[e]);
        }
      }
      if (m is List) {
        for (final e in m.asMap().entries) {
          stack.add(e.key);
          visit(e.value);
        }
      }

      if (stack.isNotEmpty && m is! Map && m is! List) {
        result.add(stack.toList());
        stack.removeLast();
      }
    }

    visit(data);
    return result;
  }
}
