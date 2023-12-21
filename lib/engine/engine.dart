import 'dart:math';

import 'package:chess_engine/game/game.dart';
import 'package:chess_engine/game/utils.dart';
import 'package:chess_engine/utils/extensions.dart';
import 'package:chess_engine/utils/logger.dart';

class Engine {
  Side side = Side.black;

  Future move(Game game) async {
    final pieceCoordinateList = game.getAllCoordsBySide(side);

    final Map<Coordinate, Set<Coordinate>> moveSet = {};

    await Future.delayed(const Duration(seconds: 4));

    for (var coordinate in pieceCoordinateList) {
   
      final moves = game.getValidMoveCoords(
        coordinate,
        checkKingSafety: true,
      );

      Logger.d(
          '========== >>>>>>>>>>>> Engine, piece = ${game.getAtCoord(coordinate)} - $coordinate - $moves');

      if (moves.isNotEmpty) {
        moveSet[coordinate] = moves;
      }
    }

    final randomKey = moveSet.randomKey();
    final keyCoordinateList = moveSet[randomKey];
    final randomMove = keyCoordinateList!
        .elementAt(Random().nextInt(keyCoordinateList.length));

    Logger.d(
        'Engine moving... piece=${game.getAtCoord(randomKey)}, move=$randomMove');
    game.move(randomKey, randomMove);
  }
}
