# Limited Lands

[![Release](https://img.shields.io/github/v/release/alcelaser/LimitedLands?style=flat-square)](https://github.com/alcelaser/LimitedLands/releases/latest)
[![Flutter](https://img.shields.io/badge/Flutter-3.16+-02569B?style=flat-square&logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

A Magic: The Gathering companion app for Limited format players, built with Flutter.

> **[Download the latest APK](https://github.com/alcelaser/LimitedLands/releases/latest)**

---

## Features

### Mana Calculator
Calculates optimal land distribution for your Limited deck using a proportional allocation algorithm with largest-remainder rounding.

- Enter colored mana symbol counts from your deck
- Automatically recommends how many of each basic land to play
- Supports Limited (40-card) and Constructed (60-card) presets
- Splash color detection with warnings
- Fully adjustable deck size and land count

### Life Counter
Clean, modern 2-player life counter designed for face-to-face play.

- Split-screen layout with Player 2 rotated for across-the-table use
- Tap to adjust by 1, long press for +/-5
- Visual warnings at low life totals
- Quick reset between games

### Roadmap
- **Match Tracker** - Record wins/losses across a draft or sealed event
- **Deck Builder** - Build and save your Limited deck lists

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
