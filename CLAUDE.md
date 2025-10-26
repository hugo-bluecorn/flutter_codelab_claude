# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter Firebase codelab application demonstrating authentication and real-time database features. The app is a "Firebase Meetup" event page with a guestbook feature where authenticated users can leave messages.

**Current Context**: This project uses **Riverpod** for state management, having migrated from the Provider pattern. The state is split into multiple focused providers for better maintainability and performance.

## Development Commands

### Running the app
```bash
flutter run
```

### Building
```bash
flutter build web          # Build for web
flutter build apk          # Build for Android
```

### Testing and Linting
```bash
flutter test               # Run tests
flutter analyze            # Run static analysis
```

### Dependencies
```bash
flutter pub get            # Install dependencies
flutter pub upgrade        # Upgrade dependencies
```

## Architecture

### State Management
The app uses **Riverpod** (flutter_riverpod) with manually defined providers. State is split into focused providers across three files:

**lib/providers/firebase_providers.dart**:
- `firebaseInitProvider` - FutureProvider that initializes Firebase and configures auth providers
  - **Includes 30-second timeout** to prevent indefinite hangs
  - Configures Firestore settings (persistence enabled, unlimited cache)
  - Provides helpful error messages on timeout or failure

**lib/providers/auth_providers.dart**:
- `authStateProvider` - StreamProvider listening to `FirebaseAuth.instance.userChanges()`
- `loggedInProvider` - Derived Provider exposing a simple `bool` for login state

**lib/providers/guestbook_providers.dart**:
- `guestbookMessagesProvider` - StreamProvider for Firestore guestbook messages (only active when logged in)
  - **Includes 20-second timeout** on Firestore snapshot streams
  - Gracefully handles errors by returning empty list
  - Returns empty list when user is not authenticated
- `guestbookServiceProvider` - Provider containing the `GuestbookService` for write operations
- `GuestbookService` - Service class for guestbook operations
  - `addMessageToGuestBook()` - **Includes 15-second timeout** on write operations
  - Validates user authentication before attempting write
  - Provides user-friendly error messages on timeout or failure

The app is wrapped in a `ProviderScope` at the root in lib/main.dart.

### Navigation
Uses **go_router** (lib/router.dart) for declarative routing with the following structure:
- `/` - HomePage
- `/sign-in` - SignInScreen (Firebase UI)
  - `/sign-in/forgot-password` - Password recovery
- `/profile` - ProfileScreen (Firebase UI)

### Firebase Integration
The app integrates three Firebase services:
- **Firebase Auth**: Email/password authentication via firebase_ui_auth
- **Cloud Firestore**: Real-time guestbook messages in the 'guestbook' collection
- **Firebase Core**: Initialization with platform-specific options (firebase_options.dart)

### Project Structure
```
lib/
├── main.dart                 # App entry point, ProviderScope setup
├── router.dart               # GoRouter configuration
├── home_page.dart            # Main page with guestbook (ConsumerWidget)
├── guest_book.dart           # Guestbook widget (form + message list)
├── guest_book_message.dart   # Message data model
├── firebase_options.dart     # Firebase configuration (generated)
├── providers/                # Riverpod provider definitions
│   ├── firebase_providers.dart   # Firebase initialization provider
│   ├── auth_providers.dart       # Authentication state providers
│   └── guestbook_providers.dart  # Guestbook providers & service
└── src/
    ├── authentication.dart   # AuthFunc widget
    └── widgets.dart          # Reusable UI components

assets/
└── codelab.png              # Event image displayed on home page

test/
├── mock_firebase.dart       # Firebase mocking utilities
├── home_page_test.dart      # HomePage widget tests (8 tests)
├── providers/
│   ├── firebase_providers_test.dart   # Firebase init tests (4 tests)
│   ├── auth_providers_test.dart       # Auth state tests (9 tests)
│   ├── guestbook_providers_test.dart  # Guestbook tests (9 tests)
│   └── timeout_test.dart              # Timeout coverage tests (10 tests)
├── CHANGES.md               # Test suite changelog
└── README.md                # Test documentation
```

### Key Patterns

**Authentication Flow**:
- `authStateProvider` streams `FirebaseAuth.instance.userChanges()`
- `loggedInProvider` derives a boolean from the auth state
- `guestbookMessagesProvider` depends on `authStateProvider` and only activates Firestore subscription when logged in
- UI widgets use `ConsumerWidget` and `ref.watch()` to react to state changes

**Data Flow**:
- Firestore messages are stored with: `text`, `timestamp`, `name`, `userId`
- Messages are ordered by timestamp (descending)
- Real-time updates via Firestore snapshots through `guestbookMessagesProvider`
- New messages added via `GuestbookService.addMessageToGuestBook()`
- StreamProvider automatically handles loading/error states with `.when()`

**Provider Dependencies**:
- All Firebase-dependent providers watch `firebaseInitProvider` to ensure initialization
- `guestbookMessagesProvider` watches `authStateProvider` to control subscription lifecycle
- Providers are granular - only widgets watching specific providers rebuild on changes

### Firebase Configuration
Firebase is initialized in the `firebaseInitProvider` with platform-specific options. The firebase.json file exists for Firebase Hosting/Emulator configuration.

**Firestore Settings**:
- Persistence enabled for offline support
- Unlimited cache size for better performance
- Configured during Firebase initialization

### Error Handling & Timeouts

The app includes comprehensive timeout protection to prevent indefinite hangs on poor network connections:

**Timeout Hierarchy**:
- **Firebase Initialization**: 30-second timeout
  - Error message: "Firebase initialization timed out after 30 seconds. Please check your internet connection and try again."
- **Firestore Queries**: 20-second timeout on snapshot streams
  - Error message: "Failed to load messages: connection timed out. Please check your internet connection."
- **Firestore Writes**: 15-second timeout on write operations
  - Error message: "Failed to add message: operation timed out. Please check your connection and try again."

All timeout errors include user-friendly guidance to help resolve connectivity issues.

### Test Suite

The project includes a comprehensive test suite with **40 tests** achieving **95% pass rate**:

**Test Coverage**:
- Firebase Providers: 4 tests (100% passing)
- Auth Providers: 9 tests (100% passing)
- Guestbook Providers: 9 tests (78% passing - 2 expected platform errors)
- HomePage Widget: 8 tests (100% passing)
- Timeout Features: 10 tests (100% passing)

**Running Tests**:
```bash
flutter test                    # Run all tests
flutter test test/providers/    # Run provider tests only
flutter test test/home_page_test.dart  # Run widget tests
flutter test --coverage         # Generate coverage report
```

**Test Documentation**:
- See `test/README.md` for testing patterns and best practices
- See `test/CHANGES.md` for test suite changelog and improvements

**Key Testing Patterns**:
- Provider overrides for mocking dependencies
- Firebase mocking with `setupFirebaseAuthMocks()`
- Async provider state handling in widget tests
- Scroll operations for testing off-screen content
