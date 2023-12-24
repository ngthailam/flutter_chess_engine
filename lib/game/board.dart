import 'package:chess_engine/game/constants.dart';
import 'package:chess_engine/game/piece.dart';
import 'package:chess_engine/game/utils.dart';
import 'package:chess_engine/utils/logger.dart';

class Board {
  List<List<Piece?>> data = List.from(initialBoard, growable: false);

  BoardIdentifier identifier() {
    String result = '';
    for (int i = 0; i < Constants.itemPerRow; i++) {
      for (int j = 0; j < Constants.itemPerRow; j++) {
        result += data[i][j]?.identifier ?? 'null';
      }
    }

    return result;
  }

  Board cloneWithNewCoords(
    Coordinate? initialCoord,
    Coordinate? moveCoord,
  ) {
    List<List<Piece?>> tempData = List.generate(Constants.itemPerRow,
        (index) => List.generate(Constants.itemPerRow, (index) => null));

    for (int i = 0; i < Constants.itemPerRow; i++) {
      for (int j = 0; j < Constants.itemPerRow; j++) {
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

  bool isCoordNotSameSide(Piece piece, Coordinate coordinate) {
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

  Coordinate? getKingCoords(Side side) {
    final pieces = getAllPiecesCoordsBySide(side);
    for (var coordinate in pieces) {
      if (getAtCoord(coordinate) is King) {
        return coordinate;
      }
    }

    return null;
  }

  // TODO: this can be cache, then changed on move called successfully
  List<Coordinate> getAllPiecesCoordsBySide(Side side) {
    final List<Coordinate> coordinates = [];
    for (int i = 0; i < Constants.itemPerRow; i++) {
      for (int j = 0; j < Constants.itemPerRow; j++) {
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
        coordinate.x <= Constants.maxIndex &&
        0 <= coordinate.y &&
        coordinate.y <= Constants.maxIndex;
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
    for (int i = 0; i < Constants.itemPerRow; i++) {
      String rowStr = '';
      for (int j = 0; j < Constants.itemPerRow; j++) {
        rowStr +=
            data[i][j] == null ? ' x x ' : ' ${data[i][j]!.toShortString()} ';
      }
      Logger.d(rowStr);
    }
    Logger.d('==============================================================');
  }
}
