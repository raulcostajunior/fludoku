import 'package:fludoku/fludoku.dart';
import 'package:test/test.dart';

void main() {
  group('Board Tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('Board initially empty', () {
      var board = Board();
      expect(board.isEmpty, true);
    });
  });
}
