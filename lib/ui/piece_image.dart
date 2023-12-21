import 'package:chess_engine/game/piece.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PieceImage extends StatelessWidget {
  const PieceImage({Key? key, required this.piece}) : super(key: key);

  final Piece piece;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset('assets/piece/${piece.imageName}');
  }
}
