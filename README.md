# Limited Lands

[![Release](https://img.shields.io/github/v/release/alcelaser/LimitedLands?style=flat-square)](https://github.com/alcelaser/LimitedLands/releases/latest)
[![Flutter](https://img.shields.io/badge/Flutter-3.16+-02569B?style=flat-square&logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

A Magic: The Gathering companion app built with Flutter. Mana calculator, Vintage Cube support, deck builder, match tracker, life counter, and 17Lands card ratings -- everything you need at the table.

> **[Download the latest APK](https://github.com/alcelaser/LimitedLands/releases/latest)**

---

## Features

### Mana Calculator
Calculates optimal land distribution using a proportional allocation algorithm with largest-remainder rounding.

- **Limited mode** - Enter mana symbol counts, get land recommendations for 40-card decks
- **Vintage Cube mode** - Account for fast mana (Moxen, Black Lotus, Mana Crypt) and mana rocks (Sol Ring, Grim Monolith) when calculating lands. Tap to add multiples, long-press to reset
- Supports Limited (40-card) and Constructed (60-card) presets
- Splash color detection with warnings
- Fully adjustable deck size and land count

### Deck Builder
Build and manage your deck lists with mainboard and sideboard tracking.

- Create decks for Limited, Vintage Cube, or Constructed
- Add cards by name with quantity tracking (+/- buttons)
- Card count progress indicator (e.g. 23/40)
- Export deck list as text to clipboard
- Rename and delete decks
- **Persistent storage** - Decks saved locally across app restarts

### Match Tracker
Record wins and losses across a draft, sealed, or constructed event.

- Create events with format tracking (Limited, Sealed, Vintage Cube, Constructed)
- Add rounds with opponent names and game-by-game results
- Quick-tap buttons for recording game wins/losses
- Draw support and match reset
- Color-coded W-L-D record badges
- Overall event record summary (e.g. 2-1)
- **Persistent storage** - Events saved locally across app restarts

### Life Counter
Full-featured life counter for 2–10 players with format-aware defaults.

- **Format presets** - Standard (20), Commander (40), or Custom starting life
- **Adaptive layout** - 2-player split-screen (rotated for across-the-table), 3–4 player grid, 5–10 player sideways columns
- Tap ±1, long press ±10, double-tap for keypad entry (up to 9999)
- **Poison counters** - Track infect damage with visual warning at lethal (≥10)
- **Experience, Energy, Storm, Commander Tax** counters — swipe down for the full counter suite
- **Mana Pool** - Track floating mana (W/U/B/R/G/C) with clear-all
- **Custom counters** - User-defined counters with custom labels
- **Commander damage** - Per-source tracking with partner support and ≥21 lethal warning; swipe right to view
- **Turn tracker** - Turn counter, active player display, auto-skip eliminated players
- **Game timer** - Total elapsed time + per-player turn time tracking
- **Dice roller** - D4/D6/D8/D10/D12/D20 with batch rolling (1–20 dice), coin flip, and roll history
- **High Roll** - D20-based "who goes first" with tie detection and winner auto-set
- **Planechase** - 86 planar cards, collapsible overlay with rotated card art from Scryfall, planar die (Planeswalk / Chaos / Blank), manual planeswalk, and deck reshuffle
- **Player management** - Rename, recolor, kill/revive players; swipe left for settings
- **Persistence** - Auto-save game state; resume in-progress games from the setup screen
- Visual low-life warnings and haptic feedback throughout

### 17Lands Card Search
Look up card ratings from 17lands.com for any draft format.

- Search by set code (e.g. FDN, DSK, BLB) and format (Premier Draft, Quick Draft, Sealed)
- **GIH WR** (Game in Hand Win Rate) - Primary card quality metric, color-coded
- **ATA** (Average Taken At) - Where the card is typically picked
- **IWD** (Improvement When Drawn) - How much drawing the card improves win rate
- Client-side search to quickly filter loaded card data
- Sortable by name, GIH WR, or ATA
- Color pips and rarity badges for quick identification

---

## Architecture

Clean Architecture with feature-based modules:

```
lib/
  core/
    theme/          # Material 3 dark theme with MTG-inspired palette
    routing/        # GoRouter with ShellRoute + bottom navigation
    constants/      # MTG constants (deck sizes, land counts, thresholds)
    widgets/        # Shared widgets (mana symbols, scaffold)
    services/       # Scryfall image service
  features/
    mana_calculator/
      domain/       # Models (freezed) + calculation service
      presentation/ # Screens, widgets, Riverpod providers
    deck_builder/
      providers/    # Deck CRUD state management
      screens/      # Deck list + detail screens
    match_tracker/
      providers/    # Event/match state management
      screens/      # Event list + match recording
    life_counter/
      models/       # Game, planechase, and counter models
      providers/    # Game, timer, dice, planechase providers
      screens/      # Setup + game screens
      widgets/      # Player panels, commander damage, counters, dice, planechase overlay
    card_search/
      providers/    # 17Lands API + state management
      screens/      # Card search + ratings UI
```

| Layer | Responsibility |
|-------|---------------|
| **Domain** | Immutable models (Freezed), calculation services |
| **Presentation** | Widgets, screens, Riverpod StateNotifier providers |
| **Core** | Theming, routing, shared constants and widgets |

## Tech Stack

| Technology | Purpose |
|-----------|---------|
| **Flutter** 3.16+ | Cross-platform UI framework (Android) |
| **Riverpod** | Reactive state management |
| **GoRouter** | Declarative routing with persistent bottom nav |
| **Freezed** | Immutable domain models with code generation |
| **Material 3** | Custom dark theme with MTG-inspired gold accent |
| **SharedPreferences** | Local persistence for decks and match history |
| **http** | HTTP client for 17Lands API integration |

## Getting Started

```bash
# Clone the repository
git clone https://github.com/alcelaser/LimitedLands.git
cd LimitedLands

# Install dependencies
flutter pub get

# Generate freezed models
dart run build_runner build

# Run on connected device or emulator
flutter run

# Run tests
flutter test

# Build release APK
flutter build apk --release
```

## Testing

```bash
flutter test
```

- **303 unit tests** - Mana calculation, game state, commander damage, planechase, dice rolling, timers, deck builder, match tracker, card search, tournament Swiss pairings, cube calculator, and model serialization
- **Widget tests** - App rendering and navigation

## License

MIT
