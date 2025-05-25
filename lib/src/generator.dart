import 'dart:async';

import 'solver.dart';
import 'board.dart';
import 'dart:math';
import 'package:fixnum/fixnum.dart';

import 'timeout_tracker.dart';

enum PuzzleDifficulty {
  easy(maxEmptyPercent: 0.4197),
  medium(maxEmptyPercent: 0.5925),
  hard(maxEmptyPercent: 0.7160);

  const PuzzleDifficulty({required double maxEmptyPercent})
      : _maxEmptyPercent = maxEmptyPercent;

  final double _maxEmptyPercent;

  /// Calculates the maximum number of empty positions allowed for a puzzle board of the given dimension, based on the difficulty level.
  ///
  /// The maximum number of empty positions is determined by the [PuzzleDifficulty] enum, which specifies a maximum percentage of empty positions for each difficulty level.
  ///
  /// Parameters:
  /// - `dimension`: The dimension of the puzzle board, which must be one of the allowed dimensions specified in [Board.allowedDimensions]. Defaults to 9.
  ///
  /// Returns:
  /// The maximum number of empty positions allowed for the puzzle board of the given dimension.
  int maxEmpty({int dimension = 9}) {
    assert(Board.allowedDimensions.contains(dimension));
    return (dimension * dimension * _maxEmptyPercent).toInt();
  }
}

typedef GeneratorProgress = void Function({int current, int total});

/// Generates a new Sudoku board with the specified difficulty level and dimensions. A Sudoku board is a puzzle that is guaranteed to have only one solution.
///
/// Parameters:
/// - `level`: The difficulty level of the puzzle, which determines the maximum number of empty positions.
/// - `dimension`: The dimension of the puzzle board, which must be one of the allowed dimensions specified in [Board.allowedDimensions]. Defaults to 9.
/// - `timeoutSecs`: The maximum number of seconds to spend generating the board. If the generation takes longer, it will be aborted and a `String` error message will be returned.
/// - `onProgress`: An optional callback function that will be called with the current and total steps of the generation process.
///
/// Returns:
/// A record containing the generated puzzle [Board] and an optional error message as a [String]. If an error occurs, the [Board] will be `null`.
(Board?, String?) generateSudokuBoard(
    {PuzzleDifficulty level = PuzzleDifficulty.medium,
    int dimension = 9,
    int timeoutSecs = 15,
    GeneratorProgress? onProgress}) {
  assert(Board.allowedDimensions.contains(dimension));
  final tracker = TimeoutTracker(timeoutSecs * 1000);
  final timeoutMsg =
      "Board generation timed out. Limit of $timeoutSecs secs reached";
  // The last step, reduction of empty positions to guarantee single solution,
  // is the one that takes longer, specially for the Hard level.
  const totalSteps = 5;
  // Step 1 -> random candidate vector generation.
  var currentStep = 1;
  onProgress?.call(current: currentStep, total: totalSteps);
  final candidatesVector = _genCandidatesVector(dimension);
  if (tracker.timedout) {
    return (null, timeoutMsg);
  }
  // Step 2 -> seeds a valid random board by initializing a random position with
  //           a random value.
  currentStep++;
  var rnd = Random();
  onProgress?.call(current: currentStep, total: totalSteps);
  Board genBoard = Board(dimension);
  genBoard.setAt(
      row: rnd.nextInt(dimension),
      col: rnd.nextInt(dimension),
      value: rnd.nextInt(dimension) + 1);
  // Step 3 -> solve the random board seeded in the last step - simply picks up
  //           one of the many possible solutions for a board with just one
  //           position set.
  currentStep++;
  onProgress?.call(current: currentStep, total: totalSteps);
  var (solvedGenBoard, findStartingTimedout) =
      _findStartingSolution(genBoard, candidatesVector, tracker);
  if (findStartingTimedout) {
    return (null, timeoutMsg);
  }
  // Step 4 -> empty the maximum number of positions allowed for the difficulty
  //           level of the board being generated.
  currentStep++;
  onProgress?.call(current: currentStep, total: totalSteps);
  // Update the genBoard from the solvedGenBoard. NOTE: as the genBoard started
  // its life as an all empty board (and hence with no read-only positions), it
  // is important that the update happens by setting each value instead of by
  // replacing it with a clone of the solvedGenBoard to keep its set of read-only
  // positions empty.
  for (int row = 0; row < genBoard.dimension; row++) {
    for (int col = 0; col < genBoard.dimension; col++) {
      genBoard.setAt(
          row: row, col: col, value: solvedGenBoard!.getAt(row: row, col: col));
    }
  }
  final emptyPositions = <({int row, int col})>{};
  final maxEmpty = level.maxEmpty(dimension: genBoard.dimension);
  while (emptyPositions.length < maxEmpty) {
    emptyPositions
        .add((row: rnd.nextInt(dimension), col: rnd.nextInt(dimension)));
  }
  if (tracker.timedout) {
    return (null, timeoutMsg);
  }
  for (final emptyPos in emptyPositions) {
    genBoard.setAt(row: emptyPos.row, col: emptyPos.col, value: 0);
  }
  // Steps 5 -> Fill the empty positions one by one until the generated
  // board has only one solution.
  currentStep++;
  onProgress?.call(current: currentStep, total: totalSteps);
  // The positions will be optimally set to reduce the board solution set as
  // fast as possible.
  while (true) {
    if (tracker.timedout) {
      return (null, timeoutMsg);
    }
    try {
      final solutions =
          findSolutions(genBoard, maxSolutions: 2, tracker: tracker);
      if (solutions.length == 1) {
        // the current genBoard is a true Sudoku puzzle (only has one solution)
        break;
      }
      final (val, pos) = _getLessFrequentVariation(solutions);
      genBoard.setAt(
          row: pos ~/ genBoard.dimension,
          col: pos % genBoard.dimension,
          value: val);
    } on TimeoutException {
      return (null, timeoutMsg);
    }
  }
  // NOTE: For the read-only positions of the generated board to be properly
  //       initialized, a clone of it is returned. During the construction of
  //       the clone, the read-only positions are initialized.
  return (Board.clone(genBoard), null);
}

/// Generates a vector with candidate values for a board position in a random
/// order.
List<int> _genCandidatesVector([int dimension = 9]) {
  assert(Board.allowedDimensions.contains(dimension));
  // Ordered list with values to be randomically transferred to the candidates
  // vector being generated.
  List<int> availableVals = List.generate(dimension, (idx) => idx + 1);
  List<int> candidates = [];
  var rnd = Random();
  while (availableVals.length > 1) {
    int candidateIdx = rnd.nextInt(availableVals.length);
    candidates.add(availableVals[candidateIdx]);
    availableVals.removeAt(candidateIdx);
  }
  candidates.add(availableVals[0]);
  return candidates;
}

(Board? solution, bool timedOut) _findStartingSolution(final Board puzzle,
    List<int> candidatesVector, final TimeoutTracker tracker) {
  assert(candidatesVector.length == puzzle.dimension);
  assert(candidatesVector.toSet().length == puzzle.dimension);
  assert(candidatesVector
      .every((element) => element >= 1 && element <= puzzle.dimension));
  assert(puzzle.isSolvable);

  List<({int row, int col})> blanks = puzzle.blankPositions;
  Board solvedBoard =
      Board.clone(puzzle); // puzzle is the starting poin for the solvedBoard
  int currCellPos = 0;
  while (currCellPos < blanks.length) {
    if (tracker.timedout) {
      return (null, true);
    }
    var currCell = blanks[currCellPos];
    var currCellValue = solvedBoard.getAt(row: currCell.row, col: currCell.col);
    int candidatesIdx = 0;
    if (currCellValue != 0) {
      // We're backtracking, so we must start with the next candidate value
      candidatesIdx = candidatesVector.indexOf(currCellValue) + 1;
    }
    bool currCellSolved = false;
    while (!currCellSolved && candidatesIdx < candidatesVector.length) {
      try {
        solvedBoard.setAt(
            row: currCell.row,
            col: currCell.col,
            value: candidatesVector[candidatesIdx]);
        currCellSolved = true;
      } on ArgumentError {
        // The current candidate value would invalidate the board, try the next
        candidatesIdx++;
      }
    }
    if (currCellSolved) {
      currCellPos++;
    } else {
      // There was no solution for the next cell - we have to roll back to the
      // previous cell
      if (currCellPos > 0) {
        // Resets the current cell before going back to the previous one
        solvedBoard.setAt(row: currCell.row, col: currCell.col, value: 0);
        currCellPos--;
      }
    }
  }
  return (solvedBoard, false);
}

/// Given a [boards] set of Boards, finds the position where the difference
/// between the accumulated frequencies of all the values and the minimum value
/// frequency is maximal, [lessFreqVarPos]. Also gets the value for which the
/// minimum frequency occurs, [lessFreqVarVal].
///
/// This position of maximum frequency dispersion and its less frequent value
/// are used by the Generation algorithm as an heuristic while finding a Sudoku
/// board (with only one solution) among a set of possible solutions. The
/// heuristic aims at minimizing the number of filled board positions while
/// going from a board with multiple solutions and empty positions to the board
/// with a single solution. At the same time, fills those positions with the
/// value the varies the least, which, in theory, are easier for a Sudoku
/// player to find, leaving positions with more variations for the player to
/// discover.
(int lessFreqVarVal, int lessFreqVarPos) _getLessFrequentVariation(
    final List<Board> boards) {
  assert(boards.isNotEmpty);
  final dim = boards[0].dimension;
  for (final board in boards) {
    assert(board.dimension == dim);
  }
  // Accumulates the frequencies of all the values in all the positions of the
  // boards.
  final List<Map<int, int>> valsFreqs =
      List.generate(dim * dim, (int i) => <int, int>{});
  for (final board in boards) {
    for (var row = 0; row < dim; row++) {
      for (var col = 0; col < dim; col++) {
        final pos = row * dim + col;
        final val = board.getAt(row: row, col: col);
        if (valsFreqs[pos].containsKey(val)) {
          valsFreqs[pos][val] = valsFreqs[pos][val]! + 1;
        } else {
          valsFreqs[pos][val] = 1;
        }
      }
    }
  }
  // Finds the position where the difference between the accumulated frequencies
  // of all the values and the minimum value frequency is maximal. Also gets the
  // value for which the minimum frequency occurs.
  var lfvPos = 0;
  var lfvVal = 0;
  var maxDist = 0;
  for (var pos = 0; pos < dim * dim; pos++) {
    var minFreq = Int64.MAX_VALUE.toInt();
    var minFreqVal = 0;
    var totalFreq = 0;
    valsFreqs[pos].forEach((int value, int freq) {
      totalFreq += freq;
      if (freq < minFreq) {
        minFreq = freq;
        minFreqVal = value;
      }
    });
    if (totalFreq - minFreq > maxDist) {
      // Found a new maximum for the difference between the accumulated
      // frequencies and minimum frequency for a position. Capture the position
      // and the value for which the minimum frequency happens.
      maxDist = totalFreq - minFreq;
      lfvVal = minFreqVal;
      lfvPos = pos;
    }
  }
  return (lfvVal, lfvPos);
}
