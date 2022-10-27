class MyMap<K, V> implements Map<K, V> {
  final Map<K, V> m;
  final void Function(K key, V value)? onChanged;
  MyMap(this.m, {this.onChanged});
  @override
  V? operator [](Object? key) => m[key];

  @override
  void operator []=(K key, V value) {
    if (onChanged != null) onChanged!(key, value);
    m[key] = value;
  }

  @override
  void addAll(Map<K, V> other) => m.addAll(other);

  @override
  void addEntries(Iterable<MapEntry<K, V>> newEntries) => m.addEntries(newEntries);

  @override
  Map<RK, RV> cast<RK, RV>() => m.cast();

  @override
  void clear() => m.clear();

  @override
  bool containsKey(Object? key) => m.containsKey(key);

  @override
  bool containsValue(Object? value) => m.containsValue(value);

  @override
  Iterable<MapEntry<K, V>> get entries => m.entries;

  @override
  void forEach(void Function(K key, V value) action) => m.forEach(action);

  @override
  bool get isEmpty => m.isEmpty;

  @override
  bool get isNotEmpty => m.isNotEmpty;

  @override
  Iterable<K> get keys => m.keys;

  @override
  int get length => m.length;

  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(K key, V value) convert) => m.map(convert);

  @override
  V putIfAbsent(K key, V Function() ifAbsent) => m.putIfAbsent(key, ifAbsent);

  @override
  V? remove(Object? key) => m.remove(key);

  @override
  void removeWhere(bool Function(K key, V value) test) => m.removeWhere(test);

  @override
  V update(K key, V Function(V value) update, {V Function()? ifAbsent}) => m.update(key, update, ifAbsent: ifAbsent);

  @override
  void updateAll(V Function(K key, V value) update) => m.updateAll(update);

  @override
  Iterable<V> get values => m.values;
}