import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/match_tracker_provider.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(matchTrackerProvider);
    final notifier = ref.read(matchTrackerProvider.notifier);
    final event =
        state.events.where((e) => e.id == widget.eventId).firstOrNull;

    if (event == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Event not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => _showRenameDialog(context, notifier, event),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(event.name, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.edit, size: 16, color: Colors.white38),
            ],
          ),
        ),
        actions: [
          if (event.matchCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _recordColor(event).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    event.record,
                    style: TextStyle(
                      color: _recordColor(event),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: event.matches.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sports_esports_outlined,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.4)),
                  const SizedBox(height: 16),
                  Text('No rounds yet',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Tap + to add your first round',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.white54)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: event.matches.length,
              itemBuilder: (context, index) {
                final match = event.matches[index];
                return _MatchCard(
                  match: match,
                  eventId: widget.eventId,
                  notifier: notifier,
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          notifier.addMatch(widget.eventId);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _recordColor(Event event) {
    if (event.matchCount == 0) return Colors.white38;
    if (event.wins > event.losses) return Colors.green.shade300;
    if (event.losses > event.wins) return Colors.red.shade300;
    return Colors.amber.shade300;
  }

  void _showRenameDialog(
      BuildContext context, MatchTrackerNotifier notifier, Event event) {
    final controller = TextEditingController(text: event.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Event'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Event Name',
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
                notifier.updateEvent(event.copyWith(name: name));
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

class _MatchCard extends StatelessWidget {
  final MatchRecord match;
  final String eventId;
  final MatchTrackerNotifier notifier;

  const _MatchCard({
    required this.match,
    required this.eventId,
    required this.notifier,
  });

  Color _resultColor() {
    switch (match.result) {
      case MatchResult.win:
        return Colors.green.shade300;
      case MatchResult.loss:
        return Colors.red.shade300;
      case MatchResult.draw:
        return Colors.amber.shade300;
      case MatchResult.inProgress:
        return Colors.white38;
    }
  }

  String _resultLabel() {
    switch (match.result) {
      case MatchResult.win:
        return 'W';
      case MatchResult.loss:
        return 'L';
      case MatchResult.draw:
        return 'D';
      case MatchResult.inProgress:
        return '...';
    }
  }

  IconData _resultIcon() {
    switch (match.result) {
      case MatchResult.win:
        return Icons.check_circle;
      case MatchResult.loss:
        return Icons.cancel;
      case MatchResult.draw:
        return Icons.remove_circle;
      case MatchResult.inProgress:
        return Icons.radio_button_unchecked;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _resultColor();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: round number, opponent, result badge
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'R${match.roundNumber}',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showOpponentDialog(context),
                    child: Text(
                      match.opponentName.isEmpty
                          ? 'Tap to set opponent'
                          : match.opponentName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: match.opponentName.isEmpty
                                ? Colors.white38
                                : Colors.white,
                            fontStyle: match.opponentName.isEmpty
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                    ),
                  ),
                ),
                // Result badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_resultIcon(), size: 16, color: color),
                      const SizedBox(width: 4),
                      Text(
                        _resultLabel(),
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Game score and action buttons
            Row(
              children: [
                // Game score display
                Text(
                  '${match.gamesWon} - ${match.gamesLost}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
                const Spacer(),
                // Action buttons
                if (!match.isDraw) ...[
                  _ActionButton(
                    label: 'Game Win',
                    icon: Icons.add_circle_outline,
                    color: Colors.green.shade300,
                    onTap: match.isComplete
                        ? null
                        : () {
                            HapticFeedback.lightImpact();
                            notifier.recordGameWin(eventId, match.id);
                          },
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    label: 'Game Loss',
                    icon: Icons.remove_circle_outline,
                    color: Colors.red.shade300,
                    onTap: match.isComplete
                        ? null
                        : () {
                            HapticFeedback.lightImpact();
                            notifier.recordGameLoss(eventId, match.id);
                          },
                  ),
                  const SizedBox(width: 8),
                ],
                // Draw toggle
                _ActionButton(
                  label: match.isDraw ? 'Undo Draw' : 'Draw',
                  icon: match.isDraw
                      ? Icons.undo
                      : Icons.horizontal_rule,
                  color: Colors.amber.shade300,
                  isActive: match.isDraw,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    notifier.toggleDraw(eventId, match.id);
                  },
                ),
                const SizedBox(width: 8),
                // Reset / Delete
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert,
                      color: Colors.white38, size: 20),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'reset', child: Text('Reset Match')),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete Round',
                          style: TextStyle(color: Colors.red.shade300)),
                    ),
                  ],
                  onSelected: (value) {
                    HapticFeedback.mediumImpact();
                    if (value == 'reset') {
                      notifier.resetMatch(eventId, match.id);
                    } else if (value == 'delete') {
                      notifier.removeMatch(eventId, match.id);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOpponentDialog(BuildContext context) {
    final controller = TextEditingController(text: match.opponentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Opponent Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'e.g. Player 2',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              notifier.updateMatch(
                eventId,
                match.copyWith(opponentName: controller.text.trim()),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isActive;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final displayColor = enabled ? color : color.withOpacity(0.3);

    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isActive ? displayColor : displayColor.withOpacity(0.5),
              ),
              color: isActive ? displayColor.withOpacity(0.15) : null,
            ),
            child: Icon(icon, color: displayColor, size: 18),
          ),
        ),
      ),
    );
  }
}
