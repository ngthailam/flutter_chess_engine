import 'dart:math';

import 'package:chess_engine/engine/minimax.dart';
import 'package:chess_engine/game/game.dart';
import 'package:chess_engine/game/move_generator.dart';
import 'package:chess_engine/game/utils.dart';
import 'package:chess_engine/utils/extensions.dart';
import 'package:chess_engine/utils/logger.dart';

class Engine {
  Side side = Side.black;

  Future move(Game game) async {
    final initialOutput = MiniMaxOutput(
      boardAndMoveSet: BoardAndMoveSet(
        board: game.board,
        pieceCoord: Coordinate(0, 0),
        targetPieceCoord: Coordinate(0, 0),
      ),
      evaluation: 0,
    );
    final MiniMaxOutput output = MiniMax()
        .run(game.board, 3, initialOutput, initialOutput, side.isWhite());

    Logger.d(
        'Engine >>>>>>>> decided: move piece ${game.board.getAtCoord(output.boardAndMoveSet.pieceCoord)} ${output.boardAndMoveSet.pieceCoord} to ${output.boardAndMoveSet.targetPieceCoord}');

    game.move(
      output.boardAndMoveSet.pieceCoord,
      output.boardAndMoveSet.targetPieceCoord,
    );
  }

  //// For random stuffs
  Future _moveRandomly(Game game) async {
    final pieceCoordinateList = game.board.getAllCoordsBySide(side);

    final Map<Coordinate, Set<Coordinate>> moveSet = {};

    await Future.delayed(const Duration(seconds: 1));

    for (var coordinate in pieceCoordinateList) {
      final moves = game.getValidMoveCoords(
        coordinate,
        checkKingSafety: true,
      );

      if (moves.isNotEmpty) {
        moveSet[coordinate] = moves;
      }
    }

    final randomKey = moveSet.randomKey();
    final keyCoordinateList = moveSet[randomKey];
    final randomMove = keyCoordinateList!
        .elementAt(Random().nextInt(keyCoordinateList.length));

    Logger.d(
        'Engine moving... piece=${game.board.getAtCoord(randomKey)}, move=$randomMove');
    game.move(randomKey, randomMove);
  }
}
