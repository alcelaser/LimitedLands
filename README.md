# Limited Lands

A Magic: The Gathering companion app for Limited format players, built with Flutter.

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
- Tap to adjust by 1, long press to adjust by 5
- Visual warnings at low life totals
- Quick reset between games

### Coming Soon
- **Match Tracker** - Record wins/losses across a draft or sealed event
- **Deck Builder** - Build and save your Limited deck lists

## Architecture

Clean Architecture with feature-based modules:

```
lib/
  core/
    theme/          # Material 3 dark theme with MTG-inspired colors
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

**State management**: Riverpod `StateNotifier` pattern
**Routing**: GoRouter with `ShellRoute` for persistent bottom navigation
**Models**: Freezed for immutable domain models with code generation

## Tech Stack

- **Flutter** 3.16+ (Android)
- **Riverpod** for state management
- **GoRouter** for declarative routing
- **Freezed** for immutable models
- **Material 3** with custom dark theme

## Getting Started

```bash
# Install dependencies
flutter pub get

# Generate freezed models
dart run build_runner build

# Run on connected device or emulator
flutter run

# Run tests
flutter test

# Build release AAB
flutter build appbundle --release
```

## Testing

- 10 unit tests covering the mana calculation algorithm (proportional distribution, rounding, splash detection, edge cases)
- Widget integration tests for app rendering

```bash
flutter test
```

## License

MIT
