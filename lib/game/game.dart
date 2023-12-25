import 'dart:async';

import 'package:chess_engine/game/board.dart';
import 'package:chess_engine/game/constants.dart';
import 'package:chess_engine/game/move_generator.dart';
import 'package:chess_engine/game/move_generator_cache.dart';
import 'package:chess_engine/game/piece.dart';
import 'package:chess_engine/game/utils.dart';
import 'package:chess_engine/utils/logger.dart';

class Game {
  Board board = Board();

  MoveGenerator moveGenerator = MoveGenerator();

  Side currentSide = Side.white;

  int turnCount = 1;

  Side? winner;

  // This is very temporary, we need IDs for individual pieces
  final Map<PieceIdentifier, bool> moveMap = {};

  StreamController<Side?> winnerStreamCtrl = StreamController();
  StreamController<Side?> turnStreamCtrl = StreamController();

  Set<Coordinate> getValidMoveCoords(
    Coordinate coordinate, {
    bool checkKingSafety = true,
  }) {
    return moveGenerator.getValidMoveCoords(
      board,
      coordinate,
      currentSide,
      checkKingSafety: checkKingSafety,
    );
  }

  bool move(
    Coordinate pieceCoord,
    Coordinate targetCoord, {
    Set<Coordinate>? validMoves,
  }) {
    Piece? piece = board.getAtCoord(pieceCoord);
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

    if (board.isCoordSameSide(piece, targetCoord)) {
      Logger.e(
          'Invalid move, coord occupied by same side piece, targetCoord=$targetCoord}');
      return false;
    }

    if (validMoves != null) {
      if (!validMoves.contains(targetCoord)) {
        Logger.e(
            'Invalid move set, targetCoord=$targetCoord, validMoves=$validMoves}');
        return false;
      }
    }

    // Handle promotion
    // Check if reached the final place, then do shits here
    if (piece is Pawn) {
      // TODO: for now, automatically promote to queen
      if (piece.isWhite() && targetCoord.y == Constants.maxIndex) {
        piece = Queen(
          side: Side.white,
          identifier: DateTime.now().millisecondsSinceEpoch.toString(),
        );
        board.updateCoordWithPiece(pieceCoord, piece);
      } else if (!piece.isWhite() && targetCoord.y == 0) {
        piece = Queen(
          side: Side.black,
          identifier: DateTime.now().millisecondsSinceEpoch.toString(),
        );
        board.updateCoordWithPiece(pieceCoord, piece);
      }
    }

    //
    board.moveToCoord(pieceCoord, targetCoord);
    moveMap[piece.identifier] = true;
    turnCount += 1;
    _lastMove = [pieceCoord, targetCoord];

    /// After a move, check if see is checkmate
    if (_needToCheckForCheckmate() && isCheckMate(pieceCoord, targetCoord)) {
      // Notify
      Logger.d(
          '${currentSide.name.toUpperCase()} is the Winner. Congratulations! \n 🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉');
      winner = currentSide;
      winnerStreamCtrl.sink.add(winner);
    }

    MoveGeneratorCache().onPieceMoved();
    turnCount += 1;
    changeTurn();

    return true;
  }

  // To reduce checkmate checks when unnesccary
  // Moto: Remove move generations whenever possible
  bool _needToCheckForCheckmate() {
    return turnCount > 2;
  }

  // TODO: is there a better way to find checkmate ?
  List<Coordinate> _lastMove = [];

  void undo() {
    winner = null;
    currentSide = currentSide.getOtherSide();
    turnCount -= 1;
    _lastMove = [];
    move(_lastMove[1], _lastMove[0]);
  }

  bool isCheckMate(
    Coordinate initialCoord,
    Coordinate moveCoord,
  ) {
    // Coords is already moved in move() function
    final tempBoard = board.cloneWithNewCoords(null, null);
    final Set<Coordinate> allMoves = {};
    final Side sideToGeneratePossibleMove = currentSide.getOtherSide();

    // Eg. After WHITE move, calls isCheckMate
    // Get all BLACK pieces, then try to generate their possible moves (while checking for Black king safety)
    // If they have 0 moves left => WHITE checkmates BLACK
    final coordinateList =
        tempBoard.getAllPiecesCoordsBySide(sideToGeneratePossibleMove);

    for (var coordinate in coordinateList) {
      final moves = moveGenerator.getValidMoveCoords(
        tempBoard,
        coordinate,
        sideToGeneratePossibleMove,
        checkKingSafety: true,
      );
      allMoves.addAll(moves);
    }

    Logger.d(
        'Checking checkmate for $sideToGeneratePossibleMove : possibleMovesLeft=$allMoves');
    return allMoves.isEmpty;
  }

  void changeTurn() {
    currentSide = currentSide.getOtherSide();
    turnStreamCtrl.sink.add(currentSide);
  }
}
