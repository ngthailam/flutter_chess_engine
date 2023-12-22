import 'dart:math';

import 'package:chess_engine/engine/evaluator.dart';
import 'package:chess_engine/game/board.dart';
import 'package:chess_engine/game/move_generator.dart';
import 'package:chess_engine/game/utils.dart';

class MiniMaxOutput {
  final BoardAndMoveSet boardAndMoveSet;
  final int evaluation;

  MiniMaxOutput({required this.boardAndMoveSet, required this.evaluation});
}

class MiniMax {
  MoveGenerator moveGenerator = MoveGenerator();

  MiniMaxOutput run(
    Board board,
    int depth,
    MiniMaxOutput alpha,
    MiniMaxOutput beta,
    bool maximizingSide,
  ) {
    if (depth == 0) {
      return MiniMaxOutput(
        evaluation: Evaluator.evaluate(board),
        boardAndMoveSet: BoardAndMoveSet(
          board: board,
          pieceCoord: Coordinate(0, 0),
          targetPieceCoord: Coordinate(0, 0),
        ),
      );
    }

    if (maximizingSide) {
      MiniMaxOutput maxOutput = MiniMaxOutput(
        boardAndMoveSet: BoardAndMoveSet(
          board: board,
          pieceCoord: Coordinate(0, 0),
          targetPieceCoord: Coordinate(0, 0),
        ),
        evaluation: -9999,
      );
      MiniMaxOutput output = MiniMaxOutput(
        boardAndMoveSet: BoardAndMoveSet(
          board: board,
          pieceCoord: Coordinate(0, 0),
          targetPieceCoord: Coordinate(0, 0),
        ),
        evaluation: 0,
      );
      List<BoardAndMoveSet> possibleBoards =
          moveGenerator.getAllPossibleBoardPositionBySide(board, Side.white);

      for (var element in possibleBoards) {
        output = run(element.board, depth - 1, alpha, beta, false);
        if (maxOutput.evaluation < output.evaluation) {
          maxOutput = output;
        }
        MiniMaxOutput? tempAlpha =
            output.evaluation > alpha.evaluation ? output : alpha;

        if (beta.evaluation <= tempAlpha.evaluation) {
          break;
        }
      }
      return maxOutput;
    } else {
      MiniMaxOutput minOutput = MiniMaxOutput(
        boardAndMoveSet: BoardAndMoveSet(
          board: board,
          pieceCoord: Coordinate(0, 0),
          targetPieceCoord: Coordinate(0, 0),
        ),
        evaluation: 9999,
      );
      MiniMaxOutput output = MiniMaxOutput(
        boardAndMoveSet: BoardAndMoveSet(
          board: board,
          pieceCoord: Coordinate(0, 0),
          targetPieceCoord: Coordinate(0, 0),
        ),
        evaluation: 0,
      );
      List<BoardAndMoveSet> possibleBoards =
          moveGenerator.getAllPossibleBoardPositionBySide(board, Side.black);

      for (var element in possibleBoards) {
        output = run(element.board, depth - 1, alpha, beta, true);
        if (minOutput.evaluation > output.evaluation) {
          minOutput = output;
        }
        if (beta.evaluation > minOutput.evaluation) {
          beta = minOutput;
        }
        if (beta.evaluation <= alpha.evaluation) {
          break;
        }
      }
      return minOutput;
    }
  }
}
