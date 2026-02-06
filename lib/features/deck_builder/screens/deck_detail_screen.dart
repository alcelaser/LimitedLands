import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/deck_list_provider.dart';

class DeckDetailScreen extends ConsumerStatefulWidget {
  final String deckId;

  const DeckDetailScreen({super.key, required this.deckId});

  @override
  ConsumerState<DeckDetailScreen> createState() => _DeckDetailScreenState();
}

class _DeckDetailScreenState extends ConsumerState<DeckDetailScreen> {
  final _cardController = TextEditingController();
  bool _addToSideboard = false;

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  void _addCard() {
    final name = _cardController.text.trim();
    if (name.isEmpty) return;

    HapticFeedback.lightImpact();
    final notifier = ref.read(deckListProvider.notifier);
    if (_addToSideboard) {
      notifier.addCardToSideboard(widget.deckId, name);
    } else {
      notifier.addCardToMainboard(widget.deckId, name);
    }
    _cardController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deckListProvider);
    final deck =
        state.decks.where((d) => d.id == widget.deckId).firstOrNull;

    if (deck == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Deck')),
        body: const Center(child: Text('Deck not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => _showRenameDeckDialog(context, deck),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(deck.name, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.edit, size: 16, color: Colors.white38),
            ],
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'export') _showExportDialog(context, deck);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'export', child: Text('Export as text')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Add card input
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cardController,
                    decoration: InputDecoration(
                      hintText: 'Card name...',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addCard,
                      ),
                    ),
                    onSubmitted: (_) => _addCard(),
                  ),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('SB'),
                  selected: _addToSideboard,
                  onSelected: (v) => setState(() => _addToSideboard = v),
                  selectedColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
              ],
            ),
          ),
          // Card lists
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Mainboard
                _SectionHeader(
                  title: 'Mainboard',
                  count: deck.mainboardCount,
                  targetCount: deck.format == 'Constructed' ? 60 : 40,
                ),
                if (deck.mainboard.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text('No cards yet',
                          style: TextStyle(color: Colors.white38)),
                    ),
                  )
                else
                  ...List.generate(deck.mainboard.length, (i) {
                    final card = deck.mainboard[i];
                    return _CardRow(
                      card: card,
                      onRemove: () {
                        HapticFeedback.lightImpact();
                        ref
                            .read(deckListProvider.notifier)
                            .removeCardFromMainboard(widget.deckId, i);
                      },
                      onAdd: () {
                        HapticFeedback.lightImpact();
                        ref
                            .read(deckListProvider.notifier)
                            .addCardToMainboard(widget.deckId, card.name);
                      },
                    );
                  }),
                const SizedBox(height: 16),
                // Sideboard
                _SectionHeader(
                  title: 'Sideboard',
                  count: deck.sideboardCount,
                ),
                if (deck.sideboard.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text('No sideboard cards',
                          style: TextStyle(color: Colors.white38)),
                    ),
                  )
                else
                  ...List.generate(deck.sideboard.length, (i) {
                    final card = deck.sideboard[i];
                    return _CardRow(
                      card: card,
                      onRemove: () {
                        HapticFeedback.lightImpact();
                        ref
                            .read(deckListProvider.notifier)
                            .removeCardFromSideboard(widget.deckId, i);
                      },
                      onAdd: () {
                        HapticFeedback.lightImpact();
                        ref
                            .read(deckListProvider.notifier)
                            .addCardToSideboard(widget.deckId, card.name);
                      },
                    );
                  }),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRenameDeckDialog(BuildContext context, Deck deck) {
    final controller = TextEditingController(text: deck.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Deck'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Deck Name',
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
                    .read(deckListProvider.notifier)
                    .updateDeck(deck.copyWith(name: name));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context, Deck deck) {
    final buffer = StringBuffer();
    buffer.writeln('// ${deck.name} (${deck.format})');
    buffer.writeln('// Mainboard (${deck.mainboardCount})');
    for (final card in deck.mainboard) {
      buffer.writeln('${card.quantity} ${card.name}');
    }
    if (deck.sideboard.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('// Sideboard (${deck.sideboardCount})');
      for (final card in deck.sideboard) {
        buffer.writeln('${card.quantity} ${card.name}');
      }
    }
    final text = buffer.toString();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Deck list copied to clipboard')),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final int? targetCount;

  const _SectionHeader({
    required this.title,
    required this.count,
    this.targetCount,
  });

  @override
  Widget build(BuildContext context) {
    final isComplete = targetCount != null && count >= targetCount!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Row(
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: isComplete
                  ? Colors.green.withOpacity(0.15)
                  : Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              targetCount != null ? '$count / $targetCount' : '$count',
              style: TextStyle(
                color: isComplete
                    ? Colors.green.shade300
                    : Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardRow extends StatelessWidget {
  final DeckCard card;
  final VoidCallback onRemove;
  final VoidCallback onAdd;

  const _CardRow({
    required this.card,
    required this.onRemove,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${card.quantity}x',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(card.name,
                style: Theme.of(context).textTheme.bodyLarge),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            color: Colors.white38,
            onPressed: onRemove,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            color: Colors.white38,
            onPressed: onAdd,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
