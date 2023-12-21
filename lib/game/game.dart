import 'package:chess_engine/game/utils.dart';
import 'package:chess_engine/game/piece.dart';
import 'package:chess_engine/utils/logger.dart';

class GameConsts {
  static const int itemPerRow = 8;
  static const int maxIndex = itemPerRow - 1;
}

class Game {
  List<List<Piece?>> board = List.from(initialBoard);

  Side currentTurn = Side.white;

  int turnCount = 1;

  Set<Coordinate> _attackingCoords = Set();

  void initialize() {
    board = List.from(initialBoard);
  }

  List<Coordinate> _getValidRayMoves(
    Piece piece,
    Coordinate coordinate,
    Coordinate moveCoord,
  ) {
    List<Coordinate> moves = [];
    for (int k = 1; k < GameConsts.itemPerRow; k++) {
      final newCoord = coordinate.add(moveCoord, multiplier: k);
      if (isCoordInsideBoard(newCoord)) {
        final targetPiece = getAtCoord(newCoord);

        if (targetPiece == null || piece.side != targetPiece.side) {
          moves.add(newCoord);
        }

        if (targetPiece != null) {
          break;
        }
      } else {
        break;
      }
    }

    return moves;
  }

  List<Coordinate> getValidMoves(Coordinate coordinate) {
    final piece = getAtCoord(coordinate);
    if (piece == null) return [];

    final List<Coordinate> moves = [];

    for (var moveCoord in piece.moveCoordinates) {
      if (piece.isMoveRay) {
        moves.addAll(_getValidRayMoves(piece, coordinate, moveCoord));
      } else {
        final newCoord = coordinate.add(moveCoord);
        if (isCoordInsideBoard(newCoord) &&
            isCoordEmptyAndNotSameSide(piece, newCoord)) {
          moves.add(newCoord);
        }
      }
    }

    for (var addCaptureCoord in piece.additionalCaptureCoordinates) {
      final newCoord = coordinate.add(addCaptureCoord);
      if (isCoordInsideBoard(newCoord) &&
          isCoordOppositeSide(piece, newCoord)) {
        moves.add(coordinate.add(addCaptureCoord));
      }
    }

    return moves;
  }

  bool isCoordOppositeSide(Piece piece, Coordinate coordinate) {
    final targetPieceAtCoord = getAtCoord(coordinate);
    if (targetPieceAtCoord == null) return false;
    return !targetPieceAtCoord.isSameSide(piece);
  }

  bool isCoordEmpty(Coordinate coordinate) => getAtCoord(coordinate) == null;

  // TODO: will have to expand on this
  bool isCoordEmptyAndNotSameSide(Piece piece, Coordinate coordinate) {
    final targetPieceAtCoord = getAtCoord(coordinate);
    if (targetPieceAtCoord?.isSameSide(piece) == true) {
      return false;
    }

    return true;
  }

  bool isCoordInsideBoard(Coordinate coordinate) {
    return 0 <= coordinate.x &&
        coordinate.x <= GameConsts.maxIndex &&
        0 <= coordinate.y &&
        coordinate.y <= GameConsts.maxIndex;
  }

  List<int> getAttackingPositions(Side side) {
    return [];
  }

  Piece? getAtCoord(Coordinate coordinate) {
    return getAtXy(coordinate.x, coordinate.y);
  }

  Piece? getAtXy(int x, int y) {
    return board[x][y];
  }

  bool move(Coordinate pieceCoord, Coordinate targetCoord) {
    final piece = getAtCoord(pieceCoord);
    Logger.d(
        'Move, pieceCoord=$pieceCoord, piece=$piece, targetCoord=$targetCoord');

    if (piece == null) {
      // Show error invalid move here
      Logger.e(
          'Invalid move, no piece at pieceCoord, pieceCoord=$pieceCoord, targetCoord=$targetCoord');
      return false;
    }

    if (currentTurn != piece.side) {
      Logger.e(
          'Invalid move, not piece turn, piece=$piece, currentTurn=$currentTurn');
      return false;
    }

    if (!isCoordEmptyAndNotSameSide(piece, targetCoord)) {
      Logger.e(
          'Invalid move, not an empty square or capture, targetCoord=$targetCoord, targetPiece=${getAtCoord(targetCoord)}');
      return false;
    }

    // TODO: add if king is attacked + piece is not king => return false
    final kingCoords = findKingCoords(currentTurn);
    if (kingCoords == null) {
      // Something went wrong here
      Logger.e('Cannot find king coords for side=$currentTurn');
      return false;
    }
    if (_attackingCoords.contains(kingCoords)) {
      // King is being attacked:
      // Check if after any move move, king is still in _attackingCoords, then returns false
    }

    List<Coordinate> validMoves = getValidMoves(pieceCoord);
    if (!validMoves.contains(targetCoord)) {
      Logger.e(
          'Invalid move set, targetCoord=$targetCoord, validMoves=$validMoves}');
      return false;
    }

    // TODO: add pins
    // TODO: add other things
    board[pieceCoord.x][pieceCoord.y] = null;
    board[targetCoord.x][targetCoord.y] = piece..isMoved = true;
    turnCount += 1;

    /// EG: After White move, calculate all the positions white can attack in the next turn
    /// Then on next turn, if Black king is in 1 of those squares, or it want to move to 1 of those squares
    /// then dissallow it, only allow 2 things:
    /// - Black King move/not move to an unattacked square
    /// - Black moves a piece, if it defends the King, then OK
    _setThisSidePossibleMovesForNextTurn();

    changeTurn();
    return true;
  }

  void _setThisSidePossibleMovesForNextTurn() {
    _attackingCoords.clear();

    for (int i = 0; i < GameConsts.itemPerRow; i++) {
      for (int j = 0; j < GameConsts.itemPerRow; j++) {
        final piece = getAtXy(i, j);
        if (piece?.side == currentTurn) {
          final moves = getValidMoves(Coordinate(i, j));
          _attackingCoords.addAll(moves);
        }
      }
    }
  }

  Coordinate? findKingCoords(Side side) {
    for (int i = 0; i < GameConsts.itemPerRow; i++) {
      for (int j = 0; j < GameConsts.itemPerRow; j++) {
        final piece = getAtXy(i, j);
        if (piece is King && piece.side == side) {
          return Coordinate(i, j);
        }
      }
    }

    return null;
  }

  void changeTurn() {
    currentTurn = currentTurn == Side.white ? Side.black : Side.white;
  }

  void test() {
    print(board);
  }
}
