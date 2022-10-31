import 'package:field_modifier/field_modifier.dart';
import 'package:test/test.dart';

FieldModifier testMap() => FieldModifier({
      'a1': {
        'a2': 123,
        'b2': true,
        'c2': [1, 2, 3],
      },
      'b1': 123,
    });
FieldModifier testList() => FieldModifier([
      3,
      4,
      [2, 3, 4]
    ]);
void main() {
  test('test map set by path', () {
    final m = testMap();
    m[['a1', 'c2', 2]] = 98;
    expect(m.data['a1']['c2'][2], equals(98));
  });
  test('test map get by path', () {
    final m = testMap();
    expect(m.data['a1']['b2'], equals(true));
  });
  test('test list get by path', () {
    final m = testList();
    expect(m.data[2], equals([2, 3, 4]));
  });
  test('test list set by path', () {
    final m = testList();
    m[[2, 1]] = 999;
    expect(m.data[2][1], equals(999));
  });
}
