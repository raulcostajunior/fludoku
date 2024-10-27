import 'package:fludoku/fludoku.dart';
import 'package:fludoku/generator.dart';

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

  var smallPuzzle = generateBoard(PuzzleDifficulty.hard, 4);
  print("Small puzzle:\n$smallPuzzle\n");
  var smallPuzzleSolution = findSolutions(smallPuzzle);
  print("Small puzzle solution:\n$smallPuzzleSolution\n");

  var puzzle = generateBoard(PuzzleDifficulty.hard, 9);
  print("Puzzle:\n$puzzle\n");
  var puzzleSolution = findSolutions(puzzle);
  print("Puzzle solution:\n$puzzleSolution\n");

  var bigPuzzle = generateBoard(PuzzleDifficulty.medium, 16);
  print("Big puzzle:\n$bigPuzzle\n");
  var bigPuzzleSolution = findSolutions(bigPuzzle);
  print("Big puzzle solution:\n$bigPuzzleSolution\n");
}
