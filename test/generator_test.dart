import 'package:fludoku/fludoku.dart';
import 'package:test/test.dart';

void main() {
  group("Generator Tests - ", () {
    for (var level in PuzzleDifficulty.values) {
      test(
          "A generated ${level.name} puzzle has 1 solution and respects max blanks",
          () {
        final (puzzle, timeoutMsg) = generateSudokuBoard(level: level);
        if (puzzle != null) {
          expect(puzzle.isSolvable, true);
          expect(puzzle.isValid, true);
          expect(puzzle.blankPositions.length <= level.maxEmpty(), true);
          final solutions = findSolutions(puzzle, maxSolutions: 20);
          expect(solutions.length, 1);
          expect(solutions[0].isComplete, true);
          print(
              "Generated ${level.name} board has ${puzzle.blankPositions.length} blanks (max. allowed is ${level.maxEmpty()})");
          print(puzzle);
        }
      });
    }

    test("Puzzle generation with a too low timeout times out", () {
      final (puzzle, timeoutMsg) = generateSudokuBoard(
          level: PuzzleDifficulty.hard, dimension: 25, timeoutSecs: 1);
      expect(puzzle, null);
      expect(timeoutMsg?.isNotEmpty, true);
    });
  });
}
