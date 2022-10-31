class FieldModifier {
  final dynamic data;
  FieldModifier(this.data);
  dynamic _get(dynamic data, List<dynamic> path, int deep) {
    if (deep >= path.length) return data;
    return _get(data[path[deep]], path, deep + 1);
  }

  dynamic get(List<dynamic> path) => _get(data, path, 0);
  dynamic operator [](List<dynamic> path) => get(path);

  void _set(dynamic data, List<dynamic> path, int deep, dynamic value) {
    final parent = _get(data, path.sublist(0, path.length - 1), 0);
    parent[path.last] = value;
  }

  void set(List<dynamic> path, dynamic value) => _set(data, path, 0, value);
  void operator []=(List<dynamic> path, dynamic value) => set(path, value);
}
