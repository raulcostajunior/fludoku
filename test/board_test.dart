import 'package:fludoku/fludoku.dart';
import 'package:test/test.dart';

void main() {
  final invalidBoardValueRange = Board.withValues([
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

  final invalidBoardColumnLine = Board.withValues([
    [5, 1, 6, 8, 4, 9, 7, 3, 2], // 2 is repeated in the fourth column.
    [3, 2, 7, 6, 1, 5, 4, 8, 9], // 3 is repeated in the fourth column.
    [8, 4, 9, 7, 2, 3, 1, 6, 5], // 9 is repeated in the fifth column.
    [1, 3, 5, 2, 6, 8, 9, 4, 7], // 4 is repeated in the sixth column.
    [4, 7, 2, 5, 9, 1, 3, 8, 6], // 1 is repeated in the seventh column.
    [9, 6, 8, 3, 7, 4, 1, 5, 2], // 9 is repeated in the seventh column.
    [2, 5, 3, 1, 8, 6, 9, 7, 4], // 8 is repeated in the eighth column.
    [6, 8, 4, 2, 9, 7, 5, 1, 3], // 2 is repeated in the ninth column.
    [7, 9, 1, 3, 5, 4, 6, 2, 8],
  ]);

  final invalidBoardSection = Board.withValues([
    [2, 9, 5, 7, 4, 3, 8, 6, 1], // 2 repeated in first section and 2nd. column.
    [4, 2, 1, 8, 6, 5, 9, 3, 7], // 3 repeated in third section and 8th. column.
    [8, 7, 6, 1, 9, 2, 5, 4, 3],
    [3, 8, 7, 4, 5, 9, 2, 1, 6],
    [6, 1, 2, 3, 8, 7, 4, 9, 5],
    [5, 4, 9, 2, 1, 6, 7, 3, 8],
    [7, 6, 3, 5, 2, 4, 1, 8, 9],
    [9, 2, 8, 6, 7, 1, 3, 5, 4],
    [1, 5, 4, 9, 3, 8, 6, 7, 2],
  ]);

  final boardWithBlanks = Board.withValues([
    [2, 9, 5, 7, 0, 3, 8, 6, 1], // a blank in the fifth column of first row
    [4, 3, 1, 8, 6, 5, 9, 2, 7],
    [8, 7, 6, 1, 9, 2, 5, 4, 3],
    [3, 8, 7, 4, 5, 9, 2, 1, 6],
    [6, 1, 2, 3, 8, 7, 4, 9, 5],
    [5, 4, 9, 2, 1, 6, 7, 3, 8],
    [7, 6, 3, 5, 2, 4, 1, 8, 9],
    [9, 2, 8, 6, 7, 1, 3, 5, 4],
    [1, 0, 4, 9, 3, 8, 6, 7, 2], // a blank in the second column of last row
  ]);

  final solvedBoard = Board.withValues([
    [2, 9, 5, 7, 4, 3, 8, 6, 1],
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
    test("Board is initially empty", () {
      var board = Board();
      expect(board.isEmpty, true);
      expect(board.blankPositions.length, 81);
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
      var boardWithBlank = Board.clone(boardWithBlanks);
      expect(boardWithBlank.blankPositions.length, 2);
      expect(boardWithBlank.isValid, true);
      expect(boardWithBlank.isComplete, false);
    });

    test("Board with value out of range is invalid", () {
      expect(invalidBoardValueRange.isValid, false);
      // There's only one of out-of-range value in the board at position (0,1)
      var invalids = invalidBoardValueRange.invalidPositions;
      expect(invalids.length, 1);
      expect(invalids[0], (row: 0, col: 1));
    });

    test("Board with repeated value in line or column is invalid", () {
      expect(invalidBoardColumnLine.isValid, false);
      final invalidPositions = invalidBoardColumnLine.invalidPositions;
      expect(invalidPositions.length, 16);
      var invalidsPerCol = List.generate(
          invalidBoardColumnLine.dimension, (col) => 0,
          growable: false);
      for (final invalidPos in invalidPositions) {
        invalidsPerCol[invalidPos.col]++;
      }
      expect(invalidsPerCol[3], 4);
      expect(invalidsPerCol[4], 2);
      expect(invalidsPerCol[5], 2);
      expect(invalidsPerCol[6], 4);
      expect(invalidsPerCol[7], 2);
      expect(invalidsPerCol[8], 2);
    });

    test("Board with value repeated in section is invalid", () {
      expect(invalidBoardSection.isValid, false);
      final invalidPositions = invalidBoardSection.invalidPositions;
      // For the invalidBoardSection fixture the invalid values should be either
      // 2 or 3.
      for (final invalidPos in invalidPositions) {
        int repVal =
            invalidBoardSection.getAt(row: invalidPos.row, col: invalidPos.col);
        expect(repVal == 2 || repVal == 3, true);
      }
    });

    test("Completed board is valid", () {
      expect(solvedBoard.isComplete, true);
      expect(solvedBoard.isValid, true);
      expect(solvedBoard.invalidPositions.length, 0);
    });

    test("Incomplete board can be valid", () {
      expect(boardWithBlanks.isValid, true);
      expect(boardWithBlanks.invalidPositions.length, 0);
    });

    test("Board assigned from another is equal to the original", () {
      Board anotherSolved = solvedBoard;
      // An assigned board references the same board referenced by the rhs.
      expect(identical(anotherSolved, solvedBoard), true);
      expect(anotherSolved == solvedBoard, true);
    });

    test("Board copy generates equal boards", () {
      var anotherSolved = Board.clone(solvedBoard);
      // A cloned board and the clone reference different objects.
      expect(identical(anotherSolved, solvedBoard), false);
      expect(anotherSolved == solvedBoard, true);
    });

    test("Set value with out-of-range value is rejected", () {
      var board = Board.clone(boardWithBlanks);
      expect(() => board.setAt(row: 0, col: 0, value: 12),
          throwsA(isA<RangeError>()));
      expect(board == boardWithBlanks, true);
      // Attempt again, without throwing an exception.
      expect(board.trySetAt(row: 0, col: 0, value: 12), false);
    });

    test("Set value that makes board invalid is rejected", () {
      var board = Board.clone(boardWithBlanks);
      // 6 is already on the line.
      expect(() => board.setAt(row: 0, col: 4, value: 6),
          throwsA(isA<ArgumentError>()));
      // Attempt again, without throwing an exception.
      expect(board.trySetAt(row: 0, col: 4, value: 6), false);
    });

    test("Set value of a read-only position of the board is rejected", () {
      var board = Board.clone(boardWithBlanks);
      // Position (0,0) of the board is defined to a non-zero value, and thus
      // is read-only
      expect(() => board.setAt(row: 0, col: 0, value: 6),
          throwsA(isA<ArgumentError>()));
      // Attempt again, without throwing an exception.
      expect(board.trySetAt(row: 0, col: 0, value: 6), false);
    });

    test("Board created from values of another has its own readOnlyPositions",
        () {
      // boardWithBlanks has only 2 positions with zero values (writable positions)
      var board = Board.clone(boardWithBlanks);
      // Position (0,4) of the board is defined as a zero value and thus writable.
      board.setAt(row: 0, col: 4, value: 4);
      // setAt doesn't affect readOnlyPositions
      expect(board.readOnlyPositions.length, 79);
      var boardFromValues = Board.withValues(board.values);
      // The number of read-only positions of the board created from the values
      // of the first is not the same.
      expect(boardFromValues.readOnlyPositions.length, 80);
      // Differently, a clone retains the read-only positions of the original
      var boardClone = Board.clone(board);
      expect(boardClone.readOnlyPositions.length, 79);
    });

    test("Properly set value is accepted", () {
      var board = Board.clone(boardWithBlanks);
      // 6 is already on the line.
      board.setAt(row: 0, col: 4, value: 4);
      // trySetAt must also be able to do it
      expect(board.trySetAt(row: 0, col: 4, value: 4), true);
      expect(board.getAt(row: 0, col: 4), 4);
    });

    test("Possible values for empty position don't invalidate board", () {
      var board = Board.clone(boardWithBlanks);
      expect(board.isValid, true);
      final possibleValues = board.possibleValuesAt(row: 0, col: 4);
      expect(possibleValues.length, 1);
      board.setAt(row: 0, col: 4, value: possibleValues.first);
      expect(board.isValid, true);
    });

    test("No possible value for non-empty board position", () {
      final possibleValues = solvedBoard.possibleValuesAt(row: 0, col: 0);
      expect(possibleValues.length, 0);
    });

    test(
        "Possible values exclude values already in the same line, column or section",
        () {
      final board = Board();
      board.setAt(row: 0, col: 0, value: 1);
      board.setAt(row: 1, col: 1, value: 6);
      board.setAt(row: 8, col: 1, value: 4);
      final possibleValues = board.possibleValuesAt(row: 0, col: 1);
      expect(possibleValues.length, 6);
      expect(possibleValues.contains(1), false);
      expect(possibleValues.contains(6), false);
      expect(possibleValues.contains(4), false);
    });
  });
}
