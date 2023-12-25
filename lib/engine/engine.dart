import 'package:chess_engine/engine/minimax.dart';
import 'package:chess_engine/game/constants.dart';
import 'package:chess_engine/game/game.dart';
import 'package:chess_engine/game/utils.dart';
import 'package:chess_engine/utils/logger.dart';
import 'package:flutter/foundation.dart';

class Engine {
  Side side = Side.black;

  // This shit is blocking the Isolate
  void move(Game game) {
    final Stopwatch stopwatch = Stopwatch()..start();
    compute<List<dynamic>, MiniMaxOutput>(
        (message) => MiniMax()
            .run(message[0], message[1], message[2], message[3], message[4]),
        <dynamic>[
          game.board,
          Constants.searchDepth,
          null,
          null,
          side.isWhite()
        ]).then((output) {
      Logger.d(
          'zzll >>>>> ${stopwatch.elapsed} ${output.boardAndMoveSet.pieceCoord} - ${output.boardAndMoveSet.targetPieceCoord}');

      stopwatch.stop();
      game.move(
        output.boardAndMoveSet.pieceCoord,
        output.boardAndMoveSet.targetPieceCoord,
      );
    }).catchError((e) {
      Logger.d('zzll error $e');
    });
  }
}
