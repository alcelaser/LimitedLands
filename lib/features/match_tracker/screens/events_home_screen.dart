import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/match_tracker_provider.dart';
import '../providers/tournament_provider.dart';
import '../screens/event_detail_screen.dart';
import '../screens/tournament_detail_screen.dart';
import '../widgets/my_matches_tab.dart';
import '../widgets/organize_tab.dart';

class EventsHomeScreen extends ConsumerStatefulWidget {
  const EventsHomeScreen({super.key});

  @override
  ConsumerState<EventsHomeScreen> createState() => _EventsHomeScreenState();
}

class _EventsHomeScreenState extends ConsumerState<EventsHomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.person_outline, size: 20),
              text: 'My Matches',
            ),
            Tab(
              icon: Icon(Icons.emoji_events_outlined, size: 20),
              text: 'Organize',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          MyMatchesTab(
              onCreateEvent: () => _showCreateEventDialog(context)),
          OrganizeTab(
              onCreateTournament: () =>
                  _showCreateTournamentDialog(context)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          if (_tabController.index == 0) {
            _showCreateEventDialog(context);
          } else {
            _showCreateTournamentDialog(context);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateEventDialog(BuildContext context) {
    final nameController = TextEditingController();
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
                  DropdownMenuItem(
                      value: 'Limited', child: Text('Limited')),
                  DropdownMenuItem(
                      value: 'Sealed', child: Text('Sealed')),
                  DropdownMenuItem(
                      value: 'Vintage Cube',
                      child: Text('Vintage Cube')),
                  DropdownMenuItem(
                      value: 'Constructed',
                      child: Text('Constructed')),
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
                final notifier =
                    ref.read(matchTrackerProvider.notifier);
                final event = notifier.createEvent(
                  name: nameController.text.trim().isEmpty
                      ? 'New Event'
                      : nameController.text.trim(),
                  format: format,
                );
                Navigator.pop(ctx);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        EventDetailScreen(eventId: event.id),
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

  void _showCreateTournamentDialog(BuildContext context) {
    final nameController = TextEditingController();
    final roundsController = TextEditingController(text: '3');
    String format = 'Limited';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('New Tournament'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tournament Name',
                  hintText: 'e.g. FNM Swiss, Store Championship',
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
                  DropdownMenuItem(
                      value: 'Limited', child: Text('Limited')),
                  DropdownMenuItem(
                      value: 'Sealed', child: Text('Sealed')),
                  DropdownMenuItem(
                      value: 'Vintage Cube',
                      child: Text('Vintage Cube')),
                  DropdownMenuItem(
                      value: 'Constructed',
                      child: Text('Constructed')),
                ],
                onChanged: (v) => setDialogState(() => format = v!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: roundsController,
                decoration: const InputDecoration(
                  labelText: 'Number of Rounds',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
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
                final notifier =
                    ref.read(tournamentProvider.notifier);
                final tournament = notifier.createTournament(
                  name: nameController.text.trim().isEmpty
                      ? 'New Tournament'
                      : nameController.text.trim(),
                  format: format,
                  totalRounds:
                      int.tryParse(roundsController.text) ?? 3,
                );
                Navigator.pop(ctx);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TournamentDetailScreen(
                        tournamentId: tournament.id),
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
