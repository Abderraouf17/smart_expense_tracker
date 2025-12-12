# Smart Expense Tracker

## Project Overview
**Smart Expense Tracker** is a Flutter-based mobile application designed to help users manage their finances. It features expense tracking, debt management, and statistical analysis.

### Key Technologies
*   **Framework:** Flutter (Dart)
*   **State Management:** Provider (`provider`)
*   **Local Database:** Hive (`hive`, `hive_flutter`) for offline persistence of expenses, people, and debts.
*   **Backend/Cloud:** Firebase
    *   Authentication (`firebase_auth`)
    *   Cloud Firestore (`cloud_firestore`)
*   **UI/UX:**
    *   Material Design
    *   Google Fonts (Poppins)
    *   Charts (`fl_chart`)
*   **Localization:** `flutter_localizations`

## Architecture
The project follows a pragmatic MVVM-like architecture:
*   **Models** (`lib/models/`): Data classes annotated for Hive adapters (`Expense`, `Person`, `DebtRecord`, `User`).
*   **Providers** (`lib/providers/`): Business logic and state management (`ExpenseProvider`, `DebtProvider`, `ThemeProvider`, `AuthProvider`).
*   **Screens** (`lib/screens/`): UI implementation for different pages (e.g., `home_screen.dart`, `add_expense_screen.dart`).
*   **Widgets** (`lib/widgets/`): Reusable UI components.
*   **Services** (`lib/services/`): Backend interaction layers (e.g., `firestore_service.dart`).

## Building and Running

### Prerequisites
*   Flutter SDK (version matching `^3.8.0` in `pubspec.yaml`)
*   Dart SDK

### Key Commands
*   **Run Development:** `flutter run`
*   **Run Tests:** `flutter test`
*   **Build Android APK:** `flutter build apk`
*   **Build iOS (macOS only):** `flutter build ios`
*   **Analyze Code:** `flutter analyze`
*   **Code Generation:** `dart run build_runner build` (Use this when modifying Hive models to regenerate adapters).

## Development Conventions

### Coding Style
*   Follows standard Dart/Flutter conventions.
*   Linting rules are defined in `analysis_options.yaml` (extends `package:flutter_lints/flutter.yaml`).
*   Use `const` constructors for widgets wherever possible.

### Data Persistence Strategy
*   **Hive**: Primary local storage for expenses and debts. Adapters must be registered in `main.dart`.
*   **Firebase**: Used for user authentication and potentially syncing data (indicated by `firestore_service.dart`).

### Internationalization
*   Localization support is enabled.
*   Strings are managed via `AppLocalizations` (likely generating from ARB files in `lib/l10n/`).

### Theme
*   Supports both Light and Dark modes.
*   Managed via `ThemeProvider` and persisted in Hive `settings` box.
