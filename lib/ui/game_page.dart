import 'dart:async';

import 'package:chess_engine/engine/engine.dart';
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
  final Engine engine = Engine();

  final Engine engineWhite = Engine(side: Side.white);

  Coordinate? focusedCoord;

  Set<Coordinate> validMoves = {};

  StreamSubscription? _winnerStreamSub;
  StreamSubscription? _turnStreamSub;

  @override
  void initState() {
    super.initState();
    _winnerStreamSub = game.winnerStreamCtrl.stream.listen((event) {
      if (event != null && mounted) {
        setState(() {});
      }
    });

    _turnStreamSub = game.turnStreamCtrl.stream.listen((event) {
      if (event == engine.side) {
        engine.move(game);
      } else if (event == engineWhite.side) {
        engineWhite.move(game);
      }

      if (mounted) {
        setState(() {});
      }
    });

    engineWhite.move(game);
  }

  @override
  void dispose() {
    _winnerStreamSub?.cancel();
    _turnStreamSub?.cancel();
    super.dispose();
  }

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

  void _onNewFocus(Coordinate newFocusedCoord) {
    focusedCoord = newFocusedCoord;
    validMoves = game.getValidMoveCoords(newFocusedCoord);
  }

  void _resetFocus() {
    focusedCoord = null;
    validMoves = {};
  }

  void _onPieceTapped(Piece? piece, int x, int y) {
    // When click empty square, nothing happens
    if (game.winner != null) {
      return;
    }
    if (focusedCoord == null && piece == null) {
      return;
    }

    final newFocusedCoord = Coordinate(x, y);
    final pieceAtNewFocusedCoord = game.board.getAtCoord(newFocusedCoord);

    if (focusedCoord == null) {
      if (pieceAtNewFocusedCoord?.side == game.currentSide) {
        _onNewFocus(newFocusedCoord);
        setState(() {});
      } else {
        // When click on piece on the other side while not your turn
        // do nothing here
      }

      return;
    }

    if (focusedCoord == newFocusedCoord) {
      _resetFocus();
      setState(() {});
      return;
    }

    final pieceAtNewCoord = game.board.getAtCoord(newFocusedCoord);
    final pieceAtFocusedCoord = game.board.getAtCoord(focusedCoord!);

    if (pieceAtNewCoord != null &&
        pieceAtFocusedCoord?.isSameSide(pieceAtNewCoord) == true) {
      _onNewFocus(newFocusedCoord);
      setState(() {});
    } else {
      game.move(focusedCoord!, newFocusedCoord, validMoves: validMoves);
      _resetFocus();
      setState(() {});
      // To avoid double setState
      return;
    }
  }

  Widget _pieceWidget({required int x, required int y}) {
    final piece = game.board.getAtXy(x, y);

    return PieceItem(
      key: Key('$x-$y'),
      onTap: () => _onPieceTapped(piece, x, y),
      xCoord: x,
      yCoord: y,
      status: _getPieceStatus(piece, x, y),
      piece: piece,
    );
  }

  List<Widget> _getColumnWidgets() {
    final List<Widget> widgets = [];

    for (int i = 0; i < game.board.data.length; i++) {
      final row = game.board.data[i];
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
            Text('Current turn: ${game.currentSide.name}'),
            if (game.currentSide == engine.side)
              const Text('Computer is thinking....'),
            Text('Turn count: ${game.turnCount}'),
            if (game.winner != null)
              Text('🎉🎉🎉 Winner: ${game.winner!.name.toUpperCase()} 🎉🎉🎉'),
            const SizedBox(height: 32),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                game.undo();
              },
              child: const Text('Undo'),
            )
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
