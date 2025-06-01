## 4.0.0

- `Board.from` constructor renamed to `Board.withValues`.
- `Board.clone` now preserves the `readOnlyPositions` of the cloned board, instead of deriving the `readOnlyPositions` from the original's board list of values at the time of the cloning operation. `Board.withValues` retains the same behavior of its previous `Board.from` form: initialize `readOnlyPositions` from the non-zero values in the list.
- Added a read-only property that returns the values in the board as a list of list of ints. The new property makes it easy to create a board with the same values of another board, but with a fresh `readOnlyPositions`.
- Extended test cases to cover the differences in the initialization of read-only positions between the constructors.

## 3.0.0

- `generateBoard` function renamed to `generateSudokuPuzzle` to better reflect what it generates. A Sudoku puzzle is a board that is known to have only 1 solution. In addition, the use of terms `board` and `puzzle` in the documentation is more accurate than in the previous version.
- A read-only property, `readOnlyPositions` (pum non-intended :)) has been added to the `Board` class. That property is initialized at construction time to contain the (row, col) positions of the non-zero initial values in the board and should make it easier for clients of the library to keep track of which positions are part of the original puzzle and thus not editable by a Sudoku player.

## 2.0.0

- Added a timeout parameter to the `generateBoard` function. All the parameters of the function are now named and optional.
- Removed the artificial limit on the number of empty positions of generated puzzles with dimensions 16 or 25.

Motivated by https://github.com/raulcostajunior/fludoku/issues/1 (thanks @ahmedatef286 for reporting!)

## 1.0.0

- Initial version with full capabilities (generator lib completed)

   **Know issue**: to avoid long generation times (several minutes) the number of maximum empty positions on generated puzzles is artificially limited to 81. In practice, this affects only boards with dimensions 16 or 25.

## 0.6.0

- Initial version (without Board generation capability)
