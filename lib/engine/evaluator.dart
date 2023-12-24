import 'package:chess_engine/game/board.dart';

class Evaluator {
  /// Positive => favors white
  /// Negative => favors black
  static int evaluate(Board board) {
    int score = 0;
    for (int i = 0; i < BoardConsts.itemPerRow; i++) {
      for (int j = 0; j < BoardConsts.itemPerRow; j++) {
        final piece = board.getAtXy(i, j);
        if (piece != null) {
          if (piece.isWhite()) {
            score += piece.baseValue;
          } else {
            score -= piece.baseValue;
          }
        }
      }
    }

    return score;
  }
}
