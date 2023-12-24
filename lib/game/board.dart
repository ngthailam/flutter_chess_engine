import 'package:chess_engine/game/piece.dart';
import 'package:chess_engine/game/utils.dart';
import 'package:chess_engine/utils/logger.dart';

class BoardConsts {
  static const int itemPerRow = 8;
  static const int maxIndex = itemPerRow - 1;
}

class Board {
  List<List<Piece?>> data = List.from(initialBoard);

  Board cloneWithNewCoords(
    Coordinate? initialCoord,
    Coordinate? moveCoord,
  ) {
    List<List<Piece?>> tempData = List.generate(BoardConsts.itemPerRow,
        (index) => List.generate(BoardConsts.itemPerRow, (index) => null));

    for (int i = 0; i < BoardConsts.itemPerRow; i++) {
      for (int j = 0; j < BoardConsts.itemPerRow; j++) {
        tempData[i][j] = getAtXy(i, j);
      }
    }

    final tempBoard = Board()..data = tempData;

    if (initialCoord != null && moveCoord != null) {
      tempBoard.moveToCoord(initialCoord, moveCoord);
    }

    return tempBoard;
  }

  bool isCoordEmpty(Coordinate coordinate) => getAtCoord(coordinate) == null;

  bool isCoordSameSide(Piece piece, Coordinate coordinate) {
    return getAtCoord(coordinate)?.isSameSide(piece) == true;
  }

  bool isNotSameSide(Piece piece, Coordinate coordinate) {
    if (getAtCoord(coordinate)?.isSameSide(piece) == true) {
      return false;
    }

    return true;
  }

  bool isCoordOppositeSide(Piece piece, Coordinate coordinate) {
    final targetPieceAtCoord = getAtCoord(coordinate);
    if (targetPieceAtCoord == null) return false;
    return !targetPieceAtCoord.isSameSide(piece);
  }

  Coordinate? findKingCoords(Side side) {
    final pieces = getAllCoordsBySide(side);
    for (var coordinate in pieces) {
      if (getAtCoord(coordinate) is King) {
        return coordinate;
      }
    }

    return null;
  }

  // TODO: this can be cache, then changed on move called successfully
  List<Coordinate> getAllCoordsBySide(Side side) {
    final List<Coordinate> coordinates = [];
    for (int i = 0; i < BoardConsts.itemPerRow; i++) {
      for (int j = 0; j < BoardConsts.itemPerRow; j++) {
        final piece = getAtXy(i, j);
        if (piece != null && piece.side == side) {
          coordinates.add(Coordinate(i, j));
        }
      }
    }

    return coordinates;
  }

  bool isCoordInsideBoard(Coordinate coordinate) {
    return 0 <= coordinate.x &&
        coordinate.x <= BoardConsts.maxIndex &&
        0 <= coordinate.y &&
        coordinate.y <= BoardConsts.maxIndex;
  }

  Piece? getAtCoord(Coordinate coordinate) {
    return getAtXy(coordinate.x, coordinate.y);
  }

  Piece? getAtXy(int x, int y) {
    return data[x][y];
  }

  void moveToCoord(Coordinate coordinate, Coordinate targetCoordinate) {
    final Piece? piece = getAtCoord(coordinate);
    if (piece != null) {
      data[coordinate.x][coordinate.y] = null;
      updateCoordWithPiece(targetCoordinate, piece);
    }
  }

  void updateCoordWithPiece(Coordinate coordinate, Piece newPiece) {
    data[coordinate.x][coordinate.y] = newPiece;
  }

  void visualizeBoard() {
    Logger.d('==============================================================');
    for (int i = 0; i < BoardConsts.itemPerRow; i++) {
      String rowStr = '';
      for (int j = 0; j < BoardConsts.itemPerRow; j++) {
        rowStr +=
            data[i][j] == null ? ' x x ' : ' ${data[i][j]!.toShortString()} ';
      }
      Logger.d(rowStr);
    }
    Logger.d('==============================================================');
  }
}
