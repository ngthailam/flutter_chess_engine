import 'package:chess_engine/game/utils.dart';

class Constants {
  static const int searchDepth = 3;
  static const int cacheAfterXMove = 5;
  static const int itemPerRow = 8;
  static const int maxIndex = itemPerRow - 1;
  static const Coordinate whiteRightCastle = Coordinate(6, 0);
  static const Coordinate whiteLeftCastle = Coordinate(2, 0);
  static const Coordinate blackRightCastle = Coordinate(6, 7);
  static const Coordinate blackLeftCastle = Coordinate(2, 7);

  static const List<Coordinate> castleMoves = [
    whiteRightCastle,
    whiteLeftCastle,
    blackRightCastle,
    blackLeftCastle,
  ];
}

typedef BoardIdentifier = String;

typedef PieceIdentifier = String;

enum GameResult {
  whiteWin,
  blackWin,
  draw;
}
