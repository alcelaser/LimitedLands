import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/scryfall_image_service.dart';
import '../../../core/widgets/card_image_dialog.dart';
import '../providers/deck_list_provider.dart';
import '../providers/scryfall_provider.dart';

class DeckDetailScreen extends ConsumerStatefulWidget {
  final String deckId;

  const DeckDetailScreen({super.key, required this.deckId});

  @override
  ConsumerState<DeckDetailScreen> createState() => _DeckDetailScreenState();
}

class _DeckDetailScreenState extends ConsumerState<DeckDetailScreen> {
  final _cardController = TextEditingController();
  final _cardFocusNode = FocusNode();
  bool _addToSideboard = false;
  bool _imageViewMode = false;
  bool _isResolvingSetNumber = false;

  @override
  void dispose() {
    _cardController.dispose();
    _cardFocusNode.dispose();
    super.dispose();
  }

  void _addCardByName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    // Check if input is a set+number pattern like "FDN 123" or "FDN/123"
    final parsed = ScryfallImageService.parseSetNumber(trimmed);
    if (parsed != null) {
      final (setCode, collectorNumber) = parsed;
      setState(() => _isResolvingSetNumber = true);
      _cardController.clear();
      ref.read(scryfallAutocompleteProvider.notifier).clear();

      final resolvedName =
          await ScryfallImageService.resolveCardName(setCode, collectorNumber);
      if (!mounted) return;
      setState(() => _isResolvingSetNumber = false);

      if (resolvedName != null) {
        HapticFeedback.lightImpact();
        final notifier = ref.read(deckListProvider.notifier);
        if (_addToSideboard) {
          notifier.addCardToSideboard(widget.deckId, resolvedName);
        } else {
          notifier.addCardToMainboard(widget.deckId, resolvedName);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added: $resolvedName'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Card not found: ${setCode.toUpperCase()} #$collectorNumber'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
      return;
    }

    // Normal card name flow
    HapticFeedback.lightImpact();
    final notifier = ref.read(deckListProvider.notifier);
    if (_addToSideboard) {
      notifier.addCardToSideboard(widget.deckId, trimmed);
    } else {
      notifier.addCardToMainboard(widget.deckId, trimmed);
    }
    _cardController.clear();
    ref.read(scryfallAutocompleteProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deckListProvider);
    final autocompleteState = ref.watch(scryfallAutocompleteProvider);
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
          IconButton(
            icon: Icon(_imageViewMode ? Icons.view_list : Icons.grid_view),
            tooltip: _imageViewMode ? 'List view' : 'Image view',
            onPressed: () => setState(() => _imageViewMode = !_imageViewMode),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _exportDeck(context, deck, value),
            itemBuilder: (context) => const [
              PopupMenuItem(
                  value: 'mtgo', child: Text('Export MTGO/Arena')),
              PopupMenuItem(
                  value: 'csv', child: Text('Export CSV')),
              PopupMenuItem(
                  value: 'text', child: Text('Export Text')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Add card input with autocomplete
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: RawAutocomplete<String>(
                    textEditingController: _cardController,
                    focusNode: _cardFocusNode,
                    optionsBuilder: (textEditingValue) {
                      final query = textEditingValue.text.trim();
                      ref
                          .read(scryfallAutocompleteProvider.notifier)
                          .search(query);
                      if (query.length < 2) return const [];
                      return autocompleteState.suggestions;
                    },
                    onSelected: (selection) {
                      _addCardByName(selection);
                    },
                    fieldViewBuilder: (context, controller, focusNode,
                        onFieldSubmitted) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          hintText: 'Card name or SET 123...',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          suffixIcon: _isResolvingSetNumber
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () =>
                                      _addCardByName(controller.text),
                                ),
                        ),
                        onSubmitted: (_) =>
                            _addCardByName(controller.text),
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xFF252540),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                                maxHeight: 240, maxWidth: 400),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final option = options.elementAt(index);
                                return InkWell(
                                  onTap: () => onSelected(option),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    child: Text(
                                      option,
                                      style: const TextStyle(
                                          color: Colors.white),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
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
            child: _imageViewMode
                ? _buildImageGridView(deck)
                : _buildTextListView(deck),
          ),
        ],
      ),
    );
  }

  Widget _buildTextListView(Deck deck) {
    return ListView(
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
              onTap: () => CardImageDialog.show(context, card.name),
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
              onTap: () => CardImageDialog.show(context, card.name),
            );
          }),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildImageGridView(Deck deck) {
    if (deck.mainboard.isEmpty && deck.sideboard.isEmpty) {
      return const Center(
        child: Text('No cards yet', style: TextStyle(color: Colors.white38)),
      );
    }

    return CustomScrollView(
      slivers: [
        if (deck.mainboard.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _SectionHeader(
                title: 'Mainboard',
                count: deck.mainboardCount,
                targetCount: deck.format == 'Constructed' ? 60 : 40,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 488.0 / 680.0,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final card = deck.mainboard[index];
                  return _CardImageTile(
                    card: card,
                    onTap: () => CardImageDialog.show(context, card.name),
                  );
                },
                childCount: deck.mainboard.length,
              ),
            ),
          ),
        ],
        if (deck.sideboard.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _SectionHeader(
                title: 'Sideboard',
                count: deck.sideboardCount,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 488.0 / 680.0,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final card = deck.sideboard[index];
                  return _CardImageTile(
                    card: card,
                    onTap: () => CardImageDialog.show(context, card.name),
                  );
                },
                childCount: deck.sideboard.length,
              ),
            ),
          ),
        ],
        const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
      ],
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

  void _exportDeck(BuildContext context, Deck deck, String format) {
    final String text;
    final String label;

    switch (format) {
      case 'mtgo':
        text = _exportMtgo(deck);
        label = 'MTGO/Arena deck list copied';
        break;
      case 'csv':
        text = _exportCsv(deck);
        label = 'CSV deck list copied';
        break;
      default:
        text = _exportText(deck);
        label = 'Deck list copied';
    }

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(label)),
    );
  }

  String _exportMtgo(Deck deck) {
    final buffer = StringBuffer();
    for (final card in deck.mainboard) {
      buffer.writeln('${card.quantity} ${card.name}');
    }
    if (deck.sideboard.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('Sideboard');
      for (final card in deck.sideboard) {
        buffer.writeln('${card.quantity} ${card.name}');
      }
    }
    return buffer.toString();
  }

  String _exportCsv(Deck deck) {
    final buffer = StringBuffer();
    buffer.writeln('Quantity,Name,Board');
    for (final card in deck.mainboard) {
      buffer.writeln('${card.quantity},${card.name},Mainboard');
    }
    for (final card in deck.sideboard) {
      buffer.writeln('${card.quantity},${card.name},Sideboard');
    }
    return buffer.toString();
  }

  String _exportText(Deck deck) {
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
    return buffer.toString();
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
  final VoidCallback? onTap;

  const _CardRow({
    required this.card,
    required this.onRemove,
    required this.onAdd,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
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
      ),
    );
  }
}

class _CardImageTile extends StatelessWidget {
  final DeckCard card;
  final VoidCallback onTap;

  const _CardImageTile({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                imageUrl: ScryfallImageService.imageUrlFromName(card.name),
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: const Color(0xFF252540),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: const Color(0xFF252540),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        card.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 9, color: Colors.white38),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (card.quantity > 1)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${card.quantity}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
