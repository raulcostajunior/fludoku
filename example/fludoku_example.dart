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
  print('board:$board');

  var smallBoard = Board(4);
  smallBoard.setAt(row: 0, col: 0, value: 1);
  smallBoard.setAt(row: 1, col: 1, value: 2);
  print('smallBoard:$smallBoard');
}
