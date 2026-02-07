import 'package:flutter/material.dart';
import '../models/tournament_models.dart';

class BracketTreeWidget extends StatelessWidget {
  final Tournament tournament;
  final ScrollController? scrollController;

  const BracketTreeWidget({
    super.key,
    required this.tournament,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final playerMap = {
      for (final p in tournament.players) p.id: p.name
    };

    return Column(
      children: [
        // Drag handle
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.account_tree,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Swiss Bracket',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '${tournament.currentRoundNumber}/${tournament.totalRounds} rounds',
                style: const TextStyle(
                    color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: tournament.rounds.isEmpty
              ? const Center(
                  child: Text('No rounds yet',
                      style: TextStyle(color: Colors.white38)),
                )
              : SingleChildScrollView(
                  controller: scrollController,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: tournament.rounds.map((round) {
                          return _RoundColumn(
                            round: round,
                            playerMap: playerMap,
                            isLast: round.roundNumber ==
                                tournament.rounds.length,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _RoundColumn extends StatelessWidget {
  final TournamentRound round;
  final Map<String, String> playerMap;
  final bool isLast;

  const _RoundColumn({
    required this.round,
    required this.playerMap,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Padding(
        padding: EdgeInsets.only(right: isLast ? 0 : 12),
        child: Column(
          children: [
            // Round header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Round ${round.roundNumber}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Pairing cards
            ...round.pairings.map((pairing) {
              return _BracketPairingCard(
                pairing: pairing,
                playerMap: playerMap,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _BracketPairingCard extends StatelessWidget {
  final TournamentPairing pairing;
  final Map<String, String> playerMap;

  const _BracketPairingCard({
    required this.pairing,
    required this.playerMap,
  });

  @override
  Widget build(BuildContext context) {
    final p1Name = playerMap[pairing.player1Id] ?? 'Unknown';
    final p2Name = pairing.isBye
        ? 'BYE'
        : (playerMap[pairing.player2Id] ?? 'Unknown');
    final p1Won = pairing.isComplete &&
        !pairing.isDraw &&
        (pairing.isBye ||
            pairing.player1Wins > pairing.player2Wins);
    final p2Won = pairing.isComplete &&
        !pairing.isDraw &&
        !pairing.isBye &&
        pairing.player2Wins > pairing.player1Wins;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _BracketPlayerRow(
            name: p1Name,
            score: pairing.isBye ? '2' : '${pairing.player1Wins}',
            isWinner: p1Won,
          ),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.06),
          ),
          _BracketPlayerRow(
            name: p2Name,
            score: pairing.isBye ? '-' : '${pairing.player2Wins}',
            isWinner: p2Won,
            isBye: pairing.isBye,
          ),
        ],
      ),
    );
  }
}

class _BracketPlayerRow extends StatelessWidget {
  final String name;
  final String score;
  final bool isWinner;
  final bool isBye;

  const _BracketPlayerRow({
    required this.name,
    required this.score,
    this.isWinner = false,
    this.isBye = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 6),
      child: Row(
        children: [
          if (isWinner)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(Icons.check,
                  size: 12, color: Colors.green.shade300),
            ),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    isWinner ? FontWeight.bold : FontWeight.normal,
                color: isBye
                    ? Colors.white24
                    : isWinner
                        ? Colors.white
                        : Colors.white70,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            score,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isWinner
                  ? Colors.green.shade300
                  : Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}
