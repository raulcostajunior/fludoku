import 'board.dart' show Board;
import 'dart:math';

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
  // Ordered list with values to be randomically transfered to the candidates
  // vector being generated.
  List<int> availables = List.generate(dimension, (idx) => idx + 1);
  List<int> candidates = [];
  var rnd = Random();
  while (availables.length > 1) {
    int candidateIdx = rnd.nextInt(availables.length);
    candidates.add(availables[candidateIdx]);
    availables.removeAt(candidateIdx);
  }
  candidates.add(availables[0]);
  return candidates;
}
