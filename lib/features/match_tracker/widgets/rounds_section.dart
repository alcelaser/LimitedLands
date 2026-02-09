import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tournament_models.dart';
import '../providers/tournament_provider.dart';
import 'bracket_tree_widget.dart';
import 'pairing_card.dart';

class RoundsSection extends ConsumerWidget {
  final String tournamentId;

  const RoundsSection({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tournamentProvider);
    final tournament =
        state.tournaments.where((t) => t.id == tournamentId).firstOrNull;

    if (tournament == null) {
      return const Center(child: Text('Tournament not found'));
    }

    final playerMap = {for (final p in tournament.players) p.id: p.name};

    return Column(
      children: [
        if (tournament.canGenerateNextRound)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  ref
                      .read(tournamentProvider.notifier)
                      .generateNextRound(tournamentId);
                },
                icon: const Icon(Icons.auto_awesome, size: 18),
                label:
                    Text('Generate Round ${tournament.currentRoundNumber + 1}'),
              ),
            ),
          ),
        Expanded(
          child: tournament.rounds.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.format_list_numbered,
                          size: 48,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.4)),
                      const SizedBox(height: 12),
                      const Text('No rounds yet',
                          style: TextStyle(color: Colors.white38)),
                      if (tournament.status == TournamentStatus.inProgress)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text('Generate the first round to begin',
                              style: TextStyle(color: Colors.white24)),
                        ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: tournament.rounds.length,
                  itemBuilder: (context, index) {
                    // Show rounds newest first.
                    final round =
                        tournament.rounds[tournament.rounds.length - 1 - index];
                    return _RoundSection(
                      round: round,
                      tournament: tournament,
                      playerMap: playerMap,
                      notifier: ref.read(tournamentProvider.notifier),
                    );
                  },
                ),
        ),
        if (tournament.rounds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    builder: (_) => DraggableScrollableSheet(
                      initialChildSize: 0.7,
                      maxChildSize: 0.95,
                      minChildSize: 0.4,
                      builder: (_, controller) => BracketTreeWidget(
                        tournament: tournament,
                        scrollController: controller,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.account_tree, size: 18),
                label: const Text('View Bracket'),
              ),
            ),
          ),
      ],
    );
  }
}

class _RoundSection extends StatelessWidget {
  final TournamentRound round;
  final Tournament tournament;
  final Map<String, String> playerMap;
  final TournamentNotifier notifier;

  const _RoundSection({
    required this.round,
    required this.tournament,
    required this.playerMap,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Row(
            children: [
              Text(
                'Round ${round.roundNumber}',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: round.isComplete
                      ? Colors.green.withOpacity(0.15)
                      : Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  round.isComplete ? 'Complete' : 'In Progress',
                  style: TextStyle(
                    color: round.isComplete
                        ? Colors.green.shade300
                        : Colors.amber.shade300,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...round.pairings.map((pairing) {
          return PairingCard(
            pairing: pairing,
            player1Name: playerMap[pairing.player1Id] ?? 'Unknown',
            player2Name: pairing.isBye
                ? 'BYE'
                : (playerMap[pairing.player2Id] ?? 'Unknown'),
            onReport: (p1w, p2w, isDraw, isComplete) {
              notifier.reportResult(
                tournament.id,
                round.roundNumber,
                pairing.id,
                player1Wins: p1w,
                player2Wins: p2w,
                isDraw: isDraw,
                isComplete: isComplete,
              );
            },
            onReset: () {
              notifier.resetPairing(
                tournament.id,
                round.roundNumber,
                pairing.id,
              );
            },
          );
        }),
      ],
    );
  }
}
