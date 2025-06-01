import 'dart:math';

/// A board that can be a Sudoku Puzzle (with only one possible solution) or not.
/// Any non-zero value in the set of initial values for the board becomes a
/// read-only position, and as such, cannot be modified.
class Board {
  static const allowedDimensions = [4, 9, 16, 25];
  final int _dimension;
  late int _groupSize;
  late int _maxValue;

  //#region Constructors

  /// Constructs an empty board - all the positions set to zero.
  Board([int dimension = 9])
      : assert(Board.allowedDimensions.contains(dimension)),
        _dimension = dimension {
    _groupSize = sqrt(_dimension).toInt();
    _maxValue = _dimension;
    _values = List.generate(_dimension,
        (row) => List.generate(_dimension, (col) => 0, growable: false),
        growable: false);
    // An empty board can have all its positions modified - it is surely not a Puzzle
    // (with one solution)
    _readOnlyPositions = [];
  }

  /// Clones a board. Preserves the readOnlyPositions from the original board
  /// - which were defined when the original board was constructed.
  Board.clone(final Board other) : _dimension = other._dimension {
    _groupSize = other._groupSize;
    _maxValue = other._maxValue;
    _values = List.generate(
        _dimension,
        (row) => List.generate(_dimension, (col) => other._values[row][col],
            growable: false),
        growable: false);
    // The clone has the same read-only positions as the original
    _readOnlyPositions = List.from(other._readOnlyPositions);
  }

  // Constructs a board from its list of values. The read-only positions of the
  // constructed board are defined from the given values (the read-only
  // positions are those with non-zero values).
  Board.withValues(final List<List<int>> values)
      : assert(Board.allowedDimensions.contains(values.length)),
        _dimension = values.length {
    _groupSize = sqrt(_dimension).toInt();
    _maxValue = _dimension;
    _values = List.generate(
        values.length,
        (row) => List.generate(values.length, (col) => values[row][col],
            growable: false),
        growable: false);
    // All the non-zero valued positions of the board being constructed are
    // considered to be read-only positions (pre-filled positions of a puzzle)
    _readOnlyPositions = [];
    for (var row = 0; row < _dimension; row++) {
      for (var col = 0; col < _dimension; col++) {
        if (_values[row][col] != 0) {
          _readOnlyPositions.add((row: row, col: col));
        }
      }
    }
  }

  //#endregion

  //#region Read-only Properties

  /// The board's dimension - number of rows and columns
  int get dimension => _dimension;

  /// The maximum value that can be placed in a board position - the range of allowed values is 1 to [maxValue].
  int get maxValue => _maxValue;

  /// Returns true if the board is valid (synonym for "has no invalid position").
  bool get isValid => _getInvalidPositions(stopAtFirst: true).isEmpty;

  /// Returns true if the board is empty (all its positions have value 0).
  bool get isEmpty => _values.every((row) => row.every((value) => value == 0));

  /// Returns a list with the blank positions of the board (positions with
  /// value 0).
  List<({int row, int col})> get blankPositions {
    var blanks = <({int row, int col})>[];
    for (var row = 0; row < _dimension; row++) {
      for (var col = 0; col < _dimension; col++) {
        if (_values[row][col] == 0) {
          blanks.add((row: row, col: col));
        }
      }
    }
    return blanks;
  }

  /// Returns a list with the read-only positions of the board. For boards that
  /// are Sudoku puzzles the read-only positions are the pre-filled positions
  /// that the user cannot change.
  List<({int row, int col})> get readOnlyPositions =>
      // NOTE: the returned list of readOnlyPositions must be immutable - if not
      // the guarantee that read-only positions can only be defined at board
      // construction time would be violated.
      List<({int row, int col})>.unmodifiable(_readOnlyPositions);

  /// Returns a list with the invalid positions of the board.
  List<({int row, int col})> get invalidPositions => _getInvalidPositions();

  /// Returns true if the Sudoku board is complete (valid without any blank position)
  bool get isComplete => blankPositions.isEmpty && isValid;

  /// Returns true if the Sudoku board is solvable (not empty and valid but yet not complete).
  bool get isSolvable => !isEmpty && isValid && !isComplete;

  /// Returns the values of the board as a list of lists (the nested lists are for each row).
  List<List<int>> get values {
    // NOTE: A copy of the internal list of values of the board is returned to avoid
    //       external bypassing of the checks performed by the setAt method.
    return List.generate(
        _dimension,
        (row) => List.generate(_dimension, (col) => _values[row][col],
            growable: false),
        growable: false);
  }

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

  /// Returns the [value] at the specified [row] and [col] on the Sudoku board.
  ///
  /// If the row or column is out of range, a [RangeError] is thrown.
  int getAt({required int row, required int col}) {
    _checkRowCol(row, col);
    return _values[row][col];
  }

  /// Sets the value at the specified row and column on the Sudoku board.
  ///
  /// If the [row] or [col] is out of range, a [RangeError] is thrown.
  /// If the value is out of range, a [RangeError] is thrown.
  /// If setting the [value] would invalidate the board, an [ArgumentError] is thrown.
  /// If the [row] and [col] specify a read-only position of the board, an
  /// [ArgumentError] is thrown.
  void setAt({required int row, required int col, required int value}) {
    _checkRowCol(row, col);
    if (value < 0 || value > _maxValue) {
      throw RangeError(
          'value must be between 0 and $_maxValue. 0 is the blank value');
    }
    if (_readOnlyPositions.contains((row: row, col: col))) {
      throw ArgumentError('Position ($row, $col) is read-only; cannot be set');
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

  /// Sets the [value] at the specified [row] and [col] on the Sudoku board,
  /// if doing so doesn't invalidate the board.
  ///
  /// Returns true if the value was set, false otherwise.
  bool trySetAt({required int row, required int col, required int value}) {
    try {
      setAt(row: row, col: col, value: value);
      return true;
    } on Error {
      return false;
    }
  }

  /// Returns the set of possible values that can be placed at the specified
  /// position of the Board.
  /// If the [row] or [col] is out of range, a [RangeError] is thrown.
  Set<int> possibleValuesAt({required int row, required int col}) {
    _checkRowCol(row, col);
    var possibleValues = Set<int>.from(List.generate(_maxValue, (i) => i + 1));
    // Removes all values already in the same row and column.
    for (var i = 0; i < _dimension; i++) {
      possibleValues.remove(_values[row][i]);
      possibleValues.remove(_values[i][col]);
    }
    // Removes all values already in the same board section
    var rowStart = (row / _groupSize).floor() * _groupSize;
    var colStart = (col / _groupSize).floor() * _groupSize;
    for (var i = rowStart; i < rowStart + _groupSize; i++) {
      for (var j = colStart; j < colStart + _groupSize; j++) {
        possibleValues.remove(_values[i][j]);
      }
    }
    return possibleValues;
  }

  /// Clears the board.
  void clear() {
    for (var row = 0; row < _dimension; row++) {
      for (var col = 0; col < _dimension; col++) {
        _values[row][col] = 0;
      }
    }
  }

  late final List<List<int>> _values;
  late final List<({int row, int col})> _readOnlyPositions;

  void _checkRowCol(int row, int col) {
    if (row < 0 || row >= _dimension) {
      throw RangeError('row must be between 0 and ${_dimension - 1}');
    }
    if (col < 0 || col >= _dimension) {
      throw RangeError('col must be between 0 and ${_dimension - 1}');
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
    for (var row = 0; row < _dimension; row++) {
      for (var col = 0; col < _dimension; col++) {
        if (_values[row][col] < 0 || _values[row][col] > _maxValue) {
          invalidPositions.add((row: row, col: col));
          if (stopAtFirst) {
            return invalidPositions;
          }
        }
      }
    }
    // Searches for duplicate non-empty values across rows
    for (var row = 0; row < _dimension; row++) {
      for (var col = 0; col < _dimension; col++) {
        int currentValue = _values[row][col];
        if (currentValue != 0 && currentValue <= _maxValue) {
          for (var col2 = col + 1; col2 < _dimension; col2++) {
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
    for (var col = 0; col < _dimension; col++) {
      for (var row = 0; row < _dimension; row++) {
        int currentValue = _values[row][col];
        if (currentValue != 0 && currentValue <= _maxValue) {
          for (var row2 = row + 1; row2 < _dimension; row2++) {
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
    for (var section = 0; section < _dimension; section++) {
      var initialCol = _groupSize * (section % _groupSize);
      var initialRow = _groupSize * (section ~/ _groupSize);
      // sectionValues keeps track of the different values in the current section,
      // storing the column and row of the first value found and whether it is repeated.
      // For the purposes of this method, there's no need to store the position of the
      // repetitions of the value in the section.
      var sectionValues =
          List<({int value, int rowFirst, int colFirst, bool repeated})>.empty(
              growable: true);
      for (var row = initialRow; row < initialRow + _groupSize; row++) {
        for (var col = initialCol; col < initialCol + _groupSize; col++) {
          var value = _values[row][col];
          if (value != 0 && value <= _maxValue) {
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
    for (var lin = 0; lin < _dimension; lin++) {
      for (var col = 0; col < _dimension; col++) {
        int value = _values[lin][col];
        switch (value) {
          case 0:
            strBuff.write(" - ");
          case < 10:
            strBuff.write(" $value ");
          default:
            strBuff.write("$value ");
        }
        if ((col + 1) % _groupSize == 0) {
          strBuff.write("  ");
        }
      }
      strBuff.write("\n");
      if ((lin + 1) % _groupSize == 0 && (lin + 1) < _dimension) {
        strBuff.write("\n\n");
      }
    }
    return strBuff.toString();
  }
} // class Board
