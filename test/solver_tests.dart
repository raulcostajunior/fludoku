import 'package:fludoku/solver.dart';
import 'package:fludoku/board.dart';
import 'package:test/test.dart';

void main() {
  final unsolvableBoard = Board.from([
    [5, 1, 6, 8, 4, 0, 7, 3, 2],
    [3, 0, 7, 6, 0, 5, 0, 0, 0],
    [8, 0, 9, 7, 0, 0, 0, 6, 5],
    [1, 3, 5, 0, 6, 0, 9, 0, 7],
    [4, 7, 2, 5, 9, 1, 0, 0, 6],
    [9, 6, 8, 3, 7, 0, 0, 5, 0],
    [2, 5, 3, 1, 8, 6, 0, 7, 4],
    [6, 8, 4, 2, 0, 7, 5, 0, 0],
    [7, 9, 1, 0, 5, 0, 6, 0, 8],
  ]);

  final invalidBoard = Board.from([
    // 2 is repeated across the first line and the last column.
    [2, 9, 5, 7, 4, 3, 8, 6, 2],
    [4, 3, 1, 8, 6, 5, 9, 2, 7],
    [8, 7, 6, 1, 9, 2, 5, 4, 3],
    [3, 8, 7, 4, 5, 9, 2, 1, 6],
    [6, 1, 2, 3, 8, 7, 4, 9, 5],
    [5, 4, 9, 2, 1, 6, 7, 3, 8],
    [7, 6, 3, 5, 2, 4, 1, 8, 9],
    [9, 2, 8, 6, 7, 1, 3, 5, 4],
    [1, 5, 4, 9, 3, 8, 6, 7, 2],
  ]);

  final solvableHardOneSolution = Board.from([
    [0, 0, 6, 0, 0, 8, 5, 0, 0],
    [0, 0, 0, 0, 7, 0, 6, 1, 3],
    [0, 0, 0, 0, 0, 0, 0, 0, 9],
    [0, 0, 0, 0, 9, 0, 0, 0, 1],
    [0, 0, 1, 0, 0, 0, 8, 0, 0],
    [4, 0, 0, 5, 3, 0, 0, 0, 0],
    [1, 0, 7, 0, 5, 3, 0, 0, 0],
    [0, 5, 0, 0, 6, 4, 0, 0, 0],
    [3, 0, 0, 1, 0, 0, 0, 6, 0],
  ]);

  final solvableOneSolution = Board.from([
    [2, 9, 5, 7, 4, 3, 8, 6, 1],
    [4, 3, 1, 8, 6, 5, 9, 2, 7],
    [8, 7, 6, 1, 9, 2, 5, 4, 3],
    [3, 8, 7, 4, 5, 9, 2, 1, 6],
    [6, 1, 2, 3, 8, 7, 4, 9, 5],
    [5, 4, 9, 2, 1, 6, 7, 3, 8],
    [7, 6, 3, 5, 2, 4, 1, 8, 9],
    [9, 2, 8, 6, 7, 1, 3, 5, 0],
    [1, 5, 4, 9, 3, 8, 6, 7, 2],
  ]);

  final solvableThreeSolutions = Board.from([
    [0, 7, 5, 8, 4, 6, 1, 0, 0],
    [8, 4, 0, 0, 0, 0, 9, 7, 0],
    [0, 0, 0, 0, 0, 0, 0, 4, 0],
    [7, 0, 0, 5, 0, 0, 2, 9, 1],
    [0, 0, 0, 0, 0, 4, 7, 0, 8],
    [2, 0, 0, 0, 9, 0, 0, 5, 0],
    [4, 8, 9, 0, 0, 0, 5, 0, 2],
    [6, 0, 0, 0, 8, 0, 3, 0, 9],
    [0, 1, 2, 6, 5, 9, 0, 0, 0],
  ]);

  final solvableTooManySolutions = Board.from([
    // Almost all positions blank
    [0, 0, 0, 0, 0, 4, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 6, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
  ]);

  group("Solver Tests - ", () {
    test("Empty board is not solvable", () {
      var emptyBoard = Board();
      expect(() => Solver.findSolutions(emptyBoard), throwsA(predicate((exc) {
        return exc is ArgumentError &&
            (exc.message as String).contains("The board is empty");
      })));
    });

    test("Invalid board is not solvable", () {
      expect(() => Solver.findSolutions(invalidBoard), throwsA(predicate((exc) {
        return exc is ArgumentError &&
            (exc.message as String).contains("The board is invalid");
      })));
    });

    test("Cannot solve unsolvableBoard", () {
      expect(() => Solver.findSolutions(unsolvableBoard),
          throwsA(predicate((exc) {
        return exc is ArgumentError &&
            (exc.message as String).contains("Board is not solvable");
      })));
    });

    test("Can solve solvableBoard", () {
      final solutions = Solver.findSolutions(solvableOneSolution);
      expect(solutions.length, 1);
      expect(solutions[0].isComplete, true);
    });

    test("Finds all solutions for a board with few solutions", () {
      final solutions =
          Solver.findSolutions(solvableThreeSolutions, maxSolutions: 20);
      expect(solutions.length, 3);
      for (final solution in solutions) {
        expect(solution.isComplete, true);
      }
    });

    test("Finds the solution for a Sudoku board considered hard", () {
      // Also checks the activations of the progress callback and verifies
      // that it is monotonically ascending.
      var higherProgress = -1;
      final solutions = Solver.findSolutions(solvableHardOneSolution,
          maxSolutions: 20, progressCallback: (progress) {
        expect(progress > higherProgress, true);
        higherProgress = progress;
      });
      expect(higherProgress, 100);
      expect(solutions.length, 1);
      expect(solutions[0].isComplete, true);
    });

    test("The limit for maximum number of solutions is being enforced", () {
      // Also checks the activations of the progress callback and verifies
      // that it is monotonically ascending.
      var higherProgress = -1;
      // Finds the solutions for a board with many solutions limited to a
      // number of solutions known to be satisfiable.
      var solutions = Solver.findSolutions(solvableTooManySolutions,
          maxSolutions: 20, progressCallback: (progress) {
        expect(progress > higherProgress, true);
        higherProgress = progress;
      });
      expect(higherProgress, 100);
      expect(solutions.length, 20);
      for (var solution in solutions) {
        expect(solution.isComplete, true);
      }
      // Finds the solutions for the same board used before, but this time
      // use a smaller value for the maximum number of solutions.
      higherProgress = -1;
      solutions = Solver.findSolutions(solvableTooManySolutions,
          maxSolutions: 10, progressCallback: (progress) {
        expect(progress > higherProgress, true);
        higherProgress = progress;
      });
      expect(higherProgress, 100);
      expect(solutions.length, 10);
      for (var solution in solutions) {
        expect(solution.isComplete, true);
      }
    });
  }); // group
} // main
