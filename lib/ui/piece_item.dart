import 'package:chess_engine/game/piece.dart';
import 'package:chess_engine/ui/piece_image.dart';
import 'package:flutter/material.dart';

enum PieceItemStatus {
  none,
  focused,
  move,
  capture;
}

class PieceItem extends StatelessWidget {
  const PieceItem({
    Key? key,
    required this.onTap,
    required this.piece,
    required this.xCoord,
    required this.yCoord,
    required this.status,
  }) : super(key: key);

  final Piece? piece;
  final GestureTapCallback? onTap;
  final int xCoord;
  final int yCoord;
  final PieceItemStatus status;

  double get borderWidth {
    if (status == PieceItemStatus.none) return 0.2;
    return 4;
  }

  Color get borderColor {
    switch (status) {
      case PieceItemStatus.focused:
        return Colors.yellow;
      case PieceItemStatus.move:
        return Colors.blue;
      case PieceItemStatus.capture:
        return Colors.red;
      default:
        return const Color(0xFF000000);
    }
  }

  Color get squareColorGreen => const Color.fromARGB(255, 67, 193, 0);

  Color get squareColorWhite => const Color(0xffffffff);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width / 8;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color:
              (xCoord + yCoord) % 2 == 0 ? squareColorGreen : squareColorWhite,
          border: Border.all(
            width: borderWidth,
            color: borderColor,
          ),
        ),
        width: size,
        height: size,
        child: piece != null
            ? Center(child: PieceImage(piece: piece!))
            : Center(child: Text('$xCoord-$yCoord')),
      ),
    );
  }
}
