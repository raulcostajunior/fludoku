## 2.0.0

- Added a timeout parameter to the `generateBoard` function. All the parameters of the function are now named and optional.
- Removed the artificial limit on the number of empty positions of generated puzzles with dimensions 16 or 25.

Motivated by https://github.com/raulcostajunior/fludoku/issues/1 (thanks @ahmedatef286 for reporting!)

## 1.0.0

- Initial version with full capabilities (generator lib completed)

   **Know issue**: to avoid long generation times (several minutes) the number of maximum empty positions on generated puzzles is artificially limited to 81. In practice, this affects only boards with dimensions 16 or 25.

## 0.6.0

- Initial version (without Board generation capability)
