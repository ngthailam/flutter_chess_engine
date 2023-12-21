import 'package:chess_engine/game/game.dart';
import 'package:chess_engine/game/piece.dart';
import 'package:chess_engine/game/utils.dart';
import 'package:chess_engine/ui/piece_item.dart';
import 'package:flutter/material.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<GamePage> {
  final Game game = Game();

  Coordinate? focusedCoord;

  List<Coordinate> validMoves = [];

  PieceItemStatus _getPieceStatus(
    Piece? piece,
    int x,
    int y,
  ) {
    if (x == focusedCoord?.x && y == focusedCoord?.y) {
      return PieceItemStatus.focused;
    }

    for (var element in validMoves) {
      if (element.x == x && element.y == y) {
        if (piece == null) {
          return PieceItemStatus.move;
        } else {
          return PieceItemStatus.capture;
        }
      }
    }

    return PieceItemStatus.none;
  }

  Widget _pieceWidget({required int x, required int y}) {
    final piece = game.getAtXy(x, y);

    return PieceItem(
      key: Key('$x-$y-$piece'),
      onTap: () {
        // When click empty square, nothing happens
        if (focusedCoord == null && piece == null) {
          return;
        }
        final newFocusedCoord = Coordinate(x, y);
        final pieceAtNewFocusedCoord = game.getAtCoord(newFocusedCoord);

        if (focusedCoord == null) {
          if (pieceAtNewFocusedCoord?.side == game.currentTurn) {
            focusedCoord = newFocusedCoord;
            validMoves = game.getValidMoves(Coordinate(x, y));
          }
        } else {
          if (focusedCoord != newFocusedCoord) {
            final pieceAtNewCoord = game.getAtCoord(newFocusedCoord);
            if (pieceAtNewCoord != null &&
                piece?.isSameSide(pieceAtNewCoord) != true) {
              focusedCoord = newFocusedCoord;
              validMoves = game.getValidMoves(Coordinate(x, y));
            } else {
              game.move(focusedCoord!, newFocusedCoord);
            }
          }

          focusedCoord = null;
          validMoves = [];
        }

        setState(() {});
      },
      xCoord: x,
      yCoord: y,
      status: _getPieceStatus(piece, x, y),
      piece: piece,
    );
  }

  List<Widget> _getColumnWidgets() {
    final List<Widget> widgets = [];

    for (int i = 0; i < game.board.length; i++) {
      final row = game.board[i];
      final List<Widget> widgetsEachRow = [];
      for (int j = row.length - 1; j >= 0; j--) {
        widgetsEachRow.add(_pieceWidget(x: i, y: j));
      }

      widgets.add(Column(children: widgetsEachRow));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _board(),
            const SizedBox(height: 16),
            Text('Current turn: ${game.currentTurn.name}'),
            Text('Turn count: ${game.turnCount}'),
          ],
        ),
      ),
    );
  }

  Widget _board() {
    final widgets = _getColumnWidgets();

    return Row(
      children: [
        widgets[0],
        widgets[1],
        widgets[2],
        widgets[3],
        widgets[4],
        widgets[5],
        widgets[6],
        widgets[7],
      ],
    );
  }
}
