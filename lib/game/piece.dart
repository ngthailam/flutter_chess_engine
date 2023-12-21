import 'package:chess_engine/game/utils.dart';

abstract class Piece {
  final Side side;

  bool isMoved;

  // Possible move directions of a piece
  List<Coordinate> get moveCoordinates;

  List<Coordinate> get additionalCaptureCoordinates => [];

  // Determine a Piece moves in a ray (continuous in given moveVectors) or not.
  bool get isMoveRay;

  String get imageName {
    return '${runtimeType.toString().toLowerCase()}_${isWhite() ? 'white' : 'black'}.svg';
  }

  // Helper functions
  bool isWhite() => side.isWhite();

  bool isSameSide(Piece otherPiece) => side == otherPiece.side;

  Piece({required this.side, required this.isMoved});

  @override
  String toString() {
    return '${side.name.toUpperCase()} ${runtimeType.toString()}';
  }
}

class Rook extends Piece {
  Rook({required super.side}) : super(isMoved: false);

  @override
  bool get isMoveRay => true;

  @override
  List<Coordinate> get moveCoordinates => [
        Coordinate(-1, 0), // Left
        Coordinate(1, 0), // Right
        Coordinate(0, 1), // Down
        Coordinate(0, -1), // Up
      ];
}

class Knight extends Piece {
  Knight({required super.side}) : super(isMoved: false);

  @override
  bool get isMoveRay => false;

  @override
  List<Coordinate> get moveCoordinates => [
        Coordinate(1, 2), // Top right
        Coordinate(2, 1), // Right top
        Coordinate(2, -1), // Right bot
        Coordinate(1, -2), // Bot right
        Coordinate(-1, -2), // Bot left
        Coordinate(-2, -1), // Left bot
        Coordinate(-2, 1), // Left top
        Coordinate(-1, 2), // Top left
      ];
}

class Bishop extends Piece {
  Bishop({required super.side}) : super(isMoved: false);

  @override
  bool get isMoveRay => true;

  @override
  List<Coordinate> get moveCoordinates => [
        Coordinate(1, 1), // Top right
        Coordinate(1, -1), // Bot right
        Coordinate(-1, -1), // Bot left
        Coordinate(-1, 1), // Top left
      ];
}

class King extends Piece {
  King({required super.side}) : super(isMoved: false);

  @override
  bool get isMoveRay => false;

  @override
  List<Coordinate> get moveCoordinates => [
        // Verticals/Horizontals
        Coordinate(-1, 0), // Left
        Coordinate(1, 0), // Right
        Coordinate(0, 1), // Down
        Coordinate(0, -1), // U
        // Diagonals
        Coordinate(1, 1), // Top right
        Coordinate(1, -1), // Bot right
        Coordinate(-1, -1), // Bot left
        Coordinate(-1, 1), // Top left
      ];
}

class Queen extends Piece {
  Queen({required super.side}) : super(isMoved: false);

  @override
  bool get isMoveRay => true;

  @override
  List<Coordinate> get moveCoordinates => [
        // Verticals/Horizontals
        Coordinate(-1, 0), // Left
        Coordinate(1, 0), // Right
        Coordinate(0, 1), // Down
        Coordinate(0, -1), // U
        // Diagonals
        Coordinate(1, 1), // Top right
        Coordinate(1, -1), // Bot right
        Coordinate(-1, -1), // Bot left
        Coordinate(-1, 1), // Top left
      ];
}

class Pawn extends Piece {
  Pawn({required super.side}) : super(isMoved: false);

  @override
  bool get isMoveRay => false;

  @override
  List<Coordinate> get additionalCaptureCoordinates {
    final List<Coordinate> moves = [];

    if (isWhite()) {
      moves.add(Coordinate(1, 1));
      moves.add(Coordinate(-1, 1));
    } else {
      moves.add(Coordinate(1, -1));
      moves.add(Coordinate(-1, -1));
    }

    return moves;
  }

  @override
  List<Coordinate> get moveCoordinates {
    final List<Coordinate> moves = [];

    // TODO: add en-passant
    if (isWhite()) {
      // 1 up
      moves.add(Coordinate(0, 1));
      if (!isMoved) {
        // 2 up on first move
        moves.add(Coordinate(0, 2));
      }
    } else {
      // 1 down
      moves.add(Coordinate(0, -1));
      if (!isMoved) {
        // 2 down on first move
        moves.add(Coordinate(0, -2));
      }
    }

    return moves;
  }
}
