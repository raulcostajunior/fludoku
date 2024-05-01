import 'package:fludoku/fludoku.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    final board = Board();

    setUp(() {
      // Additional setup goes here.
    });

    test('First Test', () {
      expect(board.getAt(row: 0, col: 0), 0);
    });
  });
}
