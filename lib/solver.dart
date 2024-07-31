import 'board.dart' show Board;

/// Callback type for Solver to report its progress searching for solutions.
/// [progress] is expected to be an integer between 0 and 100.
typedef FindSolutionsProgress = void Function(int progress);

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
  static List<Board> findSolutions(final Board puzzle,
      {final FindSolutionsProgress? progressCallback,
      final int maxSolutions = 1}) {
    // Validate the parameters
    if (maxSolutions < 1) {
      throw ArgumentError('maxSolutions must be at least 1');
    }
    _checkSolvable(puzzle);

    // Initialize progress reporting
    if (progressCallback != null) {
      progressCallback(0);
    }

    var solutions = <Board>[];
    _findSolutions(puzzle, progressCallback, maxSolutions, solutions,
        (level: 0, progress: 0));

    return solutions;
  }

  static void _findSolutions(
      final Board board,
      final FindSolutionsProgress? progressCallback,
      final int maxSolutions,
      List<Board> solutions,
      _FindSolutionsContext context) {
    if (solutions.length >= maxSolutions) {
      // The maximum number of solutions has been found. No need to search
      // further.
      return;
    }
    if (board.isComplete) {
      // The board is a solution. No need to search further.
      solutions.add(board);
      return;
    }

    var blanks = board.blankPositions;
    var possibleValues = <Set<int>>[];
    for (var blank in blanks) {
      possibleValues
          .add(board.possibleValuesAt(row: blank.row, col: blank.col));
    }
    // Selects the blank position with the minimum number of possible values to
    // be the next to be filled.
    var boardUnsolvable = false;
    var minSize = Board.maxValue + 1;
    var possValsIdx = -1;
    for (final (blankIdx, possVals) in possibleValues.indexed) {
      if (possVals.isNotEmpty && possVals.length < minSize) {
        possValsIdx = blankIdx;
        minSize = possVals.length;
      } else if (possVals.isEmpty) {
        // A blank position with no possible value has been found; the board is
        // not solvable.
        boardUnsolvable = true;
        break;
      }
    }
    if (!boardUnsolvable) {
      // Continues the search across the boards with the next position to be
      // filled with all the possible values, one for each of the possible values
      for (final (idx, possVal)
          in List.from(possibleValues[possValsIdx]).indexed) {
        var nextBoard = Board.clone(board);
        nextBoard.setAt(
            row: blanks[possValsIdx].row,
            col: blanks[possValsIdx].col,
            value: possVal);
        var newProgress = context.progress;
        if (progressCallback != null && context.level == 0) {
          // Use the minimum number of possible values as a rough progress
          // indicator; must also guarantee that the progress is monotonically
          // ascending. Only level 0 (searching within the original board
          // puzzle) is considered for reporting progress. Otherwise, the
          // progress would keep bouncing due to the required backtracks that
          // happen at deeper levels.
          var currProgress =
              ((idx + 1) / possibleValues[possValsIdx].length * 100).toInt();
          if (currProgress > context.progress) {
            newProgress = currProgress;
            progressCallback(newProgress);
          }
        }
        _findSolutions(nextBoard, progressCallback, maxSolutions, solutions,
            (level: context.level + 1, progress: newProgress));
      }
    }
    if (context.level == 0) {
      // Reaching this point at level 0 means we are done: all the solutions
      // space has been searched and all the possible solutions have been
      // gathered.
      if (solutions.isEmpty) {
        // The board is not solvable
        throw ArgumentError("Board is not solvable");
      }
      // Or all the solutions (or maximum number of allowed solutions) have been
      // found.
      if (progressCallback != null) {
        progressCallback(100);
      }
    }
  }

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

typedef _FindSolutionsContext = ({int level, int progress});
