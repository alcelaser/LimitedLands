import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/tournament_models.dart';

class PairingCard extends StatelessWidget {
  final TournamentPairing pairing;
  final String player1Name;
  final String player2Name;
  final void Function(int p1Wins, int p2Wins, bool isDraw, bool isComplete)?
      onReport;
  final VoidCallback? onReset;

  const PairingCard({
    super.key,
    required this.pairing,
    required this.player1Name,
    required this.player2Name,
    this.onReport,
    this.onReset,
  });

  Color _resultColor() {
    if (!pairing.isComplete) return Colors.white38;
    if (pairing.isDraw) return Colors.amber.shade300;
    if (pairing.isBye) return Colors.blue.shade300;
    if (pairing.player1Wins > pairing.player2Wins) {
      return Colors.green.shade300;
    }
    return Colors.red.shade300;
  }

  String _resultLabel() {
    if (!pairing.isComplete) return '...';
    if (pairing.isDraw) return 'Draw';
    if (pairing.isBye) return 'BYE';
    if (pairing.player1Wins > pairing.player2Wins) {
      return '$player1Name wins';
    }
    return '$player2Name wins';
  }

  @override
  Widget build(BuildContext context) {
    final color = _resultColor();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Player names row
            Row(
              children: [
                Expanded(
                  child: Text(
                    player1Name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (pairing.isBye)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade300.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('BYE',
                        style: TextStyle(
                          color: Colors.blue.shade300,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        )),
                  )
                else ...[
                  const Text('vs',
                      style: TextStyle(color: Colors.white38, fontSize: 12)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      player2Name,
                      textAlign: TextAlign.end,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
            if (!pairing.isBye) ...[
              const SizedBox(height: 8),
              // Score and actions row
              Row(
                children: [
                  Text(
                    '${pairing.player1Wins} - ${pairing.player2Wins}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  ),
                  const Spacer(),
                  if (!pairing.isComplete && onReport != null) ...[
                    _ScoreButton(
                      label: '+${player1Name.split(' ').first}',
                      color: Colors.green.shade300,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        final p1w = pairing.player1Wins + 1;
                        final autoComplete = p1w >= 2;
                        onReport!(
                            p1w, pairing.player2Wins, false, autoComplete);
                      },
                    ),
                    const SizedBox(width: 6),
                    _ScoreButton(
                      label: '+${player2Name.split(' ').first}',
                      color: Colors.red.shade300,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        final p2w = pairing.player2Wins + 1;
                        final autoComplete = p2w >= 2;
                        onReport!(
                            pairing.player1Wins, p2w, false, autoComplete);
                      },
                    ),
                    const SizedBox(width: 6),
                    _ScoreButton(
                      label: 'Draw',
                      color: Colors.amber.shade300,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onReport!(pairing.player1Wins, pairing.player2Wins,
                            true, true);
                      },
                    ),
                    const SizedBox(width: 6),
                    _ScoreButton(
                      label: 'Done',
                      color: Theme.of(context).colorScheme.primary,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onReport!(pairing.player1Wins, pairing.player2Wins,
                            false, true);
                      },
                    ),
                  ] else if (pairing.isComplete) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _resultLabel(),
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (onReset != null)
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert,
                            color: Colors.white38, size: 18),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'reset',
                            child: Text('Reset Result'),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'reset') {
                            HapticFeedback.lightImpact();
                            onReset!();
                          }
                        },
                      ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScoreButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ScoreButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
