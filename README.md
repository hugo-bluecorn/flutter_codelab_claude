# Firebase Flutter Codelab

A Flutter application demonstrating Firebase integration with authentication and real-time database features. This app is a "Firebase Meetup" event page with a guestbook feature where authenticated users can leave messages.

## Features

- **Firebase Authentication**: Email/password authentication using Firebase UI Auth
- **Real-time Guestbook**: Authenticated users can post and view messages in real-time
- **Cloud Firestore Integration**: Messages are stored and synced via Firestore
- **Riverpod State Management**: Modern, reactive state management with granular providers

## State Management

This application uses **Riverpod** for state management, having been migrated from the Provider pattern. The state is organized into focused providers:

- **Firebase Initialization**: `firebaseInitProvider` handles Firebase setup
- **Authentication**: `authStateProvider` and `loggedInProvider` manage auth state
- **Guestbook**: `guestbookMessagesProvider` and `guestbookServiceProvider` handle message data and operations

Benefits of this architecture:
- Fine-grained reactivity - only affected widgets rebuild
- Clear provider dependencies
- Better testability with provider overrides
- Automatic loading/error state handling

## Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Firebase project with Authentication and Firestore enabled
- Firebase configuration files (already included in `lib/firebase_options.dart`)

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd flutter_codelab_claude
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Building

```bash
flutter build web          # Build for web
flutter build apk          # Build for Android
flutter build ios          # Build for iOS
```

## Project Structure

```
lib/
├── main.dart                      # App entry point with ProviderScope
├── router.dart                    # GoRouter navigation configuration
├── home_page.dart                 # Main page (ConsumerWidget)
├── guest_book.dart                # Guestbook UI component
├── guest_book_message.dart        # Message data model
├── firebase_options.dart          # Firebase configuration
├── providers/                     # Riverpod providers
│   ├── firebase_providers.dart    # Firebase initialization
│   ├── auth_providers.dart        # Authentication state
│   └── guestbook_providers.dart   # Guestbook data & operations
└── src/
    ├── authentication.dart        # Auth UI components
    └── widgets.dart               # Reusable UI widgets
```

## Key Dependencies

- `flutter_riverpod: ^2.6.1` - State management
- `firebase_core: ^4.2.0` - Firebase core functionality
- `firebase_auth: ^6.1.1` - Firebase authentication
- `cloud_firestore: ^6.0.3` - Cloud Firestore database
- `firebase_ui_auth: ^3.0.0` - Pre-built auth UI components
- `go_router: ^16.3.0` - Declarative routing
- `google_fonts: ^6.3.2` - Typography

## Development Notes

This project was migrated from Provider to Riverpod using Claude Code, demonstrating how AI-assisted development can help modernize Flutter applications with improved architecture and best practices.

For detailed architecture documentation, see [CLAUDE.md](CLAUDE.md).
