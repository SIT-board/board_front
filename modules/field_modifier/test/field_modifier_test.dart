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
    m[['a1', 'c2', '1']] = 666;
    expect(m.data['a1']['c2'][1], equals(666));
  });
  test('test map get by path', () {
    final m = testMap();
    expect(m.data['a1']['b2'], equals(true));
    expect(m['a1.b2'], equals(true));
    expect(m['a1.c2.2'], equals(3));
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
  test('test contains by path', () {
    final m = testMap();
    expect(m.contains(['a1', 'b2']), true);
    expect(m.contains(['a1', 'c2', 4]), false);
    expect(m.contains(['a1', 'c2', 1]), true);
    expect(m.contains(['a1', 'c2', '1']), true);
  });
  test('test get pathList', () {
    final m = testMap();
    final testCases = [
      ['a1', 'a2'],
      ['a1', 'b2'],
      ['a1', 'c2', 0],
      ['a1', 'c2', 1],
      ['a1', 'c2', 2],
      ['a1', 'c2', 'b1']
    ].map((e) => e.join('/')).toSet();
    final paths = m.pathList.map((e) => e.join('/')).toSet();
    expect(paths.containsAll(testCases), true);
  });
}
