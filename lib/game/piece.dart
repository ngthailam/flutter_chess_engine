import 'package:chess_engine/game/constants.dart';
import 'package:chess_engine/game/utils.dart';
import 'package:flutter/material.dart';

abstract class Piece {
  final Side side;

  final PieceIdentifier identifier;

  // Possible move directions of a piece
  List<Coordinate> get moveCoords;

  // For pieces with capture coords different from move coords
  List<Coordinate> get captureCoords => [];

  // Determine a Piece moves in a ray (continuous in given moveVectors) or not.
  // and the number of which this move ray gets
  int moveCoordsMultiplier(bool isFirstMove);

  String get imageName {
    return '${runtimeType.toString().toLowerCase()}_${isWhite ? 'white' : 'black'}.svg';
  }

  // Helper functions
  bool isWhite;

  bool isSameSide(Piece otherPiece) => side == otherPiece.side;

  int get baseValue;

  Piece({
    required this.side,
    required this.identifier,
  }) : isWhite = side.isWhite();

  @override
  String toString() {
    return '${side.name.toUpperCase()} ${runtimeType.toString()}';
  }

  String toShortString() {
    return '${side.name.characters.characterAt(0).toUpperCase()} ${runtimeType.toString().characters.characterAt(0).toUpperCase()}';
  }
}

class Rook extends Piece {
  Rook({required super.side, required super.identifier});

  @override
  int get baseValue => 5;

  @override
  int moveCoordsMultiplier(bool isFirstMove) => Constants.maxIndex;

  @override
  List<Coordinate> get moveCoords => [
        Coordinate(-1, 0), // Left
        Coordinate(1, 0), // Right
        Coordinate(0, 1), // Down
        Coordinate(0, -1), // Up
      ];
}

class Knight extends Piece {
  Knight({required super.side, required super.identifier});

  @override
  int get baseValue => 2;

  @override
  int moveCoordsMultiplier(bool isFirstMove) => 1;

  @override
  List<Coordinate> get moveCoords => [
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
  Bishop({required super.side, required super.identifier});

  @override
  int get baseValue => 3;

  @override
  int moveCoordsMultiplier(bool isFirstMove) => Constants.maxIndex;

  @override
  List<Coordinate> get moveCoords => [
        Coordinate(1, 1), // Top right
        Coordinate(1, -1), // Bot right
        Coordinate(-1, -1), // Bot left
        Coordinate(-1, 1), // Top left
      ];
}

class King extends Piece {
  King({required super.side, required super.identifier});

  @override
  int get baseValue => 999;

  @override
  int moveCoordsMultiplier(bool isFirstMove) => 1;

  @override
  List<Coordinate> get moveCoords => [
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
  Queen({required super.side, required super.identifier});

  @override
  int get baseValue => 9;

  @override
  int moveCoordsMultiplier(bool isFirstMove) => Constants.maxIndex;

  @override
  List<Coordinate> get moveCoords => [
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
  Pawn({required super.side, required super.identifier});

  @override
  int get baseValue => 1;

  @override
  int moveCoordsMultiplier(bool isFirstMove) {
    if (isFirstMove) return 2;
    return 1;
  }

  @override
  List<Coordinate> get captureCoords {
    final List<Coordinate> moves = [];

    if (isWhite) {
      moves.add(Coordinate(1, 1));
      moves.add(Coordinate(-1, 1));
    } else {
      moves.add(Coordinate(1, -1));
      moves.add(Coordinate(-1, -1));
    }

    return moves;
  }

  @override
  List<Coordinate> get moveCoords {
    final List<Coordinate> moves = [];

    if (isWhite) {
      // 1 up
      moves.add(Coordinate(0, 1));
    } else {
      // 1 down
      moves.add(Coordinate(0, -1));
    }

    return moves;
  }
}
