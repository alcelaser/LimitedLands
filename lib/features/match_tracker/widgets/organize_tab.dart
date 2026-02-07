import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tournament_models.dart';
import '../providers/tournament_provider.dart';
import '../screens/tournament_detail_screen.dart';

class OrganizeTab extends ConsumerWidget {
  final VoidCallback onCreateTournament;

  const OrganizeTab({super.key, required this.onCreateTournament});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tournamentProvider);

    if (state.tournaments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined,
                size: 64,
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withOpacity(0.4)),
            const SizedBox(height: 16),
            Text('No tournaments yet',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Tap + to organize an event',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.white54)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.tournaments.length,
      itemBuilder: (context, index) {
        final tournament = state.tournaments[index];
        return _TournamentCard(
          tournament: tournament,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  TournamentDetailScreen(tournamentId: tournament.id),
            ),
          ),
          onDelete: () {
            HapticFeedback.mediumImpact();
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Delete Tournament'),
                content: Text(
                    'Delete "${tournament.name}"? This cannot be undone.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      ref
                          .read(tournamentProvider.notifier)
                          .deleteTournament(tournament.id);
                      Navigator.pop(ctx);
                    },
                    child: Text('Delete',
                        style: TextStyle(color: Colors.red.shade300)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _TournamentCard extends StatelessWidget {
  final Tournament tournament;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _TournamentCard({
    required this.tournament,
    required this.onTap,
    required this.onDelete,
  });

  Color _statusColor() {
    switch (tournament.status) {
      case TournamentStatus.setup:
        return Colors.blue.shade300;
      case TournamentStatus.inProgress:
        return Colors.amber.shade300;
      case TournamentStatus.completed:
        return Colors.green.shade300;
    }
  }

  String _statusLabel() {
    switch (tournament.status) {
      case TournamentStatus.setup:
        return 'Setup';
      case TournamentStatus.inProgress:
        return 'In Progress';
      case TournamentStatus.completed:
        return 'Complete';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.emoji_events,
                    color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tournament.name,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _InfoChip(label: tournament.format),
                        const SizedBox(width: 8),
                        _InfoChip(
                            label:
                                '${tournament.players.length} players'),
                        const SizedBox(width: 8),
                        _InfoChip(
                            label:
                                'R${tournament.currentRoundNumber}/${tournament.totalRounds}'),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusLabel(),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline,
                    color: Colors.red.shade300, size: 20),
                onPressed: onDelete,
              ),
              const Icon(Icons.chevron_right, color: Colors.white24),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 12, color: Colors.white54)),
    );
  }
}
