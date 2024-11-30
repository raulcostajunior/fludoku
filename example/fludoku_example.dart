import 'package:fludoku/fludoku.dart';

void main() {
  var board = Board();
  board.setAt(row: 0, col: 0, value: 4);
  board.setAt(row: 3, col: 1, value: 6);
  try {
    board.setAt(row: 1, col: 2, value: 4);
  } on ArgumentError catch (e) {
    print('Exception: $e');
  }
  final valueSet = board.trySetAt(row: 1, col: 2, value: 4);
  assert(valueSet == false);
  print('board:\n$board\n');

  final (smallPuzzle, _) =
      generateBoard(level: PuzzleDifficulty.hard, dimension: 4);
  if (smallPuzzle != null) {
    print("Small puzzle:\n$smallPuzzle\n");
    var smallPuzzleSolution = findSolutions(smallPuzzle);
    print("Small puzzle solution:\n$smallPuzzleSolution\n");
  }

  final (puzzle, _) = generateBoard(level: PuzzleDifficulty.hard, dimension: 9);
  if (puzzle != null) {
    print("Puzzle:\n$puzzle\n");
    var puzzleSolution = findSolutions(puzzle);
    print("Puzzle solution:\n$puzzleSolution\n");
  }

  final (bigPuzzle, _) =
      generateBoard(level: PuzzleDifficulty.medium, dimension: 16);
  if (bigPuzzle != null) {
    print("Big puzzle:\n$bigPuzzle\n");
    var bigPuzzleSolution = findSolutions(bigPuzzle);
    print("Big puzzle solution:\n$bigPuzzleSolution\n");
  }
}
