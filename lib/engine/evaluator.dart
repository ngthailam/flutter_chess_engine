import 'package:chess_engine/game/board.dart';
import 'package:chess_engine/game/constants.dart';
import 'package:chess_engine/game/move_generator.dart';
import 'package:chess_engine/game/piece.dart';
import 'package:chess_engine/game/utils.dart';

class Evaluator {
  static List<List<double>> centralExtraPoints = [
    [0, 0.1, 0.25, 0.5, 0.5, 0.25, 0.1, 0],
    [0, 0.1, 0.25, 0.5, 0.5, 0.25, 0.1, 0],
    [0, 0.1, 0.50, 0.5, 0.5, 0.50, 0.1, 0],
    [0, 0.1, 0.50, 0.9, 0.9, 0.50, 0.1, 0],
    [0, 0.1, 0.50, 0.9, 0.9, 0.50, 0.1, 0],
    [0, 0.1, 0.25, 0.5, 0.5, 0.50, 0.1, 0],
    [0, 0.1, 0.25, 0.5, 0.5, 0.25, 0.1, 0],
    [0, 0.1, 0.25, 0.5, 0.5, 0.25, 0.1, 0],
  ];

  static List<List<double>> whitePawnExtraPoints = [
    [5, 5, 5, 5, 5, 5, 5, 5],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0.1, 0.50, 0.9, 0.9, 0.50, 0.1, 0],
    [0, 0.1, 0.50, 0.9, 0.9, 0.50, 0.1, 0],
    [0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
  ];

  static List<List<double>> blackPawnExtraPoints = [
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05],
    [0, 0.1, 0.50, 0.9, 0.9, 0.50, 0.1, 0],
    [0, 0.1, 0.50, 0.9, 0.9, 0.50, 0.1, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [5, 5, 5, 5, 5, 5, 5, 5],
  ];

  static List<List<double>> kingEarlyGameExtraPoints = [
    [0, 0, 2, 0, 0.1, 0, 2, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 2, 0, 0.1, 0, 2, 0],
  ];

  static List<Coordinate> pawnsSupportPositions = [
    // Verticals/Horizontals
    const Coordinate(-1, 0), // Left
    const Coordinate(1, 0), // Right
    const Coordinate(0, 1), // Down
    const Coordinate(0, -1), // U
    // Diagonals
    const Coordinate(1, 1), // Top right
    const Coordinate(1, -1), // Bot right
    const Coordinate(-1, -1), // Bot left
    const Coordinate(-1, 1), // Top left
  ];

  /// Positive => favors white
  /// Negative => favors black
  static double evaluate(Board board) {
    double score = 0;
    int pieceCount = 0;

    int whiteKingX = 0;
    int whiteKingY = 0;
    int blackKingX = 0;
    int blackKingY = 0;

    for (int i = 0; i < Constants.itemPerRow; i++) {
      for (int j = 0; j < Constants.itemPerRow; j++) {
        final piece = board.getAtXy(i, j);
        final extraScore = centralExtraPoints[i][j];
        if (piece != null) {
          pieceCount += 1;
          if (piece.isWhite) {
            if (piece is King) {
              whiteKingX = i;
              whiteKingY = j;
            }
            if (piece is Pawn) {
              score += piece.baseValue + whitePawnExtraPoints[i][j];
              // Check if pawn has another pawn in 8 surrounding places
              for (var pSupportPosition in pawnsSupportPositions) {
                final targetPieceCoord = Coordinate(i, j).add(pSupportPosition);
                if (board.isCoordInsideBoard(targetPieceCoord)) {
                  final targetPiece = board.getAtCoord(targetPieceCoord);
                  if (targetPiece is Pawn && targetPiece.isWhite) {
                    score += 0.1;
                  }
                }
              }
            } else {
              score += piece.baseValue + extraScore;
            }
          } else {
            if (piece is King) {
              blackKingX = i;
              blackKingY = j;
            }
            if (piece is Pawn) {
              score -= piece.baseValue + blackPawnExtraPoints[i][j];
              // Check if pawn has another pawn in 8 surrounding places
              for (var pSupportPosition in pawnsSupportPositions) {
                final targetPieceCoord = Coordinate(i, j).add(pSupportPosition);
                if (board.isCoordInsideBoard(targetPieceCoord)) {
                  final targetPiece = board.getAtCoord(targetPieceCoord);
                  if (targetPiece is Pawn && !targetPiece.isWhite) {
                    score -= 0.1;
                  }
                }
              }
            } else {
              score -= (piece.baseValue + extraScore);
            }
          }
        }
      }
    }

    // King safety
    if (pieceCount > 16) {
      score += kingEarlyGameExtraPoints[whiteKingX][whiteKingY];
      score -= kingEarlyGameExtraPoints[blackKingX][blackKingY];
    }

    // Allow the most possible moves ?
    // if (pieceCount > 24) {
    //   int blackMoveCount = 0;
    //   board.getAllPiecesCoordsBySide(Side.black).forEach((element) {
    //     blackMoveCount +=
    //         (MoveGenerator().getValidMoveCoords(board, element, Side.black))
    //             .length;
    //   });

    //   int whiteMoveCount = 0;
    //   board.getAllPiecesCoordsBySide(Side.white).forEach((element) {
    //     whiteMoveCount +=
    //         (MoveGenerator().getValidMoveCoords(board, element, Side.white))
    //             .length;
    //   });

    //   score += (whiteMoveCount - blackMoveCount) * 0.15;
    // }

    return score;
  }
}
