import 'dart:async';

import 'package:chess_engine/game/utils.dart';
import 'package:chess_engine/game/piece.dart';
import 'package:chess_engine/utils/logger.dart';

class GameConsts {
  static const int itemPerRow = 8;
  static const int maxIndex = itemPerRow - 1;
}

class Game {
  List<List<Piece?>> board = List.from(initialBoard);

  Side currentSide = Side.white;

  int turnCount = 1;

  Side? winner;

  StreamController<Side?> winnerStreamCtrl = StreamController();
  StreamController<Side?> turnStreamCtrl = StreamController();

  void initialize(List<List<Piece?>>? mBoard) {
    board = List.from(mBoard ?? initialBoard);
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

  Set<Coordinate> getValidMoveCoords(
    Coordinate coordinate, {
    bool checkKingSafety = true,
  }) {
    final piece = getAtCoord(coordinate);
    if (piece == null) return {};

    final Set<Coordinate> moves = {};

    for (var moveCoord in piece.moveCoords) {
      if (piece.isMoveRay) {
        moves.addAll(_getValidRayMoves(piece, coordinate, moveCoord));
      } else {
        final newCoord = coordinate.add(moveCoord);
        if (!isCoordInsideBoard(newCoord)) {
          continue;
        }

        if (isCoordEmpty(newCoord) ||
            (isCoordOppositeSide(piece, newCoord) &&
                piece.alternateCaptureCoords.isEmpty)) {
          moves.add(newCoord);
        }
      }
    }

    for (var addCaptureCoord in piece.alternateCaptureCoords) {
      final newCoord = coordinate.add(addCaptureCoord);
      if (isCoordInsideBoard(newCoord) &&
          isCoordOppositeSide(piece, newCoord)) {
        moves.add(coordinate.add(addCaptureCoord));
      }
    }

    if (moves.isNotEmpty && checkKingSafety) {
      Logger.d('getValidMoveCoords, piece=$piece, moves=$moves');

      // TODO: add if king is attacked + piece is not king => return false
      final kingCoords = findKingCoords(currentSide);
      if (kingCoords == null) {
        // Something went wrong here
        Logger.e('Cannot find king coords for side=$currentSide');
        return {};
      }

      /// EG: After White move, calculate all the positions white can attack in the next turn
      /// Then on next turn, if Black king is in 1 of those squares, or it want to move to 1 of those squares
      /// then dissallow it, only allow 2 things:
      /// - Black King move/not move to an unattacked square
      /// - Black moves a piece, if it defends the King, then OK
      final otherSide = currentSide.getOtherSide();
      // TODO: moves to be removed, cannot remove 1 item by 1 from a Set while iterating through it
      final List<Coordinate> coordsToRemoved = [];
      for (int m = 0; m < moves.length; m++) {
        Logger.d(
            'Checking King danger if piece=$piece, targetMove=${moves.elementAt(m)}');

        final targetMoveCoord = moves.elementAt(m);

        final otherSideAttackingCoords =
            getAllAttackingMovesBySideProposedBoard(
          otherSide,
          piece,
          coordinate,
          targetMoveCoord,
        );

        if (piece is King) {
          if (otherSideAttackingCoords.contains(targetMoveCoord)) {
            Logger.d('Removing coords from possible move $targetMoveCoord');
            coordsToRemoved.add(targetMoveCoord);
          }
        } else {
          if (otherSideAttackingCoords.contains(kingCoords)) {
            Logger.d('Removing coords from possible move $targetMoveCoord');
            coordsToRemoved.add(targetMoveCoord);
          }
        }
      }

      moves.removeAll(coordsToRemoved);
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

    if (currentSide != piece.side) {
      Logger.e(
          'Invalid move, not piece turn, piece=$piece, currentTurn=$currentSide');
      return false;
    }

    if (!isCoordEmptyAndNotSameSide(piece, targetCoord)) {
      Logger.e(
          'Invalid move, not an empty square or capture, targetCoord=$targetCoord, targetPiece=${getAtCoord(targetCoord)}');
      return false;
    }

    Set<Coordinate> validMoves = getValidMoveCoords(pieceCoord);

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

    /// After a move, check if see is checkmate
    if (isCheckMate()) {
      // Notify
      Logger.d(
          '${currentSide.name.toUpperCase()} is the Winner. Congratulations! \n 🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉');
      // winner = currentSide;
      // winnerStreamCtrl.sink.add(winner);
    }

    changeTurn();
    return true;
  }

  List<Coordinate> getAllCoordsBySide(Side side) {
    final List<Coordinate> coordinates = [];
    for (int i = 0; i < GameConsts.itemPerRow; i++) {
      for (int j = 0; j < GameConsts.itemPerRow; j++) {
        final piece = getAtXy(i, j);
        if (piece != null && piece.side == side) {
          coordinates.add(Coordinate(i, j));
        }
      }
    }

    return coordinates;
  }

  bool isCheckMate() {
    final tempGame = createTempGame();
    final Set<Coordinate> allMoves = {};

    // TODO: Do a very stupid + crud check
    // TODO: check for double checks
    final coordinateList =
        tempGame.getAllCoordsBySide(currentSide.getOtherSide());

    for (var coordinate in coordinateList) {
      final piece = getAtCoord(coordinate);
      final moves = tempGame.getValidMoveCoords(
        coordinate,
        checkKingSafety: true,
      );
      if (piece is King) {
        print('========>>>>>>>> $moves');
      }
      allMoves.addAll(moves);
    }

    Logger.d(
        'Checking checkmate for ${currentSide.getOtherSide()} : possibleMovesLeft=$allMoves');
    return allMoves.isEmpty;
  }

  Game createTempGame() {
    final List<List<Piece?>> tempBoard = [];
    for (var element in board) {
      final List<Piece?> newList = [];
      for (var e in element) {
        newList.add(e);
      }

      tempBoard.add(newList);
    }

    return Game()..initialize(tempBoard);
  }

  Set<Coordinate> getAllAttackingMovesBySideProposedBoard(
    Side side,
    Piece movedPiece,
    Coordinate movedPieceCurrentCoord,
    Coordinate movedPieceNewCoord,
  ) {
    Logger.d(
        'getAllAttackingMovesBySideProposedBoard piece=$movedPiece, target=$movedPieceNewCoord ======>>>>>>>>');
    final Set<Coordinate> allMoves = {};

    // TODO: might need to refactor this
    // move generateMoveCoords out of game
    Game tempGame = createTempGame();
    tempGame.board[movedPieceCurrentCoord.x][movedPieceCurrentCoord.y] = null;
    tempGame.board[movedPieceNewCoord.x][movedPieceNewCoord.y] = movedPiece;

    visualizeBoard(tempGame.board);

    final coordinateList = tempGame.getAllCoordsBySide(side);

    for (var coordinate in coordinateList) {
      final moves = tempGame.getValidMoveCoords(
        coordinate,
        checkKingSafety: false,
      );
      allMoves.addAll(moves);
    }

    Logger.d('getAllAttackingMovesBySideProposedBoard allMoves=$allMoves');
    return allMoves;
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

  void changeTurn() {
    currentSide = currentSide.getOtherSide();
    turnStreamCtrl.sink.add(currentSide);
  }

  void visualizeBoard(List<List<Piece?>> targetBoard) {
    Logger.d('==============================================================');
    for (int i = 0; i < GameConsts.itemPerRow; i++) {
      String rowStr = '';
      for (int j = 0; j < GameConsts.itemPerRow; j++) {
        rowStr += targetBoard[i][j] == null
            ? ' x x '
            : ' ${targetBoard[i][j]!.toShortString()} ';
      }
      Logger.d(rowStr);
    }
    Logger.d('==============================================================');
  }
}
