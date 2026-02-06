import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/match_tracker_provider.dart';
import 'event_detail_screen.dart';

class MatchTrackerScreen extends ConsumerWidget {
  const MatchTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(matchTrackerProvider);
    final notifier = ref.read(matchTrackerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Tracker'),
      ),
      body: state.events.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.scoreboard_outlined,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.4)),
                  const SizedBox(height: 16),
                  Text('No events yet',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Tap + to start tracking an event',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.white54)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.events.length,
              itemBuilder: (context, index) {
                final event = state.events[index];
                return _EventCard(
                  event: event,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EventDetailScreen(eventId: event.id),
                    ),
                  ),
                  onDelete: () {
                    HapticFeedback.mediumImpact();
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Event'),
                        content: Text(
                            'Delete "${event.name}"? This cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              notifier.deleteEvent(event.id);
                              Navigator.pop(ctx);
                            },
                            child: Text('Delete',
                                style:
                                    TextStyle(color: Colors.red.shade300)),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          _showCreateEventDialog(context, notifier);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateEventDialog(
      BuildContext context, MatchTrackerNotifier notifier) {
    final nameController = TextEditingController(text: '');
    String format = 'Limited';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('New Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Event Name',
                  hintText: 'e.g. FNM Draft, GP Sealed',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: format,
                decoration: const InputDecoration(
                  labelText: 'Format',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Limited', child: Text('Limited')),
                  DropdownMenuItem(value: 'Sealed', child: Text('Sealed')),
                  DropdownMenuItem(
                      value: 'Vintage Cube', child: Text('Vintage Cube')),
                  DropdownMenuItem(
                      value: 'Constructed', child: Text('Constructed')),
                ],
                onChanged: (v) => setDialogState(() => format = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final event = notifier.createEvent(
                  name: nameController.text.trim().isEmpty
                      ? 'New Event'
                      : nameController.text.trim(),
                  format: format,
                );
                Navigator.pop(ctx);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EventDetailScreen(eventId: event.id),
                  ),
                );
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _EventCard({
    required this.event,
    required this.onTap,
    required this.onDelete,
  });

  Color _recordColor(BuildContext context) {
    if (event.matchCount == 0) return Colors.white38;
    if (event.wins > event.losses) return Colors.green.shade300;
    if (event.losses > event.wins) return Colors.red.shade300;
    return Colors.amber.shade300;
  }

  @override
  Widget build(BuildContext context) {
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
                child: Icon(Icons.scoreboard,
                    color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.name,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _InfoChip(label: event.format),
                        const SizedBox(width: 8),
                        _InfoChip(
                            label:
                                '${event.matchCount} ${event.matchCount == 1 ? 'round' : 'rounds'}'),
                      ],
                    ),
                  ],
                ),
              ),
              if (event.matchCount > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _recordColor(context).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    event.record,
                    style: TextStyle(
                      color: _recordColor(context),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
