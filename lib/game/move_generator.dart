import 'package:chess_engine/game/board.dart';
import 'package:chess_engine/game/piece.dart';
import 'package:chess_engine/game/utils.dart';
import 'package:chess_engine/utils/logger.dart';

class MoveGenerator {
  List<Coordinate> _getValidRayMoves(
    Board board,
    Piece piece,
    Coordinate coordinate,
    Coordinate moveCoord,
  ) {
    List<Coordinate> moves = [];
    for (int k = 1; k < BoardConsts.itemPerRow; k++) {
      final newCoord = coordinate.add(moveCoord, multiplier: k);
      if (board.isCoordInsideBoard(newCoord)) {
        final targetPiece = board.getAtCoord(newCoord);

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
    Board board,
    Coordinate pieceCoordinate,
    Side currentSide, {
    bool checkKingSafety = true,
    bool isFirstMove = false,
  }) {
    final piece = board.getAtCoord(pieceCoordinate);
    if (piece == null) return {};

    final Set<Coordinate> moves = {};

    for (var moveCoord in (isFirstMove ? piece.firstMoveCoords : piece.moveCoords)) {
      if (piece.isMoveRay) {
        moves.addAll(
            _getValidRayMoves(board, piece, pieceCoordinate, moveCoord));
      } else {
        final newCoord = pieceCoordinate.add(moveCoord);
        if (!board.isCoordInsideBoard(newCoord)) {
          continue;
        }

        if (board.isCoordEmpty(newCoord) ||
            (board.isCoordOppositeSide(piece, newCoord) &&
                piece.alternateCaptureCoords.isEmpty)) {
          moves.add(newCoord);
        }
      }
    }

    for (var addCaptureCoord in piece.alternateCaptureCoords) {
      final newCoord = pieceCoordinate.add(addCaptureCoord);
      if (board.isCoordInsideBoard(newCoord) &&
          board.isCoordOppositeSide(piece, newCoord)) {
        moves.add(pieceCoordinate.add(addCaptureCoord));
      }
    }

    if (moves.isNotEmpty && checkKingSafety) {
      Logger.d('getValidMoveCoords, piece=$piece, moves=$moves');

      final kingCoords = board.findKingCoords(currentSide);
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
          board,
          otherSide,
          piece,
          pieceCoordinate,
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

  Set<Coordinate> getAllAttackingMovesBySideProposedBoard(
    Board board,
    Side side,
    Piece? movedPiece,
    Coordinate? movedPieceCurrentCoord,
    Coordinate? movedPieceNewCoord,
  ) {
    Logger.d(
        'getAllAttackingMovesBySideProposedBoard piece=$movedPiece, target=$movedPieceNewCoord ======>>>>>>>>');
    final Set<Coordinate> allMoves = {};

    // TODO: might need to refactor this
    // move generateMoveCoords out of game
    Board tempBoard =
        board.cloneWithNewCoords(movedPieceCurrentCoord, movedPieceNewCoord);

    tempBoard.visualizeBoard();

    final coordinateList = tempBoard.getAllCoordsBySide(side);

    for (var coordinate in coordinateList) {
      final moves = getValidMoveCoords(
        tempBoard,
        coordinate,
        side,
        checkKingSafety: false,
      );
      allMoves.addAll(moves);
    }

    Logger.d('getAllAttackingMovesBySideProposedBoard allMoves=$allMoves');
    return allMoves;
  }

  List<BoardAndMoveSet> getAllPossibleBoardPositionBySide(
      Board board, Side side) {
    final List<BoardAndMoveSet> possibleBoards = [];

    board.getAllCoordsBySide(side).forEach((pieceCoord) {
      final allPiecePossibleMoveCoordList =
          getValidMoveCoords(board, pieceCoord, side, checkKingSafety: true);
      for (var possibleMoveCoord in allPiecePossibleMoveCoordList) {
        possibleBoards.add(
          BoardAndMoveSet(
            board: board.cloneWithNewCoords(pieceCoord, possibleMoveCoord),
            pieceCoord: pieceCoord,
            targetPieceCoord: possibleMoveCoord,
          ),
        );
      }
    });

    return possibleBoards;
  }
}

class BoardAndMoveSet {
  final Board board;
  final Coordinate pieceCoord;
  final Coordinate targetPieceCoord;

  BoardAndMoveSet({
    required this.board,
    required this.pieceCoord,
    required this.targetPieceCoord,
  });
}
