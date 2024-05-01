/// A Sudoku puzzle Board.
class Board {
  static const dimension = 9;
  static const maxValue = 9;

  Board() {
    _values = List.generate(Board.dimension,
        (row) => List.generate(Board.dimension, (col) => 0, growable: false),
        growable: false);
  }

  Board.clone(Board other) {
    _values = List.generate(
        Board.dimension,
        (row) => List.generate(
            Board.dimension, (col) => other._values[row][col],
            growable: false),
        growable: false);
  }

  /// Returns the [value] at the specified [row] and [column] on the Sudoku board.
  ///
  /// If the row or column is out of range, a [RangeError] is thrown.
  int getAt({required int row, required int col}) {
    if (row >= 0 &&
        row < Board.dimension &&
        col >= 0 &&
        col < Board.dimension) {
      return _values[row][col];
    }
    throw RangeError(
        'row and col must be between 0 and ${Board.dimension - 1}');
  }

  /// Sets the value at the specified row and column on the Sudoku board.
  ///
  /// If the [row] or [column] is out of range, a [RangeError] is thrown.
  /// If the value is out of range, a [RangeError] is thrown.
  /// If setting the [value] would invalidate the board, an [ArgumentError] is thrown.
  void setAt({required int row, required int col, required int value}) {
    if (row < 0 || row >= Board.dimension) {
      throw RangeError('row must be between 0 and ${Board.dimension - 1}');
    }
    if (col < 0 || col >= Board.dimension) {
      throw RangeError('col must be between 0 and ${Board.dimension - 1}');
    }
    if (value < 0 || value >= Board.maxValue) {
      throw RangeError(
          'value must be between 0 and ${Board.maxValue}. 0 is the blank value');
    }
    var boardWithValue = Board.clone(this);
    if (boardWithValue.isValid) {
      // The addition of the value doesn't invalidate the board.
      boardWithValue._values[row][col] = value;
    } else {
      // The addition of the value invalidates the board.
      throw ArgumentError(
          'Cannot set ($row, $col) to "$value" because it would invalidate the board');
    }
  }

  /// Returns true if the board is valid (synonym for "has no invalid position").
  bool get isValid => _getInvalidPositions(stopAtFirst: true).isEmpty;

  late final List<List<int>> _values;

  /// Finds all invalid positions in the Sudoku board.
  ///
  /// This method checks the board for values that are out of range, as well as
  /// duplicate non-empty values across rows, columns or any of the square
  /// sections of the board. It returns a list of (row, column) tuples
  /// representing the invalid positions.
  ///
  /// If [stopAtFirst] is true, the method will return as soon as the first
  /// invalid position is found.
  List<(int, int)> _getInvalidPositions({bool stopAtFirst = false}) {
    var invalidPositions = <(int, int)>[];

    // Searches for out of range values
    for (var row = 0; row < Board.dimension; row++) {
      for (var col = 0; col < Board.dimension; col++) {
        if (_values[row][col] < 0 || _values[row][col] > Board.maxValue) {
          invalidPositions.add((row, col));
          if (stopAtFirst) {
            return invalidPositions;
          }
        }
      }
    }
    // Searches for duplicate non-empty values across rows
    for (var row = 0; row < Board.dimension; row++) {
      for (var col = 0; col < Board.dimension; col++) {
        int currentValue = _values[row][col];
        if (currentValue != 0 && currentValue <= Board.maxValue) {
          for (var col2 = col + 1; col2 < Board.dimension; col2++) {
            if (_values[row][col2] == currentValue) {
              invalidPositions.add((row, col));
              if (stopAtFirst) {
                return invalidPositions;
              }
            }
          }
        }
      }
    }
    // Searches for duplicate non-empty values across columns
    for (var col = 0; col < Board.dimension; col++) {
      for (var row = 0; row < Board.dimension; row++) {
        int currentValue = _values[row][col];
        if (currentValue != 0 && currentValue <= Board.maxValue) {
          for (var row2 = row + 1; row2 < Board.dimension; row2++) {
            if (_values[row2][col] == currentValue) {
              invalidPositions.add((row, col));
              if (stopAtFirst) {
                return invalidPositions;
              }
            }
          }
        }
      }
    }
    // TODO: Searches for duplicate non-empty values across square sections

    return invalidPositions;
  }
}
