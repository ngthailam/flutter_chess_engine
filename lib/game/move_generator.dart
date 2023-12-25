import 'package:chess_engine/game/board.dart';
import 'package:chess_engine/game/constants.dart';
import 'package:chess_engine/game/move_generator_cache.dart';
import 'package:chess_engine/game/piece.dart';
import 'package:chess_engine/game/shared_data.dart';
import 'package:chess_engine/game/utils.dart';
import 'package:chess_engine/utils/logger.dart';

class MoveGenerator {
  final cache = MoveGeneratorCache();

  List<Coordinate> _getValidRayMoves(
    Board board,
    Piece piece,
    Coordinate coordinate,
    Coordinate moveCoord,
    int extendIndex,
  ) {
    List<Coordinate> moves = [];
    for (int k = 1; k <= extendIndex; k++) {
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

  // 0:00:00.001444 - total time 700 - totalTimeSeconds: 0.7
  // 0:00:00.004108 - total time 439 - totalTimeSeconds: 0.439
  // int totalTime = 0;
  // int cacheHitCount = 0;
  // int cacheMissCount = 0;
  Set<Coordinate> getValidMoveCoords(
    Board board,
    Coordinate pieceCoordinate,
    Side currentSide, {
    bool checkKingSafety = true,
  }) {
    // final watch = Stopwatch()..start();
    final piece = board.getAtCoord(pieceCoordinate);
    if (piece == null) return {};

    /// Start - Check for cache
    final cacheValidMoves = cache.get(
      boardIdentifier: board.identifier(),
      pieceIdentifier: piece.identifier,
    );

    if (cacheValidMoves != null) {
      // cacheHitCount += 1;
      // print(
      //     'zzll cachehit ${board.identifier()} - ${piece.identifier}, totalCacheHit= $cacheHitCount');
      // totalTime += watch.elapsedMilliseconds;
      // print(
      //     'zzll elapsed = ${watch.elapsed} - total time ${totalTime} - totalTimeSeconds: ${totalTime / 1000}');
      // watch.stop();
      return cacheValidMoves;
    }

    /// End - Check for cache

    final Set<Coordinate> moves = {};

    // TODO: this is not very good, piece can return to their original places
    final isFirstMove = SharedData.isFirstMove(piece.identifier);
    for (var moveCoord in piece.moveCoords) {
      if (piece.moveCoordsMultiplier(isFirstMove) > 1) {
        moves.addAll(
          _getValidRayMoves(
            board,
            piece,
            pieceCoordinate,
            moveCoord,
            piece.moveCoordsMultiplier(isFirstMove),
          ),
        );
      } else {
        final newCoord = pieceCoordinate.add(moveCoord);
        if (!board.isCoordInsideBoard(newCoord)) {
          continue;
        }

        if (board.isCoordEmpty(newCoord) ||
            (board.isCoordOppositeSide(piece, newCoord) &&
                piece.captureCoords.isEmpty)) {
          moves.add(newCoord);
        }
      }
    }

    // Add catsle-ing , very hard cody, try refactoring if possible
    if (piece is King && SharedData.isFirstMove(piece.identifier)) {
      if (piece.isWhite) {
        final rightRook = board.getAtXy(7, 0);
        if (board.getAtXy(6, 0) == null &&
            board.getAtXy(5, 0) == null &&
            rightRook is Rook &&
            SharedData.isFirstMove(rightRook.identifier)) {
          moves.add(Constants.whiteRightCastle);
        }

        final leftRook = board.getAtXy(0, 0);
        if (board.getAtXy(1, 0) == null &&
            board.getAtXy(2, 0) == null &&
            leftRook is Rook &&
            SharedData.isFirstMove(leftRook.identifier)) {
          moves.add(Constants.whiteLeftCastle);
        }
      } else {
        final rightRook = board.getAtXy(7, 7);
        if (board.getAtXy(6, 7) == null &&
            board.getAtXy(5, 7) == null &&
            rightRook is Rook &&
            SharedData.isFirstMove(rightRook.identifier)) {
          moves.add(Constants.blackRightCastle);
        }

        final leftRook = board.getAtXy(0, 7);
        if (board.getAtXy(1, 7) == null &&
            board.getAtXy(2, 7) == null &&
            leftRook is Rook &&
            SharedData.isFirstMove(leftRook.identifier)) {
          moves.add(Constants.blackLeftCastle);
        }
      }
    }

    for (var addCaptureCoord in piece.captureCoords) {
      final newCoord = pieceCoordinate.add(addCaptureCoord);
      if (board.isCoordInsideBoard(newCoord) &&
          board.isCoordOppositeSide(piece, newCoord)) {
        moves.add(pieceCoordinate.add(addCaptureCoord));
      }
    }

    // Try to optimize, since this check safety operation is very costly
    // so try to minimize the number of times this needs to be called.
    const needToCheckKingSafety = true;
    if (moves.isNotEmpty && checkKingSafety && needToCheckKingSafety) {
      Logger.d('getValidMoveCoords, piece=$piece, moves=$moves');

      final kingCoords = board.getKingCoords(currentSide);
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
      final List<Coordinate> coordsToRemoved = [];
      for (int m = 0; m < moves.length; m++) {
        Logger.d(
            'Checking King danger if piece=$piece, targetMove=${moves.elementAt(m)}');

        final targetMoveCoord = moves.elementAt(m);

        final otherSideAttackingCoords = getAllAttackingMovesBySideInBoard(
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

    cache.save(
      boardIdentifier: board.identifier(),
      pieceIdentifier: piece.identifier,
      moves: moves,
    );

    // cacheMissCount += 1;
    // totalTime += watch.elapsedMilliseconds;
    // print(
    //     'zzll cacheMiss count=$cacheMissCount, elapsed = ${watch.elapsed} - total time ${totalTime} - totalTimeSeconds: ${totalTime / 1000}');
    // watch.stop();
    return moves;
  }

  Set<Coordinate> getAllAttackingMovesBySideInBoard(
    Board board,
    Side side,
    Piece? movedPiece,
    Coordinate? movedPieceCurrentCoord,
    Coordinate? movedPieceNewCoord,
  ) {
    Logger.d(
        'getAllAttackingMovesBySideProposedBoard piece=$movedPiece, target=$movedPieceNewCoord ======>>>>>>>>');
    final Set<Coordinate> allMoves = {};

    Board tempBoard = board.cloneWithNewCoords(
      movedPieceCurrentCoord,
      movedPieceNewCoord,
    );

    final coordinateList = tempBoard.getAllPiecesCoordsBySide(side);
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
    Board board,
    Side side,
  ) {
    final List<BoardAndMoveSet> possibleBoards = [];

    board.getAllPiecesCoordsBySide(side).forEach((pieceCoord) {
      final allPiecePossibleMoveCoordList = getValidMoveCoords(
        board,
        pieceCoord,
        side,
        checkKingSafety: true,
      );
      for (var possibleMoveCoord in allPiecePossibleMoveCoordList) {
        final boardAndMoveSet = BoardAndMoveSet(
          board: board.cloneWithNewCoords(pieceCoord, possibleMoveCoord),
          pieceCoord: pieceCoord,
          targetPieceCoord: possibleMoveCoord,
        );
        possibleBoards.add(boardAndMoveSet);
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

  BoardAndMoveSet copyWith({
    Board? board,
    Coordinate? pieceCoord,
    Coordinate? targetPieceCoord,
  }) =>
      BoardAndMoveSet(
        board: board ?? this.board,
        pieceCoord: pieceCoord ?? this.pieceCoord,
        targetPieceCoord: targetPieceCoord ?? this.targetPieceCoord,
      );
}
