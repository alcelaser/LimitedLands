import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tournament_models.dart';
import '../providers/tournament_provider.dart';
import '../services/swiss_pairing_service.dart';

class StandingsSection extends ConsumerWidget {
  final String tournamentId;

  const StandingsSection({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tournamentProvider);
    final tournament =
        state.tournaments.where((t) => t.id == tournamentId).firstOrNull;

    if (tournament == null) {
      return const Center(child: Text('Tournament not found'));
    }

    final standings = SwissPairingService.calculateStandings(tournament);

    if (standings.isEmpty || tournament.status == TournamentStatus.setup) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.leaderboard_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.4)),
            const SizedBox(height: 12),
            const Text('Start the tournament to see standings',
                style: TextStyle(color: Colors.white38)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(36),
          1: FlexColumnWidth(),
          2: FixedColumnWidth(40),
          3: FixedColumnWidth(64),
          4: FixedColumnWidth(52),
          5: FixedColumnWidth(52),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          // Header row
          TableRow(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            children: [
              _headerCell('#'),
              _headerCell('Player'),
              _headerCell('Pts'),
              _headerCell('Record'),
              _headerCell('OMW%'),
              _headerCell('GWP'),
            ],
          ),
          // Data rows
          ...standings.map((entry) {
            final isLeader = entry.rank == 1;
            final recordColor = _recordColor(entry);

            return TableRow(
              decoration: isLeader
                  ? BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.05),
                    )
                  : null,
              children: [
                _dataCell(
                  '${entry.rank}',
                  fontWeight: isLeader ? FontWeight.bold : FontWeight.normal,
                  color: isLeader
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white70,
                ),
                _dataCell(
                  entry.player.name,
                  fontWeight: isLeader ? FontWeight.bold : FontWeight.normal,
                ),
                _dataCell(
                  '${entry.matchPoints}',
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                _dataCell(
                  entry.record,
                  color: recordColor,
                  fontWeight: FontWeight.w600,
                ),
                _dataCell(
                  '${(entry.omwPercent * 100).toStringAsFixed(0)}%',
                  color: Colors.white54,
                ),
                _dataCell(
                  '${(entry.gwPercent * 100).toStringAsFixed(0)}%',
                  color: Colors.white54,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Color _recordColor(StandingsEntry entry) {
    if (entry.wins > entry.losses) return Colors.green.shade300;
    if (entry.losses > entry.wins) return Colors.red.shade300;
    if (entry.wins == 0 && entry.losses == 0) return Colors.white38;
    return Colors.amber.shade300;
  }

  Widget _headerCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white54,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _dataCell(
    String text, {
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.white,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: fontWeight,
          fontSize: 14,
        ),
      ),
    );
  }
}
