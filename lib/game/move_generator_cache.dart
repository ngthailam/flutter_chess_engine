import 'package:chess_engine/game/constants.dart';
import 'package:chess_engine/game/utils.dart';

// Each board possition should contain 1 Map<PieceIndentifier, Set<Coordinate>>
// This works best when user toggle between pieces in the same turn
class MoveGeneratorCache {
  static final MoveGeneratorCache _singleton = MoveGeneratorCache._internal();

  factory MoveGeneratorCache() {
    return _singleton;
  }

  MoveGeneratorCache._internal();

  //////// CODE ////////
  final Map<BoardIdentifier, Map<PieceIdentifier, Set<Coordinate>>>
      possibleMoves = {};

  /// @value: last moveCount
  final Map<BoardIdentifier, int> cacheHitCount = {};

  int moveCount = 0;

  Set<Coordinate>? get({
    required BoardIdentifier boardIdentifier,
    required PieceIdentifier pieceIdentifier,
  }) {
    final result = possibleMoves[boardIdentifier]?[pieceIdentifier];
    if (result != null) {
      cacheHitCount[boardIdentifier] = moveCount;
    }

    return result;
  }

  void save({
    required BoardIdentifier boardIdentifier,
    required PieceIdentifier pieceIdentifier,
    required Set<Coordinate> moves,
  }) {
    if (possibleMoves[boardIdentifier] == null) {
      possibleMoves[boardIdentifier] = {};
    }
    possibleMoves[boardIdentifier]?[pieceIdentifier] = moves;
  }

  void onPieceMoved() {
    moveCount += 1;
    cacheHitCount.removeWhere((key, value) {
      return moveCount - value > Constants.searchDepth;
    });
  }

  // Clear cache
  void invalidate() {
    possibleMoves.clear();
  }
}
