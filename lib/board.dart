import 'dart:math';

/// A Sudoku puzzle Board.
class Board {
  static const dimension = 9;
  static final groupSize = sqrt(dimension).toInt();
  static const maxValue = dimension;

  //#region Constructors

  Board() {
    _values = List.generate(Board.dimension,
        (row) => List.generate(Board.dimension, (col) => 0, growable: false),
        growable: false);
  }

  Board.clone(final Board other) {
    _values = List.generate(
        Board.dimension,
        (row) => List.generate(
            Board.dimension, (col) => other._values[row][col],
            growable: false),
        growable: false);
  }

  Board.from(final List<List<int>> values) {
    _values = List.generate(
        Board.dimension,
        (row) => List.generate(Board.dimension, (col) => values[row][col],
            growable: false),
        growable: false);
  }

  //#endregion

  //#region Read-only Properties

  /// Returns true if the board is valid (synonym for "has no invalid position").
  bool get isValid => _getInvalidPositions(stopAtFirst: true).isEmpty;

  /// Returns true if the board is empty (all its positions have value 0).
  bool get isEmpty => _values.every((row) => row.every((value) => value == 0));

  /// Returns a list with the blank positions of the board (positions with
  /// value 0).
  List<({int row, int col})> get blankPositions {
    var blanks = <({int row, int col})>[];
    for (var row = 0; row < Board.dimension; row++) {
      for (var col = 0; col < Board.dimension; col++) {
        if (_values[row][col] == 0) {
          blanks.add((row: row, col: col));
        }
      }
    }
    return blanks;
  }

  /// Returns a list with the invalid positions of the board.
  List<({int row, int col})> get invalidPositions => _getInvalidPositions();

  /// Returns true if the Sudoku board is complete (valid without any blank position)
  bool get isComplete => blankPositions.isEmpty && isValid;

  //#endregion

  //#region Identity and Equality

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Board) {
      return false;
    }
    var allEqual = true;
    for (final (rowIdx, row) in _values.indexed) {
      for (final (colIdx, posValue) in row.indexed) {
        if (posValue != other._values[rowIdx][colIdx]) {
          allEqual = false;
          break;
        }
      }
    }
    return allEqual;
  }

  @override
  int get hashCode => Object.hashAll(_values);

  //#endregion

  /// Returns the [value] at the specified [row] and [column] on the Sudoku board.
  ///
  /// If the row or column is out of range, a [RangeError] is thrown.
  int getAt({required int row, required int col}) {
    _checkRowCol(row, col);
    return _values[row][col];
  }

  /// Sets the value at the specified row and column on the Sudoku board.
  ///
  /// If the [row] or [column] is out of range, a [RangeError] is thrown.
  /// If the value is out of range, a [RangeError] is thrown.
  /// If setting the [value] would invalidate the board, an [ArgumentError] is thrown.
  void setAt({required int row, required int col, required int value}) {
    _checkRowCol(row, col);
    if (value < 0 || value > Board.maxValue) {
      throw RangeError(
          'value must be between 0 and ${Board.maxValue}. 0 is the blank value');
    }
    var boardWithValue = Board.clone(this);
    boardWithValue._values[row][col] = value;
    if (boardWithValue.isValid) {
      // The addition of the value doesn't invalidate the board.
      _values[row][col] = value;
    } else {
      // The addition of the value invalidates the board.
      throw ArgumentError(
          'Cannot set ($row, $col) to "$value" as it would invalidate the board');
    }
  }

  /// Returns the set of possible values that can be placed at the specified
  /// position of the Board.
  /// If the [row] or [column] is out of range, a [RangeError] is thrown.
  Set<int> possibleValuesAt({required int row, required int col}) {
    _checkRowCol(row, col);
    var possibleValues =
        Set<int>.from(List.generate(Board.maxValue, (i) => i + 1));
    // Removes all values already in the same row and column.
    for (var i = 0; i < Board.dimension; i++) {
      possibleValues.remove(_values[row][i]);
      possibleValues.remove(_values[i][col]);
    }
    // Removes all values already in the same board section
    var rowStart = (row / Board.groupSize).floor() * Board.groupSize;
    var colStart = (col / Board.groupSize).floor() * Board.groupSize;
    for (var i = rowStart; i < rowStart + Board.groupSize; i++) {
      for (var j = colStart; j < colStart + Board.groupSize; j++) {
        possibleValues.remove(_values[i][j]);
      }
    }
    return possibleValues;
  }

  /// Clears the board.
  void clear() {
    for (var row = 0; row < Board.dimension; row++) {
      for (var col = 0; col < Board.dimension; col++) {
        _values[row][col] = 0;
      }
    }
  }

  late final List<List<int>> _values;

  void _checkRowCol(int row, int col) {
    if (row < 0 || row >= Board.dimension) {
      throw RangeError('row must be between 0 and ${Board.dimension - 1}');
    }
    if (col < 0 || col >= Board.dimension) {
      throw RangeError('col must be between 0 and ${Board.dimension - 1}');
    }
  }

  /// Finds all invalid positions in the Sudoku board.
  ///
  /// Checks the board for values that are out of range, as well as
  /// duplicate non-empty values across rows, columns or any of the square
  /// sections of the board. It returns a list of (row, column) records
  /// representing the invalid positions.
  ///
  /// If [stopAtFirst] is true, the method will return as soon as the first
  /// invalid position is found.
  List<({int row, int col})> _getInvalidPositions({bool stopAtFirst = false}) {
    var invalidPositions = <({int row, int col})>[];

    // Searches for out of range values
    for (var row = 0; row < Board.dimension; row++) {
      for (var col = 0; col < Board.dimension; col++) {
        if (_values[row][col] < 0 || _values[row][col] > Board.maxValue) {
          invalidPositions.add((row: row, col: col));
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
              invalidPositions.add((row: row, col: col));
              if (stopAtFirst) {
                return invalidPositions;
              }
              // Also adds the position of the repeated item to the list
              // of invalid positions
              invalidPositions.add((row: row, col: col2));
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
              invalidPositions.add((row: row, col: col));
              if (stopAtFirst) {
                return invalidPositions;
              }
              // Also adds the position of the repeated item to the list
              // of invalids
              invalidPositions.add((row: row2, col: col));
            }
          }
        }
      }
    }
    // Searches for duplicate non-empty values across square sections
    for (var section = 0; section < Board.dimension; section++) {
      var initialCol = Board.groupSize * (section % Board.groupSize);
      var initialRow = Board.groupSize * (section ~/ Board.groupSize);
      // sectionValues keeps track of the different values in the current section,
      // storing the column and row of the first value found and whether it is repeated.
      // For the purposes of this method, there's no need to store the position of the
      // repetitions of the value in the section.
      var sectionValues =
          List<({int value, int rowFirst, int colFirst, bool repeated})>.empty(
              growable: true);
      for (var row = initialRow; row < initialRow + Board.groupSize; row++) {
        for (var col = initialCol; col < initialCol + Board.groupSize; col++) {
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
                invalidPositions.add((row: row, col: col));
                if (stopAtFirst) {
                  return invalidPositions;
                }
              }
            }
            if (isFirstInSection) {
              // Registers the first occurrence of the value in the section.
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
          invalidPositions
              .add((row: sectionValue.rowFirst, col: sectionValue.colFirst));
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

  @override
  String toString() {
    var strBuff = StringBuffer("\n");
    for (var lin = 0; lin < Board.dimension; lin++) {
      for (var col = 0; col < Board.dimension; col++) {
        var value = _values[lin][col] > 0 ? _values[lin][col] : '_';
        strBuff.write("$value ");
        if ((col + 1) % Board.groupSize == 0) {
          strBuff.write(" ");
        }
      }
      strBuff.write("\n");
      if ((lin + 1) % Board.groupSize == 0 && (lin + 1) < Board.dimension) {
        strBuff.write("\n");
      }
    }
    return strBuff.toString();
  }
} // class Board
