import 'package:flutter/material.dart';

import '../../../core/constants/mtg_constants.dart';
import '../models/player_model.dart';
import 'player_panel.dart';

/// Computes the grid layout (rows, cols, rotation) based on player count.
class _GridConfig {
  final int rows;
  final int cols;

  /// Rotation per cell as quarterTurns.
  /// Returns 0, 1, 2, or 3 (90-degree increments CW).
  final int Function(int row, int col) quarterTurns;

  const _GridConfig({
    required this.rows,
    required this.cols,
    required this.quarterTurns,
  });
}

_GridConfig _configForCount(int count) {
  if (count <= 2) {
    return _GridConfig(
      rows: 2,
      cols: 1,
      quarterTurns: (row, col) => row == 0 ? 2 : 0, // top rotated 180
    );
  }
  if (count <= 4) {
    return _GridConfig(
      rows: 2,
      cols: 2,
      quarterTurns: (row, col) => row == 0 ? 2 : 0,
    );
  }
  // 5-10: two columns, sideways layout
  final rows = ((count + 1) ~/ 2); // ceil(count / 2)
  return _GridConfig(
    rows: rows,
    cols: 2,
    quarterTurns: (row, col) => col == 0 ? 1 : 3, // left=90CW, right=270CW
  );
}

/// Maps player index to (row, col) in the grid.
/// Players fill bottom-to-top, alternating left-right.
List<(int row, int col)> _playerPositions(int count, _GridConfig config) {
  final positions = <(int row, int col)>[];
  if (count <= 2) {
    // 2 players: bottom (row 1), top (row 0)
    positions.add((1, 0)); // Player 1 at bottom
    if (count > 1) positions.add((0, 0)); // Player 2 at top
  } else if (count <= 4) {
    // 3-4 players: bottom-left, bottom-right, top-left, top-right
    positions.add((1, 0)); // P1
    if (count > 1) positions.add((1, 1)); // P2
    if (count > 2) positions.add((0, 0)); // P3
    if (count > 3) positions.add((0, 1)); // P4
  } else {
    // 5-10: fill from bottom, alternating left-right
    int row = config.rows - 1;
    int col = 0;
    for (int i = 0; i < count; i++) {
      positions.add((row, col));
      if (col == 0) {
        col = 1;
      } else {
        col = 0;
        row--;
      }
    }
  }
  return positions;
}

class PlayerGrid extends StatelessWidget {
  final List<PlayerState> players;
  final int activePlayerIndex;

  const PlayerGrid({
    super.key,
    required this.players,
    required this.activePlayerIndex,
  });

  @override
  Widget build(BuildContext context) {
    final count = players.length;
    final config = _configForCount(count);
    final positions = _playerPositions(count, config);

    // Build a 2D grid of widgets (null for empty cells)
    final grid = List.generate(
      config.rows,
      (_) => List<Widget?>.filled(config.cols, null),
    );

    for (int i = 0; i < count; i++) {
      final (row, col) = positions[i];
      final player = players[i];
      final isActive = i == activePlayerIndex;
      final turns = config.quarterTurns(row, col);
      final bgColor = Color(
        MtgConstants.playerColors[player.colorIndex % MtgConstants.playerColors.length],
      );

      grid[row][col] = RotatedBox(
        quarterTurns: turns,
        child: PlayerPanel(
          playerIndex: i,
          player: player,
          isActive: isActive,
          backgroundColor: bgColor,
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: Column(
        children: [
          for (int r = 0; r < config.rows; r++) ...[
            if (r > 0) const SizedBox(height: 1), // thin row divider
            Expanded(
              child: Row(
                children: [
                  for (int c = 0; c < config.cols; c++) ...[
                    if (c > 0) const SizedBox(width: 1), // thin col divider
                    Expanded(
                      child: grid[r][c] ?? const SizedBox.expand(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
