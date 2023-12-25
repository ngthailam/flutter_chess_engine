import 'package:chess_engine/game/constants.dart';

class SharedData {
  static final Map<PieceIdentifier, bool> moveMap = {};

  static bool isFirstMove(PieceIdentifier pieceIdentifier) {
    return moveMap[pieceIdentifier] != true;
  }

  static void setMoved(PieceIdentifier pieceIdentifier) {
    if (moveMap[pieceIdentifier] == null) {
      moveMap[pieceIdentifier] = true;
    }
  }

  static void remove(PieceIdentifier pieceIdentifier) {
    moveMap.remove(pieceIdentifier);
  }

  static void reset() {
    //
  }
}
