import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tournament_models.dart';
import '../providers/tournament_provider.dart';
import '../widgets/players_section.dart';
import '../widgets/rounds_section.dart';
import '../widgets/standings_section.dart';

class TournamentDetailScreen extends ConsumerStatefulWidget {
  final String tournamentId;

  const TournamentDetailScreen({super.key, required this.tournamentId});

  @override
  ConsumerState<TournamentDetailScreen> createState() =>
      _TournamentDetailScreenState();
}

class _TournamentDetailScreenState
    extends ConsumerState<TournamentDetailScreen> {
  int _selectedSection = 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tournamentProvider);
    final tournament = state.tournaments
        .where((t) => t.id == widget.tournamentId)
        .firstOrNull;

    if (tournament == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Tournament not found')),
      );
    }

    final statusColor = _statusColor(tournament.status);

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => _showRenameDialog(context, tournament),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(tournament.name,
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.edit, size: 16, color: Colors.white38),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusLabel(tournament.status),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          if (tournament.status == TournamentStatus.inProgress &&
              tournament.isComplete)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'complete') {
                  HapticFeedback.mediumImpact();
                  ref
                      .read(tournamentProvider.notifier)
                      .completeTournament(widget.tournamentId);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'complete',
                  child: Text('Complete Tournament'),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // Segmented button
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: 0,
                  label: Text('Players'),
                  icon: Icon(Icons.people_outline, size: 18),
                ),
                ButtonSegment(
                  value: 1,
                  label: Text('Rounds'),
                  icon: Icon(Icons.format_list_numbered, size: 18),
                ),
                ButtonSegment(
                  value: 2,
                  label: Text('Standings'),
                  icon: Icon(Icons.leaderboard_outlined, size: 18),
                ),
              ],
              selected: {_selectedSection},
              onSelectionChanged: (set) {
                setState(() => _selectedSection = set.first);
              },
            ),
          ),
          // Section content
          Expanded(
            child: IndexedStack(
              index: _selectedSection,
              children: [
                PlayersSection(tournamentId: widget.tournamentId),
                RoundsSection(tournamentId: widget.tournamentId),
                StandingsSection(tournamentId: widget.tournamentId),
              ],
            ),
          ),
          // Start tournament button
          if (tournament.status == TournamentStatus.setup &&
              tournament.players.length >= 2)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      ref
                          .read(tournamentProvider.notifier)
                          .startTournament(widget.tournamentId);
                      setState(() => _selectedSection = 1);
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: Text(
                        'Start Tournament (${tournament.players.length} players)'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _statusColor(TournamentStatus status) {
    switch (status) {
      case TournamentStatus.setup:
        return Colors.blue.shade300;
      case TournamentStatus.inProgress:
        return Colors.amber.shade300;
      case TournamentStatus.completed:
        return Colors.green.shade300;
    }
  }

  String _statusLabel(TournamentStatus status) {
    switch (status) {
      case TournamentStatus.setup:
        return 'Setup';
      case TournamentStatus.inProgress:
        return 'In Progress';
      case TournamentStatus.completed:
        return 'Complete';
    }
  }

  void _showRenameDialog(
      BuildContext context, Tournament tournament) {
    final controller = TextEditingController(text: tournament.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Tournament'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Tournament Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref
                    .read(tournamentProvider.notifier)
                    .updateTournament(
                        tournament.copyWith(name: name));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }
}
