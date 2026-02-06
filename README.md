# Limited Lands

[![Release](https://img.shields.io/github/v/release/alcelaser/LimitedLands?style=flat-square)](https://github.com/alcelaser/LimitedLands/releases/latest)
[![Flutter](https://img.shields.io/badge/Flutter-3.16+-02569B?style=flat-square&logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

A Magic: The Gathering companion app built with Flutter. Mana calculator, Vintage Cube support, deck builder, and life counter -- everything you need at the table.

> **[Download the latest APK](https://github.com/alcelaser/LimitedLands/releases/latest)**

---

## Features

### Mana Calculator
Calculates optimal land distribution using a proportional allocation algorithm with largest-remainder rounding.

- **Limited mode** - Enter mana symbol counts, get land recommendations for 40-card decks
- **Vintage Cube mode** - Account for fast mana (Moxen, Black Lotus, Mana Crypt) and mana rocks (Sol Ring, Grim Monolith) when calculating lands
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

### Life Counter
Clean, modern 2-player life counter designed for face-to-face play.

- Split-screen layout with Player 2 rotated for across-the-table use
- Tap to adjust by 1, long press for +/-5
- Visual warnings at low life totals
- Quick reset between games

### Roadmap
- **Match Tracker** - Record wins/losses across a draft or sealed event

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
  features/
    mana_calculator/
      domain/       # Models (freezed) + calculation service
      presentation/ # Screens, widgets, Riverpod providers
    deck_builder/
      providers/    # Deck CRUD state management
      screens/      # Deck list + detail screens
    life_counter/
      providers/    # Riverpod state management
      screens/      # Life counter UI
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

- **10 unit tests** - Mana calculation algorithm: proportional distribution, largest-remainder rounding, splash detection, edge cases (zero input, single color, 5-way equal split)
- **Widget tests** - App rendering and navigation

## License

MIT
