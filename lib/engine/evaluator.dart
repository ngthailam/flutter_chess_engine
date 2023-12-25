import 'package:chess_engine/game/board.dart';
import 'package:chess_engine/game/constants.dart';

class Evaluator {
  static List<List<double>> extraCentralPoints = [
    [0, 0.1, 0.25, 0.5, 0.5, 0.25, 0.1, 0],
    [0, 0.1, 0.25, 0.5, 0.5, 0.25, 0.1, 0],
    [0, 0.1, 0.50, 0.5, 0.5, 0.50, 0.1, 0],
    [0, 0.1, 0.50, 0.9, 0.9, 0.50, 0.1, 0],
    [0, 0.1, 0.50, 0.9, 0.9, 0.50, 0.1, 0],
    [0, 0.1, 0.25, 0.5, 0.5, 0.50, 0.1, 0],
    [0, 0.1, 0.25, 0.5, 0.5, 0.25, 0.1, 0],
    [0, 0.1, 0.25, 0.5, 0.5, 0.25, 0.1, 0],
  ];

  /// Positive => favors white
  /// Negative => favors black
  static double evaluate(Board board) {
    double score = 0;
    for (int i = 0; i < Constants.itemPerRow; i++) {
      for (int j = 0; j < Constants.itemPerRow; j++) {
        final piece = board.getAtXy(i, j);
        final extraScore = extraCentralPoints[i][j];
        if (piece != null) {
          if (piece.isWhite) {
            score += piece.baseValue + extraScore;
          } else {
            score -= (piece.baseValue + extraScore);
          }
        }
      }
    }

    return score;
  }
}
