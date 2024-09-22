import 'board.dart' show Board;
import 'dart:math';
import 'package:fixnum/fixnum.dart';

enum PuzzleDifficulty { easy, medium, hard }

typedef GeneratorProgress = void Function(int currentStep, int totalSteps);

Board generateBoard(PuzzleDifficulty difficulty,
    [int dimension = 9, GeneratorProgress? progressCallback]) {
  assert(Board.allowedDimensions.contains(dimension));
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

/// Given a [boards] set of Boards, returns the position [lessFreqVarPos] where
/// the maximum difference between the accumulated frequency of values for the
/// position and the minimum frequency among all the values for the position.
/// Also returns the value for which the minimum frequency in [lessFreqVarPos]
/// occurs. That value is returned in [lessFreqVarVal].
///
/// This position of maximum frequency dispersion and its less frequent value
/// are used by the Generation algorithm as an heuristic while finding a Sudoku
/// board (with only one solution) among a set of possible solutions. The
/// heuristic aims at minimizing the number of filled board positions while
/// going from a board with multiple solutions and empty positions and at the
/// same time filling those positions with the value the varies the least, which
/// in theory would be easier to find by the Sudoku player, leaving the
/// positions with more variations (theoratically more difficult) for the player
/// to discover.
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
