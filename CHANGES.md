# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Fixed
- **Performance Issue: Frame Drops on App Launch** - Fixed "Skipped frames" error that occurred when running the app in the emulator
  - **Root Cause**: Firebase initialization was blocking the main thread
  - **Changes Made**:
    1. Updated `authStateProvider` to properly await Firebase initialization using async generator pattern
       - Changed from synchronously watching `firebaseInitProvider` to awaiting `firebaseInitProvider.future`
       - Ensured Firebase is fully initialized before streaming authentication state changes
    2. Removed redundant nested `Consumer` widget in `HomePage`
       - `HomePage` is already a `ConsumerWidget`, so the nested `Consumer` was creating duplicate provider subscriptions
       - Moved all `ref.watch()` calls to the top of the build method for better performance
  - **Impact**: Eliminated main thread blocking and unnecessary widget rebuilds, resulting in smooth app startup

## [2025-01-26] - Provider to Riverpod Migration

### Added
- Created new `lib/providers/` directory with three provider files:
  - `firebase_providers.dart` - Contains `firebaseInitProvider` for Firebase initialization
  - `auth_providers.dart` - Contains `authStateProvider` and `loggedInProvider` for authentication state
  - `guestbook_providers.dart` - Contains `guestbookMessagesProvider` and `guestbookServiceProvider` for guestbook functionality
- Added `CLAUDE.md` - Comprehensive project documentation for AI-assisted development
- Added comprehensive `README.md` with project overview, architecture details, and usage instructions

### Changed
- **State Management**: Migrated from Provider to Riverpod
  - Replaced monolithic `ApplicationState` (ChangeNotifier) with focused, granular providers
  - Updated `lib/main.dart` to use `ProviderScope` instead of `ChangeNotifierProvider`
  - Converted `HomePage` from `StatelessWidget` to `ConsumerWidget`
  - Updated all state access patterns from `Consumer<ApplicationState>` to `ref.watch()`
- **Dependencies** (pubspec.yaml):
  - Removed: `provider: ^6.1.5+1`
  - Added: `flutter_riverpod: ^2.6.1`

### Removed
- Deleted `lib/app_state.dart` - Replaced by Riverpod providers

### Benefits
- **Fine-grained reactivity**: Only widgets watching specific providers rebuild on state changes
- **Better performance**: Eliminated unnecessary rebuilds throughout the widget tree
- **Clearer dependencies**: Provider dependency graph is explicit and compile-time safe
- **Improved testability**: Providers can be overridden independently for testing
- **Automatic loading/error handling**: StreamProvider's `.when()` method handles loading and error states declaratively

### Technical Details

#### Authentication Flow Changes
**Before (Provider)**:
- Single `ApplicationState` class managed all state
- Auth state listened via `FirebaseAuth.instance.userChanges()` in constructor
- Widgets accessed state via `Consumer<ApplicationState>`

**After (Riverpod)**:
- `authStateProvider` - StreamProvider for Firebase auth state
- `loggedInProvider` - Derived provider for boolean login state
- Widgets access via `ref.watch(loggedInProvider)` or `ref.watch(authStateProvider)`

#### Guestbook Data Flow Changes
**Before (Provider)**:
- Firestore subscription managed in `ApplicationState.init()`
- Messages stored in `_guestBookMessages` list
- Subscription lifecycle tied to auth state changes

**After (Riverpod)**:
- `guestbookMessagesProvider` - StreamProvider that automatically subscribes/unsubscribes based on auth state
- `guestbookServiceProvider` - Service provider for write operations
- Lifecycle managed automatically by Riverpod

#### Firebase Initialization Changes
**Before (Provider)**:
- Firebase initialized in `ApplicationState.init()` called from constructor
- No explicit dependency tracking

**After (Riverpod)**:
- `firebaseInitProvider` - FutureProvider that handles initialization
- All Firebase-dependent providers explicitly watch this provider
- Ensures proper initialization order
