import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _storageKey = 'deck_list_v1';

class DeckCard {
  final String name;
  final int quantity;

  const DeckCard({required this.name, this.quantity = 1});

  DeckCard copyWith({String? name, int? quantity}) {
    return DeckCard(name: name ?? this.name, quantity: quantity ?? this.quantity);
  }

  Map<String, dynamic> toJson() => {'name': name, 'quantity': quantity};

  factory DeckCard.fromJson(Map<String, dynamic> json) {
    return DeckCard(
      name: json['name'] as String,
      quantity: json['quantity'] as int? ?? 1,
    );
  }
}

class Deck {
  final String id;
  final String name;
  final String format;
  final List<DeckCard> mainboard;
  final List<DeckCard> sideboard;
  final DateTime createdAt;
  final DateTime updatedAt;

  Deck({
    required this.id,
    required this.name,
    this.format = 'Limited',
    this.mainboard = const [],
    this.sideboard = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  int get mainboardCount =>
      mainboard.fold<int>(0, (sum, c) => sum + c.quantity);
  int get sideboardCount =>
      sideboard.fold<int>(0, (sum, c) => sum + c.quantity);

  Deck copyWith({
    String? name,
    String? format,
    List<DeckCard>? mainboard,
    List<DeckCard>? sideboard,
    DateTime? updatedAt,
  }) {
    return Deck(
      id: id,
      name: name ?? this.name,
      format: format ?? this.format,
      mainboard: mainboard ?? this.mainboard,
      sideboard: sideboard ?? this.sideboard,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'format': format,
        'mainboard': mainboard.map((c) => c.toJson()).toList(),
        'sideboard': sideboard.map((c) => c.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Deck.fromJson(Map<String, dynamic> json) {
    return Deck(
      id: json['id'] as String,
      name: json['name'] as String,
      format: json['format'] as String? ?? 'Limited',
      mainboard: (json['mainboard'] as List<dynamic>?)
              ?.map((e) => DeckCard.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      sideboard: (json['sideboard'] as List<dynamic>?)
              ?.map((e) => DeckCard.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
    );
  }
}

class DeckFolder {
  final String id;
  final String name;
  final List<String> deckIds;

  const DeckFolder({
    required this.id,
    required this.name,
    this.deckIds = const [],
  });

  DeckFolder copyWith({
    String? name,
    List<String>? deckIds,
  }) {
    return DeckFolder(
      id: id,
      name: name ?? this.name,
      deckIds: deckIds ?? this.deckIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'deckIds': deckIds,
      };

  factory DeckFolder.fromJson(Map<String, dynamic> json) {
    return DeckFolder(
      id: json['id'] as String,
      name: json['name'] as String,
      deckIds: (json['deckIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

class DeckListState {
  final List<Deck> decks;
  final List<DeckFolder> folders;

  const DeckListState({this.decks = const [], this.folders = const []});
}

class DeckListNotifier extends StateNotifier<DeckListState> {
  DeckListNotifier() : super(const DeckListState()) {
    _loadFromStorage();
  }

  int _nextId = 1;
  int _nextFolderId = 1;

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw);
      List<Deck> decks;
      List<DeckFolder> folders = [];

      if (decoded is List) {
        // Legacy format: plain array of decks
        decks = decoded
            .map((e) => Deck.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        // New format: {decks: [...], folders: [...]}
        final map = decoded as Map<String, dynamic>;
        decks = (map['decks'] as List<dynamic>?)
                ?.map((e) => Deck.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
        folders = (map['folders'] as List<dynamic>?)
                ?.map((e) => DeckFolder.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
      }

      // Recover next IDs from loaded data
      for (final deck in decks) {
        final parts = deck.id.split('_');
        if (parts.length == 2) {
          final num = int.tryParse(parts[1]);
          if (num != null && num >= _nextId) {
            _nextId = num + 1;
          }
        }
      }
      for (final folder in folders) {
        final parts = folder.id.split('_');
        if (parts.length == 2) {
          final num = int.tryParse(parts[1]);
          if (num != null && num >= _nextFolderId) {
            _nextFolderId = num + 1;
          }
        }
      }
      state = DeckListState(decks: decks, folders: folders);
    } catch (_) {
      // Corrupted data: start fresh
    }
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'decks': state.decks.map((d) => d.toJson()).toList(),
      'folders': state.folders.map((f) => f.toJson()).toList(),
    };
    await prefs.setString(_storageKey, jsonEncode(data));
  }

  Deck createDeck({String name = 'New Deck', String format = 'Limited'}) {
    final deck = Deck(
      id: 'deck_${_nextId++}',
      name: name,
      format: format,
    );
    state = DeckListState(
      decks: [...state.decks, deck],
      folders: state.folders,
    );
    _saveToStorage();
    return deck;
  }

  void deleteDeck(String id) {
    // Also remove from any folder
    final updatedFolders = state.folders.map((f) {
      if (f.deckIds.contains(id)) {
        return f.copyWith(deckIds: f.deckIds.where((d) => d != id).toList());
      }
      return f;
    }).toList();
    state = DeckListState(
      decks: state.decks.where((d) => d.id != id).toList(),
      folders: updatedFolders,
    );
    _saveToStorage();
  }

  void updateDeck(Deck updated) {
    state = DeckListState(
      decks:
          state.decks.map((d) => d.id == updated.id ? updated : d).toList(),
      folders: state.folders,
    );
    _saveToStorage();
  }

  Deck? _findDeck(String id) {
    for (final d in state.decks) {
      if (d.id == id) return d;
    }
    return null;
  }

  void addCardToMainboard(String deckId, String cardName) {
    final deck = _findDeck(deckId);
    if (deck == null) return;
    final existing = deck.mainboard.indexWhere(
        (c) => c.name.toLowerCase() == cardName.toLowerCase());
    List<DeckCard> newMainboard;
    if (existing >= 0) {
      newMainboard = List.from(deck.mainboard);
      newMainboard[existing] = newMainboard[existing]
          .copyWith(quantity: newMainboard[existing].quantity + 1);
    } else {
      newMainboard = [...deck.mainboard, DeckCard(name: cardName)];
    }
    updateDeck(deck.copyWith(mainboard: newMainboard));
  }

  void addCardToSideboard(String deckId, String cardName) {
    final deck = _findDeck(deckId);
    if (deck == null) return;
    final existing = deck.sideboard.indexWhere(
        (c) => c.name.toLowerCase() == cardName.toLowerCase());
    List<DeckCard> newSideboard;
    if (existing >= 0) {
      newSideboard = List.from(deck.sideboard);
      newSideboard[existing] = newSideboard[existing]
          .copyWith(quantity: newSideboard[existing].quantity + 1);
    } else {
      newSideboard = [...deck.sideboard, DeckCard(name: cardName)];
    }
    updateDeck(deck.copyWith(sideboard: newSideboard));
  }

  void removeCardFromMainboard(String deckId, int index) {
    final deck = _findDeck(deckId);
    if (deck == null) return;
    final card = deck.mainboard[index];
    List<DeckCard> newMainboard = List.from(deck.mainboard);
    if (card.quantity > 1) {
      newMainboard[index] = card.copyWith(quantity: card.quantity - 1);
    } else {
      newMainboard.removeAt(index);
    }
    updateDeck(deck.copyWith(mainboard: newMainboard));
  }

  void removeCardFromSideboard(String deckId, int index) {
    final deck = _findDeck(deckId);
    if (deck == null) return;
    final card = deck.sideboard[index];
    List<DeckCard> newSideboard = List.from(deck.sideboard);
    if (card.quantity > 1) {
      newSideboard[index] = card.copyWith(quantity: card.quantity - 1);
    } else {
      newSideboard.removeAt(index);
    }
    updateDeck(deck.copyWith(sideboard: newSideboard));
  }

  // --- Folder operations ---

  DeckFolder createFolder(String name) {
    final folder = DeckFolder(
      id: 'folder_${_nextFolderId++}',
      name: name,
    );
    state = DeckListState(
      decks: state.decks,
      folders: [...state.folders, folder],
    );
    _saveToStorage();
    return folder;
  }

  void renameFolder(String folderId, String newName) {
    state = DeckListState(
      decks: state.decks,
      folders: state.folders
          .map((f) => f.id == folderId ? f.copyWith(name: newName) : f)
          .toList(),
    );
    _saveToStorage();
  }

  void deleteFolder(String folderId) {
    state = DeckListState(
      decks: state.decks,
      folders: state.folders.where((f) => f.id != folderId).toList(),
    );
    _saveToStorage();
  }

  void moveDeckToFolder(String deckId, String folderId) {
    // Remove deck from all folders first, then add to target
    final updatedFolders = state.folders.map((f) {
      final withoutDeck =
          f.deckIds.where((id) => id != deckId).toList();
      if (f.id == folderId) {
        return f.copyWith(deckIds: [...withoutDeck, deckId]);
      }
      return f.copyWith(deckIds: withoutDeck);
    }).toList();
    state = DeckListState(
      decks: state.decks,
      folders: updatedFolders,
    );
    _saveToStorage();
  }

  void removeDeckFromFolder(String deckId) {
    final updatedFolders = state.folders.map((f) {
      if (f.deckIds.contains(deckId)) {
        return f.copyWith(
            deckIds: f.deckIds.where((id) => id != deckId).toList());
      }
      return f;
    }).toList();
    state = DeckListState(
      decks: state.decks,
      folders: updatedFolders,
    );
    _saveToStorage();
  }

  /// Returns the folder containing the given deck, or null if unfiled.
  String? folderForDeck(String deckId) {
    for (final f in state.folders) {
      if (f.deckIds.contains(deckId)) return f.id;
    }
    return null;
  }
}

final deckListProvider =
    StateNotifierProvider<DeckListNotifier, DeckListState>(
  (ref) => DeckListNotifier(),
);
