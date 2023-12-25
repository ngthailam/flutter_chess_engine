import 'package:chess_engine/game/piece.dart';

class LastMove {
  final List<Coordinate> coord;
  final List<Coordinate> targetCoord;

  LastMove({
    this.coord = const [],
    this.targetCoord = const [],
  });
}

class Coordinate {
  final int x;
  final int y;

  const Coordinate(this.x, this.y);

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
    Rook(side: Side.white, identifier: '0-0'),
    Pawn(side: Side.white, identifier: '0-1'),
    null,
    null,
    null,
    null,
    Pawn(side: Side.black, identifier: '0-6'),
    Rook(side: Side.black, identifier: '0-7'),
  ],
  [
    Knight(side: Side.white, identifier: '1-0'),
    Pawn(side: Side.white, identifier: '1-1'),
    null,
    null,
    null,
    null,
    Pawn(side: Side.black, identifier: '1-6'),
    Knight(side: Side.black, identifier: '1-7'),
  ],
  [
    Bishop(side: Side.white, identifier: '2-0'),
    Pawn(side: Side.white, identifier: '2-1'),
    null,
    null,
    null,
    null,
    Pawn(side: Side.black, identifier: '2-6'),
    Bishop(side: Side.black, identifier: '2-7'),
  ],
  [
    Queen(side: Side.white, identifier: '3-0'),
    Pawn(side: Side.white, identifier: '3-1'),
    null,
    null,
    null,
    null,
    Pawn(side: Side.black, identifier: '3-6'),
    Queen(side: Side.black, identifier: '3-7'),
  ],
  [
    King(side: Side.white, identifier: '4-0'),
    Pawn(side: Side.white, identifier: '4-1'),
    null,
    null,
    null,
    null,
    Pawn(side: Side.black, identifier: '4-6'),
    King(side: Side.black, identifier: '4-7'),
  ],
  [
    Bishop(side: Side.white, identifier: '5-0'),
    Pawn(side: Side.white, identifier: '5-1'),
    null,
    null,
    null,
    null,
    Pawn(side: Side.black, identifier: '5-6'),
    Bishop(side: Side.black, identifier: '5-7'),
  ],
  [
    Knight(side: Side.white, identifier: '6-0'),
    Pawn(side: Side.white, identifier: '6-1'),
    null,
    null,
    null,
    null,
    Pawn(side: Side.black, identifier: '6-6'),
    Knight(side: Side.black, identifier: '6-7'),
  ],
  [
    Rook(side: Side.white, identifier: '7-0'),
    Pawn(side: Side.white, identifier: '7-1'),
    null,
    null,
    null,
    null,
    Pawn(side: Side.black, identifier: '7-6'),
    Rook(side: Side.black, identifier: '7-7'),
  ]
];
