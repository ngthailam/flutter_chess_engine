import 'package:chess_engine/engine/evaluator.dart';
import 'package:chess_engine/game/board.dart';
import 'package:chess_engine/game/move_generator.dart';
import 'package:chess_engine/game/utils.dart';

class MiniMaxOutput {
  final BoardAndMoveSet boardAndMoveSet;
  final double evaluation;

  MiniMaxOutput({required this.boardAndMoveSet, required this.evaluation});

  MiniMaxOutput copyWith({
    BoardAndMoveSet? boardAndMoveSet,
    double? evaluation,
  }) =>
      MiniMaxOutput(
        boardAndMoveSet: boardAndMoveSet ?? this.boardAndMoveSet,
        evaluation: evaluation ?? this.evaluation,
      );

  MiniMaxOutput copyWithCoord({
    required Coordinate coordinate,
    required Coordinate targetCoordinate,
  }) =>
      MiniMaxOutput(
        boardAndMoveSet: boardAndMoveSet.copyWith(
          pieceCoord: coordinate,
          targetPieceCoord: targetCoordinate,
        ),
        evaluation: evaluation,
      );
}

class MiniMax {
  MoveGenerator moveGenerator = MoveGenerator();

  MiniMaxOutput run(
    Board board,
    int depth,
    MiniMaxOutput? alpha,
    MiniMaxOutput? beta,
    bool maximizingSide,
  ) {
    if (depth == 0) {
      return MiniMaxOutput(
        evaluation: Evaluator.evaluate(board),
        boardAndMoveSet: BoardAndMoveSet(
          board: board,
          pieceCoord: const Coordinate(0, 0),
          targetPieceCoord: const Coordinate(0, 0),
        ),
      );
    }

    if (maximizingSide) {
      MiniMaxOutput maxOutput = MiniMaxOutput(
        boardAndMoveSet: BoardAndMoveSet(
          board: board,
          pieceCoord: const Coordinate(0, 0),
          targetPieceCoord: const Coordinate(0, 0),
        ),
        evaluation: -9999,
      );
      MiniMaxOutput output = MiniMaxOutput(
        boardAndMoveSet: BoardAndMoveSet(
          board: board,
          pieceCoord: const Coordinate(0, 0),
          targetPieceCoord: const Coordinate(0, 0),
        ),
        evaluation: 0,
      );
      List<BoardAndMoveSet> possibleBoards =
          moveGenerator.getAllPossibleBoardPositionBySide(board, Side.white);

      for (var element in possibleBoards) {
        output =
            run(element.board, depth - 1, alpha, beta, false).copyWithCoord(
          coordinate: element.pieceCoord,
          targetCoordinate: element.targetPieceCoord,
        );
        if (maxOutput.evaluation < output.evaluation) {
          maxOutput = output;
        }

        MiniMaxOutput? tempAlpha;

        if (alpha?.evaluation == null) {
          tempAlpha = output;
        } else {
          tempAlpha = output.evaluation > alpha!.evaluation ? output : alpha;
        }

        if (beta != null) {
          if (beta.evaluation <= tempAlpha.evaluation) {
            break;
          }
        }
      }
      return maxOutput;
    } else {
      MiniMaxOutput minOutput = MiniMaxOutput(
        boardAndMoveSet: BoardAndMoveSet(
          board: board,
          pieceCoord: const Coordinate(0, 0),
          targetPieceCoord: const Coordinate(0, 0),
        ),
        evaluation: 9999,
      );
      MiniMaxOutput output = MiniMaxOutput(
        boardAndMoveSet: BoardAndMoveSet(
          board: board,
          pieceCoord: const Coordinate(0, 0),
          targetPieceCoord: const Coordinate(0, 0),
        ),
        evaluation: 0,
      );
      List<BoardAndMoveSet> possibleBoards =
          moveGenerator.getAllPossibleBoardPositionBySide(board, Side.black);

      for (BoardAndMoveSet element in possibleBoards) {
        output = run(element.board, depth - 1, alpha, beta, true).copyWithCoord(
          coordinate: element.pieceCoord,
          targetCoordinate: element.targetPieceCoord,
        );

        if (minOutput.evaluation > output.evaluation) {
          minOutput = output;
        }

        if (beta == null || beta.evaluation > minOutput.evaluation) {
          beta = minOutput;
        }

        MiniMaxOutput? tempBeta =
            beta.evaluation > minOutput.evaluation ? minOutput : beta;

        if (alpha != null) {
          if (tempBeta.evaluation <= alpha.evaluation) {
            break;
          }
        }
      }

      return minOutput;
    }
  }
}
