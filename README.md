# fludoku

[![Unit Tests Status](https://github.com/raulcostajunior/fludoku/actions/workflows/ci.yml/badge.svg)](https://github.com/raulcostajunior/fludoku/actions/workflows/ci.yml)

Dart package for generating and solving Sudoku puzzles - Sudoku boards that have
only one solution.

Boards with dimensions 4, 9, 16 and 25 are supported. The most usual (and default) dimension is 9.

The generation of Sudoku puzzles of dimensions 16 and 25, especially when
`PuzzleDifficulty` is set to `medium` or `high`, can be a lengthy process, usually taking
several minutes. A timeout argument, in seconds, can be passed to the `generateSudokuPuzzle` function. The default timeout is `infinite`. Internally, any negative value for the timeout is interpreted as `infinite`.

A Flutter application demoing some non-obvious aspects of using the `Fludoku` package can be found in the [fludoku_demo](https://github.com/raulcostajunior/fludoku_demo) public Github repository.

## Tests

Unit tests are available for the `board`, `generator`, and `solver` libraries.

Use either `dart test` or `flutter test` to run the tests.

## Example

A usage example for the package:

```dart

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
      generateSudokuPuzzle(level: PuzzleDifficulty.hard, dimension: 4);
  if (smallPuzzle != null) {
    print("Small puzzle:\n$smallPuzzle\n");
    var smallPuzzleSolution = findSolutions(smallPuzzle);
    print("Small puzzle solution:\n$smallPuzzleSolution\n");
  }

  final (puzzle, _) = generateSudokuPuzzle(level: PuzzleDifficulty.hard, dimension: 9);
  if (puzzle != null) {
    print("Puzzle:\n$puzzle\n");
    var puzzleSolution = findSolutions(puzzle);
    print("Puzzle solution:\n$puzzleSolution\n");
  }

  final (bigPuzzle, _) =
      generateSudokuPuzzle(level: PuzzleDifficulty.medium, dimension: 16);
  if (bigPuzzle != null) {
    print("Big puzzle:\n$bigPuzzle\n");
    var bigPuzzleSolution = findSolutions(bigPuzzle);
    print("Big puzzle solution:\n$bigPuzzleSolution\n");
  }
}

```

The output of the example program:

```
❯ dart run example/fludoku_example.dart
Exception: Invalid argument(s): Cannot set (1, 2) to "4" as it would invalidate the board
board:

 4  -  -    -  -  -    -  -  -
 -  -  -    -  -  -    -  -  -
 -  -  -    -  -  -    -  -  -


 -  6  -    -  -  -    -  -  -
 -  -  -    -  -  -    -  -  -
 -  -  -    -  -  -    -  -  -


 -  -  -    -  -  -    -  -  -
 -  -  -    -  -  -    -  -  -
 -  -  -    -  -  -    -  -  -


Small puzzle:

 3  4    1  -
 1  -    -  -


 -  -    -  1
 -  -    4  -


Small puzzle solution:
[
 3  4    1  2
 1  2    3  4


 4  3    2  1
 2  1    4  3
]

Puzzle:

 -  8  2    4  9  6    -  -  -
 3  -  -    1  -  -    -  -  6
 -  -  -    -  -  2    -  1  -


 8  3  -    -  -  -    5  2  -
 -  -  -    2  -  -    1  3  8
 2  7  5    -  -  -    4  -  9


 4  -  7    6  -  5    -  -  1
 5  -  -    -  -  -    6  4  -
 -  -  -    -  -  -    -  -  5


Puzzle solution:
[
 1  8  2    4  9  6    7  5  3
 3  5  4    1  7  8    2  9  6
 7  6  9    5  3  2    8  1  4


 8  3  1    9  6  4    5  2  7
 9  4  6    2  5  7    1  3  8
 2  7  5    8  1  3    4  6  9


 4  9  7    6  2  5    3  8  1
 5  1  3    7  8  9    6  4  2
 6  2  8    3  4  1    9  7  5
]

Big puzzle:

 8 12 15  3    9 11 13  1    6  - 10  7    -  5  -  4
 - 11 13  1   14 12  -  3    8  5 16  4    6  - 10  7
 6  2 10  -    -  5  -  4    - 12 15  3    9 11 13  -
 -  -  -  -    6  2 10  7    - 11 13  -    -  - 15  3


12 14  3  -    -  9  1  -    -  -  7 10    -  -  - 16
11  9  1  -   15 14 12  -    5  8  - 16    3 10  -  2
 -  6  - 10    5  8  - 16   12 14  3  -    -  9  1 13
 -  8  4  -    3 10  -  2   11  -  1 13   12 14  6 15


15  - 14  9   12 13  - 10    1  7  -  2    -  4  8  5
 -  - 12  -    2  - 14  9   16  4  8  5   10  7  3  6
 -  -  -  8    -  4  3  5   15 13  - 12    2  1  9 11
16  -  2  5    -  7  -  8    - 10  - 11    - 13 14 12


 3 15  -  -    -  1  - 12    7 16 11  8    4  -  5 10
 - 13 11  -    -  3  9  -    4  -  5  6    7 16  2  8
 7 10  8  6    4  -  - 11   13  3  2  -    1 15  -  -
 4 16  -  2    7  6  8  -   10  1  -  9   13  - 11 14


Big puzzle solution:
[
 8 12 15  3    9 11 13  1    6  2 10  7   14  5 16  4
 9 11 13  1   14 12 15  3    8  5 16  4    6  2 10  7
 6  2 10  7    8  5 16  4   14 12 15  3    9 11 13  1
14  5 16  4    6  2 10  7    9 11 13  1    8 12 15  3


12 14  3 15   11  9  1 13    2  6  7 10    5  8  4 16
11  9  1 13   15 14 12  6    5  8  4 16    3 10  7  2
 2  6  7 10    5  8  4 16   12 14  3 15   11  9  1 13
 5  8  4 16    3 10  7  2   11  9  1 13   12 14  6 15


15  3 14  9   12 13 11 10    1  7  6  2   16  4  8  5
13  1 12 11    2 15 14  9   16  4  8  5   10  7  3  6
10  7  6  8   16  4  3  5   15 13 14 12    2  1  9 11
16  4  2  5    1  7  6  8    3 10  9 11   15 13 14 12


 3 15  9 14   13  1  2 12    7 16 11  8    4  6  5 10
 1 13 11 12   10  3  9 14    4 15  5  6    7 16  2  8
 7 10  8  6    4 16  5 11   13  3  2 14    1 15 12  9
 4 16  5  2    7  6  8 15   10  1 12  9   13  3 11 14
]

❯
```
