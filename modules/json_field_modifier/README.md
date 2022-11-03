# Map/List 字段修改器

可使用path来访问与修改Map/List中的字段

```dart
import 'package:field_modifier/json_field_modifier.dart';

void main() {
  final map = {
    'a1': {
      'a2': 123,
      'b2': true,
      'c2': [1, 2, 3],
    },
    'b1': 123,
  };
  final fm = FieldModifier(map);
  print(fm.get(['a1', 'c2'])); // [1,2,3]
  print(fm[['a1', 'c2']]); // [1,2,3]
  print(fm['a1.c2']); // [1,2,3]
  print(fm.get(['a1', 'c2', 2])); // 3
  print(fm[['a1', 'c2', 2]]); // 3
  print(fm['a1.c2.2']); // 3
  fm['a1.c2.1'] = 666;
  print(fm['a1.c2.1']); // 666
}

```