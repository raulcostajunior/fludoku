import 'dart:math';

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

  /// Returns true if the board is empty (all its positions have value 0).
  bool get isEmpty => _values.every((row) => row.every((value) => value == 0));

  late final List<List<int>> _values;

  /// Finds all invalid positions in the Sudoku board.
  ///
  /// Checks the board for values that are out of range, as well as
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
    // Searches for duplicate non-empty values across square sections
    final sectionSize = sqrt(Board.dimension).toInt();
    for (var section = 0; section < Board.dimension; section++) {
      var initialCol = sectionSize * (section % sectionSize);
      var initialRow = sectionSize * (section ~/ sectionSize);
      // sectionValues keeps track of the different values in the current section,
      // storing the column and row of the first value found and whether it is repeated.
      // For the purposes of this method, there's no need to store the position of the
      // repetitions of the value in the section.
      var sectionValues =
          List<({int value, int rowFirst, int colFirst, bool repeated})>.empty(
              growable: true);
      for (var row = initialRow; row < initialRow + sectionSize; row++) {
        for (var col = initialCol; col < initialCol + sectionSize; col++) {
          var value = _values[row][col];
          if (value != 0 && value <= Board.maxValue) {
            // Value is not blank, check if it is repeated in the section.
            bool isFirstInSection = true;
            for (var sectionValue in sectionValues) {
              if (sectionValue.value == value) {
                isFirstInSection = false;
                // Value is repeated in the section.
                sectionValue = (
                  value: sectionValue.value,
                  rowFirst: sectionValue.rowFirst,
                  colFirst: sectionValue.colFirst,
                  repeated: true,
                );
                invalidPositions.add((row, col));
                if (stopAtFirst) {
                  return invalidPositions;
                }
              }
            }
            if (isFirstInSection) {
              // Registers the first occurence of the value in the section.
              sectionValues.add((
                value: value,
                rowFirst: row,
                colFirst: col,
                repeated: false,
              ));
            }
          }
        }
      }
      // Registers the first occurrences of repeated values in the section - the first occurrences
      // of repeated values are also considered invalid positions. The positions of the repetitions
      // have already been registered at the moment the repetition has been found.
      for (var sectionValue in sectionValues) {
        if (sectionValue.repeated) {
          invalidPositions.add((sectionValue.rowFirst, sectionValue.colFirst));
          // A first occurrence of a repeated value cannot be the first error found - the
          // repetition itself would have been the first error. If the stopAtFirst
          // method argument is true this point would never have been reached, so there's
          // no need to check for stopAtFirst and return immediately.
        }
      }
    }

    // Eliminates duplicates in the list of invalid positions.
    var invalidPositionsSet = Set.from(invalidPositions);

    return List.from(invalidPositionsSet);
  } // _getInvalidPositions
} // class Board
