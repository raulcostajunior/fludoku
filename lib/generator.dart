import 'package:fludoku/solver.dart';

import 'board.dart' show Board;
import 'dart:math';
import 'package:fixnum/fixnum.dart';

enum PuzzleDifficulty {
  // TODO: maxEmpty must be relative to the board dimension.
  // Easy: 41.97%, Medium: 59.25%, Hard: 71.60%
  easy(maxEmpty: 34),
  medium(maxEmpty: 48),
  hard(maxEmpty: 58);

  const PuzzleDifficulty({required this.maxEmpty});

  final int maxEmpty;
}

typedef GeneratorProgress = void Function({int current, int total});

Board generateBoard(PuzzleDifficulty difficulty,
    [int dimension = 9, GeneratorProgress? progressCallback]) {
  assert(Board.allowedDimensions.contains(dimension));
  // The last step, reduction of empty positions to guarantee single solution,
  // is the one that takes longer, specially for the Hard level.
  const totalSteps = 5;
  // Step 1 -> random candidate vector generation.
  var currentStep = 1;
  progressCallback?.call(current: currentStep, total: totalSteps);
  final candidatesVector = _genCandidatesVector(dimension);
  // Step 2 -> seeds a valid random board by initializing a random position with
  //           a random value.
  currentStep++;
  var rnd = Random();
  progressCallback?.call(current: currentStep, total: totalSteps);
  Board genBoard = Board(dimension);
  genBoard.setAt(
      row: rnd.nextInt(dimension),
      col: rnd.nextInt(dimension),
      value: rnd.nextInt(dimension) + 1);
  // Step 3 -> solve the random board seeded in the last step - simply picks up
  //           one of the many possible solutions for a board with just one
  //           position set.
  currentStep++;
  progressCallback?.call(current: currentStep, total: totalSteps);
  // For this specific execution of findSolutionWithCandidates, it is safe to
  // assume that a solution will be found: we started from a board with only
  // one non-empty position.
  Board solvedGenBoard =
      findSolutionWithCandidates(genBoard, candidatesVector)!;
  // Step 4 -> empty the maximum number of positions allowed for the difficulty
  //           level of the board being generated.
  currentStep++;
  progressCallback?.call(current: currentStep, total: totalSteps);
  genBoard = Board.clone(solvedGenBoard);
  final emptyPositions = <({int row, int col})>{};
  while (emptyPositions.length < difficulty.maxEmpty) {
    emptyPositions
        .add((row: rnd.nextInt(dimension), col: rnd.nextInt(dimension)));
  }
  for (final emptyPos in emptyPositions) {
    genBoard.setAt(row: emptyPos.row, col: emptyPos.col, value: 0);
  }
  // Steps 5 -> Fill the empty positions one by one until the generated
  // board has only one solution.
  currentStep++;
  progressCallback?.call(current: currentStep, total: totalSteps);
  // The positions will be optimally set to reduce the board solution set as
  // fast as possible.
  while (true) {
    final solutions = findSolutions(genBoard, maxSolutions: 20);
    if (solutions.length == 1) {
      // the current genBoard is a true Sudoku puzzle (only has one solution)
      break;
    }
    final (val, pos) = _getLessFrequentVariation(solutions);
    genBoard.setAt(
        row: pos ~/ genBoard.dimension,
        col: pos % genBoard.dimension,
        value: val);
  }
  return genBoard;
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
