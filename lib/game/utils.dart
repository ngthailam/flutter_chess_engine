import 'package:chess_engine/game/piece.dart';

class Coordinate {
  final int x;
  final int y;

  Coordinate(this.x, this.y);

  Coordinate add(Coordinate coord, {int multiplier = 1}) {
    return Coordinate(
      x + (coord.x * multiplier),
      y + (coord.y * multiplier),
    );
  }

  @override
  bool operator ==(other) =>
      other is Coordinate && x == other.x && y == other.y;

  @override
  String toString() {
    return 'Coord($x,$y)';
  }

  @override
  int get hashCode => "$x$y".hashCode;
}

enum Side {
  white,
  black;

  bool isWhite() => this == white;
  bool isBlack() => this == black;

  Side getOtherSide() => isWhite() ? Side.black : Side.white;
}

List<List<Piece?>> initialBoard = [
  [
    Rook(side: Side.white),
    Pawn(side: Side.white),
    null,
    null,
    null,
    null,
    Pawn(side: Side.black),
    Rook(side: Side.black),
  ],
  [
    Knight(side: Side.white),
    Pawn(side: Side.white),
    null,
    null,
    null,
    null,
    Pawn(side: Side.black),
    Knight(side: Side.black),
  ],
  [
    Bishop(side: Side.white),
    Pawn(side: Side.white),
    null,
    null,
    null,
    null,
    Pawn(side: Side.black),
    Bishop(side: Side.black),
  ],
  [
    Queen(side: Side.white),
    Pawn(side: Side.white),
    null,
    null,
    null,
    null,
    Pawn(side: Side.black),
    Queen(side: Side.black),
  ],
  [
    King(side: Side.white),
    Pawn(side: Side.white),
    null,
    null,
    null,
    null,
    Pawn(side: Side.black),
    King(side: Side.black),
  ],
  [
    Bishop(side: Side.white),
    Pawn(side: Side.white),
    null,
    null,
    null,
    null,
    Pawn(side: Side.black),
    Bishop(side: Side.black),
  ],
  [
    Knight(side: Side.white),
    Pawn(side: Side.white),
    null,
    null,
    null,
    null,
    Pawn(side: Side.black),
    Knight(side: Side.black),
  ],
  [
    Rook(side: Side.white),
    Pawn(side: Side.white),
    null,
    null,
    null,
    null,
    Pawn(side: Side.black),
    Rook(side: Side.black),
  ]
];
