/// Generates and solves Sudoku puzzles with dimensions 4, 9 (default), 16, or 25.
library;

export 'src/board.dart' show Board;
export 'src/generator.dart'
    show generateSudokuPuzzle, GeneratorProgress, PuzzleDifficulty;
export 'src/solver.dart' show findSolutions, FindSolutionsProgress;
