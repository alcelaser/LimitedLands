import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/deck_list_provider.dart';
import 'deck_detail_screen.dart';

class DeckListScreen extends ConsumerStatefulWidget {
  const DeckListScreen({super.key});

  @override
  ConsumerState<DeckListScreen> createState() => _DeckListScreenState();
}

class _DeckListScreenState extends ConsumerState<DeckListScreen> {
  final Set<String> _expandedFolders = {};

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deckListProvider);
    final notifier = ref.read(deckListProvider.notifier);

    // Compute unfiled decks (not in any folder)
    final filedDeckIds =
        state.folders.expand((f) => f.deckIds).toSet();
    final unfiledDecks =
        state.decks.where((d) => !filedDeckIds.contains(d.id)).toList();

    final hasContent = state.decks.isNotEmpty || state.folders.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Deck Lists')),
      body: !hasContent
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.style_outlined,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.4)),
                  const SizedBox(height: 16),
                  Text('No decks yet',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Tap + to create your first deck',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.white54)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Folders
                for (final folder in state.folders) ...[
                  _buildFolderCard(context, notifier, state, folder),
                ],
                // Unfiled section header
                if (state.folders.isNotEmpty && unfiledDecks.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Text('Unfiled',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(color: Colors.white54)),
                  ),
                // Unfiled decks
                for (final deck in unfiledDecks)
                  _DeckCard(
                    deck: deck,
                    onTap: () => _navigateToDeck(context, deck),
                    onDelete: () =>
                        _showDeleteDeckDialog(context, notifier, deck),
                    trailing: state.folders.isNotEmpty
                        ? PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert,
                                color: Colors.white38, size: 20),
                            onSelected: (value) {
                              if (value == 'move') {
                                _showMoveDeckDialog(
                                    context, notifier, state, deck);
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'move',
                                child: Text('Move to folder'),
                              ),
                            ],
                          )
                        : null,
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          _showCreateOptions(context, notifier);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFolderCard(BuildContext context, DeckListNotifier notifier,
      DeckListState state, DeckFolder folder) {
    final isExpanded = _expandedFolders.contains(folder.id);
    final folderDecks = state.decks
        .where((d) => folder.deckIds.contains(d.id))
        .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                if (isExpanded) {
                  _expandedFolders.remove(folder.id);
                } else {
                  _expandedFolders.add(folder.id);
                }
              });
            },
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(12),
              bottom: isExpanded
                  ? Radius.zero
                  : const Radius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.folder,
                        color: Colors.amber),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(folder.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          '${folderDecks.length} ${folderDecks.length == 1 ? 'deck' : 'decks'}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        color: Colors.white38, size: 20),
                    onSelected: (value) {
                      if (value == 'rename') {
                        _showRenameFolderDialog(
                            context, notifier, folder);
                      } else if (value == 'delete') {
                        _showDeleteFolderDialog(
                            context, notifier, folder);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'rename',
                        child: Text('Rename'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete folder'),
                      ),
                    ],
                  ),
                  Icon(
                    isExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: Colors.white38,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            if (folderDecks.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No decks in this folder',
                    style: TextStyle(color: Colors.white38)),
              )
            else
              ...folderDecks.map((deck) => _DeckCard(
                    deck: deck,
                    onTap: () => _navigateToDeck(context, deck),
                    onDelete: () =>
                        _showDeleteDeckDialog(context, notifier, deck),
                    inFolder: true,
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert,
                          color: Colors.white38, size: 20),
                      onSelected: (value) {
                        if (value == 'remove') {
                          HapticFeedback.lightImpact();
                          notifier.removeDeckFromFolder(deck.id);
                        } else if (value == 'move') {
                          _showMoveDeckDialog(
                              context, notifier, state, deck);
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'remove',
                          child: Text('Remove from folder'),
                        ),
                        if (state.folders.length > 1)
                          const PopupMenuItem(
                            value: 'move',
                            child: Text('Move to another folder'),
                          ),
                      ],
                    ),
                  )),
          ],
        ],
      ),
    );
  }

  void _navigateToDeck(BuildContext context, Deck deck) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DeckDetailScreen(deckId: deck.id),
      ),
    );
  }

  void _showCreateOptions(
      BuildContext context, DeckListNotifier notifier) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.style),
              title: const Text('New Deck'),
              onTap: () {
                Navigator.pop(ctx);
                _showCreateDeckDialog(context, notifier);
              },
            ),
            ListTile(
              leading: const Icon(Icons.create_new_folder),
              title: const Text('New Folder'),
              onTap: () {
                Navigator.pop(ctx);
                _showCreateFolderDialog(context, notifier);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateDeckDialog(
      BuildContext context, DeckListNotifier notifier) {
    final nameController = TextEditingController(text: 'New Deck');
    String format = 'Limited';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Create Deck'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Deck Name',
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
                final deck = notifier.createDeck(
                  name: nameController.text.trim().isEmpty
                      ? 'New Deck'
                      : nameController.text.trim(),
                  format: format,
                );
                Navigator.pop(ctx);
                _navigateToDeck(context, deck);
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateFolderDialog(
      BuildContext context, DeckListNotifier notifier) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Folder'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Folder name',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
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
                notifier.createFolder(name);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showRenameFolderDialog(BuildContext context,
      DeckListNotifier notifier, DeckFolder folder) {
    final controller = TextEditingController(text: folder.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Folder'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Folder Name',
          ),
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
                notifier.renameFolder(folder.id, name);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeleteFolderDialog(BuildContext context,
      DeckListNotifier notifier, DeckFolder folder) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Folder'),
        content: Text(
            'Delete "${folder.name}"? Decks inside will become unfiled.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              notifier.deleteFolder(folder.id);
              Navigator.pop(ctx);
            },
            child: Text('Delete',
                style: TextStyle(color: Colors.red.shade300)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDeckDialog(
      BuildContext context, DeckListNotifier notifier, Deck deck) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Deck'),
        content:
            Text('Delete "${deck.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              notifier.deleteDeck(deck.id);
              Navigator.pop(ctx);
            },
            child: Text('Delete',
                style: TextStyle(color: Colors.red.shade300)),
          ),
        ],
      ),
    );
  }

  void _showMoveDeckDialog(BuildContext context,
      DeckListNotifier notifier, DeckListState state, Deck deck) {
    final currentFolderId = notifier.folderForDeck(deck.id);

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('Move "${deck.name}" to...',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            for (final folder in state.folders)
              if (folder.id != currentFolderId)
                ListTile(
                  leading: const Icon(Icons.folder),
                  title: Text(folder.name),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    notifier.moveDeckToFolder(deck.id, folder.id);
                    Navigator.pop(ctx);
                  },
                ),
            if (currentFolderId != null)
              ListTile(
                leading: const Icon(Icons.folder_off),
                title: const Text('Remove from folder'),
                onTap: () {
                  HapticFeedback.lightImpact();
                  notifier.removeDeckFromFolder(deck.id);
                  Navigator.pop(ctx);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DeckCard extends StatelessWidget {
  final Deck deck;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool inFolder;
  final Widget? trailing;

  const _DeckCard({
    required this.deck,
    required this.onTap,
    required this.onDelete,
    this.inFolder = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final content = InkWell(
      onTap: onTap,
      borderRadius: inFolder ? null : BorderRadius.circular(12),
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
              child: Icon(Icons.style,
                  color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(deck.name,
                      style:
                          Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _InfoChip(label: deck.format),
                      const SizedBox(width: 8),
                      _InfoChip(
                          label: '${deck.mainboardCount} cards'),
                      if (deck.sideboardCount > 0) ...[
                        const SizedBox(width: 8),
                        _InfoChip(
                            label: '${deck.sideboardCount} SB'),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline,
                  color: Colors.red.shade300, size: 20),
              onPressed: onDelete,
            ),
            if (trailing != null)
              trailing!
            else
              const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );

    if (inFolder) return content;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: content,
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
