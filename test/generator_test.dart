import 'package:fludoku/generator.dart';
import 'package:fludoku/solver.dart';
import 'package:test/test.dart';

void main() {
  group("Generator Tests - ", () {
    for (var difficulty in PuzzleDifficulty.values) {
      test(
          "A generated ${difficulty.name} puzzle has 1 solution and respects max blanks",
          () {
        final puzzle = generateBoard(difficulty);
        expect(puzzle.isSolvable, true);
        expect(puzzle.isValid, true);
        expect(puzzle.blankPositions.length <= difficulty.maxEmpty, true);
        final solutions = findSolutions(puzzle, maxSolutions: 20);
        expect(solutions.length, 1);
        expect(solutions[0].isComplete, true);
        print(
            "Generated ${difficulty.name} board has ${puzzle.blankPositions.length} blanks (max. allowed is ${difficulty.maxEmpty})");
        print(puzzle);
      });
    }
  });
}
