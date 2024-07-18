import 'package:fludoku/fludoku.dart';
import 'package:test/test.dart';

void main() {
  var invalidBoardValueRange = Board.from([
    [2, 19, 5, 7, 4, 3, 8, 6, 1],
    [4, 3, 1, 8, 6, 5, 9, 2, 7],
    [8, 7, 6, 1, 9, 2, 5, 4, 3],
    [3, 8, 7, 4, 5, 9, 2, 1, 6],
    [6, 1, 2, 3, 8, 7, 4, 9, 5],
    [5, 4, 9, 2, 1, 6, 7, 3, 8],
    [7, 6, 3, 5, 2, 4, 1, 8, 9],
    [9, 2, 8, 6, 7, 1, 3, 5, 4],
    [1, 5, 4, 9, 3, 8, 6, 7, 2],
  ]);

  group("Board Tests - ", () {
    setUp(() {
      // Additional setup goes here.
    });

    test("Board is initially empty", () {
      var board = Board();
      expect(board.isEmpty, true);
      expect(board.blankPositionsCount, 81);
      expect(board.isValid, true);
      expect(board.isComplete, false);
    });

    test("Board is empty after clear", () {
      var invalidBoardCopy = Board.clone(invalidBoardValueRange);
      invalidBoardCopy.clear();
      expect(invalidBoardCopy.isEmpty, true);
    });

    test("Invalid board isn't complete", () {
      expect(invalidBoardValueRange.isComplete, false);
    });

    test("Board with blank position isn't complete", () {
      var boardWithBlank = Board.clone(invalidBoardValueRange);
      // Turn invalidBoardValueRange into a valid Board with a blank position
      boardWithBlank.setAt(row: 0, col: 1, value: 0);
      expect(boardWithBlank.blankPositionsCount, 1);
      expect(boardWithBlank.isValid, true);
      expect(boardWithBlank.isComplete, false);
    });

    test("Board with value out of range is invalid", () {
      expect(invalidBoardValueRange.isValid, false);
      // There's only one of out-of-range value in the board at position (0,1)
      var invalids = invalidBoardValueRange.invalidPositions;
      expect(invalids.length, 1);
      expect(invalids[0], (0, 1));
    });

  });
}
