import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tournament_models.dart';
import '../providers/tournament_provider.dart';

class PlayersSection extends ConsumerStatefulWidget {
  final String tournamentId;

  const PlayersSection({super.key, required this.tournamentId});

  @override
  ConsumerState<PlayersSection> createState() => _PlayersSectionState();
}

class _PlayersSectionState extends ConsumerState<PlayersSection> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addPlayer() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    HapticFeedback.lightImpact();
    ref.read(tournamentProvider.notifier).addPlayer(
          widget.tournamentId,
          name,
        );
    _nameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tournamentProvider);
    final tournament = state.tournaments
        .where((t) => t.id == widget.tournamentId)
        .firstOrNull;

    if (tournament == null) {
      return const Center(child: Text('Tournament not found'));
    }

    final isSetup = tournament.status == TournamentStatus.setup;

    return Column(
      children: [
        if (isSetup)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Player name',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    textCapitalization: TextCapitalization.words,
                    onSubmitted: (_) => _addPlayer(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _addPlayer,
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
          ),
        Expanded(
          child: tournament.players.isEmpty
              ? Center(
                  child: Text(
                    isSetup
                        ? 'Add at least 2 players to start'
                        : 'No players',
                    style: const TextStyle(color: Colors.white38),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: tournament.players.length,
                  itemBuilder: (context, index) {
                    final player = tournament.players[index];
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.15),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      title: Text(player.name),
                      trailing: isSetup
                          ? IconButton(
                              icon: Icon(Icons.remove_circle_outline,
                                  color: Colors.red.shade300,
                                  size: 20),
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                ref
                                    .read(tournamentProvider.notifier)
                                    .removePlayer(
                                      widget.tournamentId,
                                      player.id,
                                    );
                              },
                            )
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }
}
