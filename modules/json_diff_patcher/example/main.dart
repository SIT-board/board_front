import 'dart:convert';

import 'package:json_diff_patcher/json_diff_patcher.dart';

dynamic copy(dynamic json) {
  return jsonDecode(jsonEncode(json));
}

final sourceMap = {
  'a': 123,
  'b': 321,
  'c': [2, 3, 4],
  'd': [3, 4, 5],
  'e': {'e1': 333, 'e2': 22222},
};
final targetMap = copy(sourceMap);

void main() {
  targetMap['a'] = 'a1';
  targetMap['f'] = 'f1';
  targetMap['c'].add(2);
  targetMap['e']['e2'] = 345;
  targetMap['e']['e2'] = 345;
  (targetMap['e'] as Map).remove('e1');
  final patcher = JsonDiffPatcher(sourceMap);
  final patch = patcher.diff(targetMap);
  print('source: $sourceMap');
  print('target: $targetMap');
  print('patch: $patch');

  patcher.applyPatch(patch);
  print('source += patch: $sourceMap');

  patcher.applyPatch(patch.inverse());
  print('source -= patch: $sourceMap');
}
