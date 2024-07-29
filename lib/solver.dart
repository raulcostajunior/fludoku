import 'board.dart' show Board;

/// Callback type for Solver to report its progress searching for solutions.
typedef FindSolutionsProgress = void Function(
    {int progress, int unsolvablesFound});

class Solver {
  /// Finds solution(s) for a given [puzzle] board.
  ///
  /// If defined, [progressCallback] will be called to report progress.
  /// As [puzzle] is not guaranteed to be a "canonical" Sudoku board, which must
  /// have only one solution, a [maxSolutions] maximum number of solutions to be
  /// found can be specified.
  ///
  /// If [puzzle] is not a solvable board, an [ArgumentError] is thrown. If
  /// [maxSolutions] is less than 1, an [ArgumentError] is thrown.
  static List<Board> findSolutions(
      final Board puzzle, final FindSolutionsProgress? progressCallback,
      [final int maxSolutions = 1]) {
    // Validate the parameters
    if (maxSolutions < 1) {
      throw ArgumentError('maxSolutions must be at least 1');
    }
    _checkSolvable(puzzle);

    var solutions = <Board>[];
    _findSolutions(puzzle, progressCallback, maxSolutions, solutions,
        (level: 0, unsolvablesFound: 0, progress: 0));

    return solutions;
  }

  static void _findSolutions(
      final Board board,
      final FindSolutionsProgress? progressCallback,
      final int maxSolutions,
      List<Board> solutions,
      _FindSolutionsContext context) {}

  static void _checkSolvable(final Board board) {
    if (!board.isValid) {
      throw ArgumentError('The board is invalid');
    }
    if (board.isEmpty) {
      throw ArgumentError('The board is empty');
    }
    if (board.isComplete) {
      throw ArgumentError('The board has already been solved');
    }
  }
}

typedef _FindSolutionsContext = ({
  int level,
  int unsolvablesFound,
  int progress
});
