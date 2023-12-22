import 'dart:async';

import 'package:chess_engine/game/board.dart';
import 'package:chess_engine/game/move_generator.dart';
import 'package:chess_engine/game/piece.dart';
import 'package:chess_engine/game/utils.dart';
import 'package:chess_engine/utils/logger.dart';

class Game {
  Board board = Board();

  MoveGenerator moveGenerator = MoveGenerator();

  Side currentSide = Side.white;

  int turnCount = 1;

  Side? winner;

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
      isFirstMove: moveMap[board.getAtCoord(coordinate)] == null,
    );
  }

  final Map<Piece, bool> moveMap = {};

  bool move(Coordinate pieceCoord, Coordinate targetCoord) {
    final piece = board.getAtCoord(pieceCoord);
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

    // !isCoordEmptyAndNotSameSide(piece, targetCoord)
    if (board.isCoordSameSide(piece, targetCoord)) {
      Logger.e(
          'Invalid move, coord occupied by same side piece, targetCoord=$targetCoord}');
      return false;
    }

    Set<Coordinate> validMoves = getValidMoveCoords(pieceCoord);

    if (!validMoves.contains(targetCoord)) {
      Logger.e(
          'Invalid move set, targetCoord=$targetCoord, validMoves=$validMoves}');
      return false;
    }

    board.moveToCoord(pieceCoord, targetCoord);
    moveMap[piece] = true;
    turnCount += 1;

    /// After a move, check if see is checkmate
    if (isCheckMate(pieceCoord, targetCoord)) {
      // Notify
      Logger.d(
          '${currentSide.name.toUpperCase()} is the Winner. Congratulations! \n 🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉');
      winner = currentSide;
      winnerStreamCtrl.sink.add(winner);
    }

    changeTurn();
    return true;
  }

  bool isCheckMate(
    Coordinate initialCoord,
    Coordinate moveCoord,
  ) {
    final tempBoard = board.cloneWithNewCoords(initialCoord, moveCoord);
    final Set<Coordinate> allMoves = {};

    // TODO: Do a very stupid + crud check
    // TODO: check for double checks
    final coordinateList =
        tempBoard.getAllCoordsBySide(currentSide.getOtherSide());

    for (var coordinate in coordinateList) {
      final moves = moveGenerator.getValidMoveCoords(
        tempBoard,
        coordinate,
        currentSide,
        checkKingSafety: true,
      );
      allMoves.addAll(moves);
    }

    Logger.d(
        'Checking checkmate for ${currentSide.getOtherSide()} : possibleMovesLeft=$allMoves');
    return allMoves.isEmpty;
  }

  void changeTurn() {
    currentSide = currentSide.getOtherSide();
    turnStreamCtrl.sink.add(currentSide);
  }
}
