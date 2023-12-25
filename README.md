# chess_engine

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## TODO:
- Add enpassant
- Add move repetition
- Optimize where can
    + Cache board state for minimax ?
- Test for multiple check scenario

## Improvements:

- Try a different way to hash the Board (currently use string combination, which is costly)

https://en.wikipedia.org/wiki/Transposition_table
- Transposition table

https://www.chessprogramming.org/Late_Move_Reductions
https://www.chessprogramming.org/Principal_Variation_Search
- Research NegaScout(Principal Variation Search) as an alternative for Minimax search



/// TODO: Fully refactor ?????????