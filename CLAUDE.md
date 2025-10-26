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

**lib/providers/auth_providers.dart**:
- `authStateProvider` - StreamProvider listening to `FirebaseAuth.instance.userChanges()`
- `loggedInProvider` - Derived Provider exposing a simple `bool` for login state

**lib/providers/guestbook_providers.dart**:
- `guestbookMessagesProvider` - StreamProvider for Firestore guestbook messages (only active when logged in)
- `guestbookServiceProvider` - Provider containing the `GuestbookService` for write operations

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
