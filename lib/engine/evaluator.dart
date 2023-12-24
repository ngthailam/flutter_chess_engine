import 'package:chess_engine/game/board.dart';
import 'package:chess_engine/game/constants.dart';

class Evaluator {
  /// Positive => favors white
  /// Negative => favors black
  static int evaluate(Board board) {
    int score = 0;
    for (int i = 0; i < Constants.itemPerRow; i++) {
      for (int j = 0; j < Constants.itemPerRow; j++) {
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
