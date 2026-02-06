import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/card_search_provider.dart';

class CardSearchScreen extends ConsumerStatefulWidget {
  const CardSearchScreen({super.key});

  @override
  ConsumerState<CardSearchScreen> createState() => _CardSearchScreenState();
}

class _CardSearchScreenState extends ConsumerState<CardSearchScreen> {
  late TextEditingController _setController;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _setController = TextEditingController(text: 'FDN');
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _setController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cardSearchProvider);
    final notifier = ref.read(cardSearchProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('17Lands'),
      ),
      body: Column(
        children: [
          // Search controls
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    // Set code input
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: _setController,
                        decoration: const InputDecoration(
                          labelText: 'Set',
                          hintText: 'FDN',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 12),
                        ),
                        textCapitalization: TextCapitalization.characters,
                        onChanged: notifier.setExpansion,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Format dropdown
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: state.format,
                        decoration: const InputDecoration(
                          labelText: 'Format',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 12),
                        ),
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                              value: 'PremierDraft',
                              child: Text('Premier Draft')),
                          DropdownMenuItem(
                              value: 'QuickDraft',
                              child: Text('Quick Draft')),
                          DropdownMenuItem(
                              value: 'TradDraft',
                              child: Text('Trad Draft')),
                          DropdownMenuItem(
                              value: 'Sealed',
                              child: Text('Sealed')),
                          DropdownMenuItem(
                              value: 'TradSealed',
                              child: Text('Trad Sealed')),
                        ],
                        onChanged: (v) {
                          if (v != null) notifier.setFormat(v);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Fetch button
                    FilledButton(
                      onPressed: state.isLoading
                          ? null
                          : () {
                              HapticFeedback.mediumImpact();
                              FocusScope.of(context).unfocus();
                              notifier.fetchCards();
                            },
                      child: state.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white70),
                            )
                          : const Text('Fetch'),
                    ),
                  ],
                ),
                if (state.allCards.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  // Card name search
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search ${state.allCards.length} cards...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 12),
                      suffixIcon: state.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                notifier.setSearchQuery('');
                              },
                            )
                          : null,
                    ),
                    onChanged: notifier.setSearchQuery,
                  ),
                ],
              ],
            ),
          ),

          // Sort bar
          if (state.allCards.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              color: Colors.white.withOpacity(0.03),
              child: Row(
                children: [
                  _SortChip(
                    label: 'Name',
                    sortKey: 'name',
                    currentSort: state.sortBy,
                    ascending: state.sortAscending,
                    onTap: () => notifier.setSortBy('name'),
                  ),
                  const Spacer(),
                  _SortChip(
                    label: 'GIH WR',
                    sortKey: 'gihWr',
                    currentSort: state.sortBy,
                    ascending: state.sortAscending,
                    onTap: () => notifier.setSortBy('gihWr'),
                  ),
                  const SizedBox(width: 12),
                  _SortChip(
                    label: 'ATA',
                    sortKey: 'ata',
                    currentSort: state.sortBy,
                    ascending: state.sortAscending,
                    onTap: () => notifier.setSortBy('ata'),
                  ),
                ],
              ),
            ),

          // Results
          Expanded(
            child: _buildBody(context, state),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, CardSearchState state) {
    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: Colors.red.shade300),
              const SizedBox(height: 12),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade300),
              ),
            ],
          ),
        ),
      );
    }

    if (state.allCards.isEmpty && !state.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search,
                size: 64,
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withOpacity(0.4)),
            const SizedBox(height: 16),
            Text('17Lands Card Ratings',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Enter a set code and tap Fetch',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.white54)),
          ],
        ),
      );
    }

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final cards = state.filteredCards;

    if (cards.isEmpty) {
      return Center(
        child: Text('No cards match "${ state.searchQuery}"',
            style: const TextStyle(color: Colors.white54)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return _CardRow(card: card);
      },
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final String sortKey;
  final String currentSort;
  final bool ascending;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.sortKey,
    required this.currentSort,
    required this.ascending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentSort == sortKey;
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white38,
            ),
          ),
          if (isActive)
            Icon(
              ascending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
        ],
      ),
    );
  }
}

class _CardRow extends StatelessWidget {
  final CardRating card;

  const _CardRow({required this.card});

  Color _colorPip() {
    switch (card.color.toUpperCase()) {
      case 'W':
        return const Color(0xFFF9FAF4);
      case 'U':
        return const Color(0xFF0E68AB);
      case 'B':
        return const Color(0xFF150B00);
      case 'R':
        return const Color(0xFFD3202A);
      case 'G':
        return const Color(0xFF00733E);
      default:
        if (card.color.length > 1) return const Color(0xFFC9A96E); // multicolor
        return Colors.grey; // colorless
    }
  }

  Color _rarityColor() {
    switch (card.rarity.toLowerCase()) {
      case 'mythic':
        return const Color(0xFFD35400);
      case 'rare':
        return const Color(0xFFC9A96E);
      case 'uncommon':
        return const Color(0xFFC0C0C0);
      default:
        return Colors.white38; // common
    }
  }

  String _rarityLetter() {
    switch (card.rarity.toLowerCase()) {
      case 'mythic':
        return 'M';
      case 'rare':
        return 'R';
      case 'uncommon':
        return 'U';
      default:
        return 'C';
    }
  }

  Color _winRateColor(double? wr) {
    if (wr == null) return Colors.white38;
    if (wr >= 0.56) return Colors.green.shade300;
    if (wr >= 0.52) return Colors.amber.shade300;
    return Colors.red.shade300;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          // Color pip
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: _colorPip(),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          // Name + rarity
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.name,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: _rarityColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _rarityLetter(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _rarityColor(),
                        ),
                      ),
                    ),
                    if (card.iwd != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        'IWD ${(card.iwd! * 100).toStringAsFixed(1)}pp',
                        style: const TextStyle(
                            fontSize: 11, color: Colors.white38),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // GIH WR
          SizedBox(
            width: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  card.gihWinRate != null
                      ? '${(card.gihWinRate! * 100).toStringAsFixed(1)}%'
                      : '-',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _winRateColor(card.gihWinRate),
                  ),
                ),
                const Text('GIH WR',
                    style: TextStyle(fontSize: 9, color: Colors.white24)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // ATA
          SizedBox(
            width: 36,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  card.avgPick != null
                      ? card.avgPick!.toStringAsFixed(1)
                      : '-',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
                const Text('ATA',
                    style: TextStyle(fontSize: 9, color: Colors.white24)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
