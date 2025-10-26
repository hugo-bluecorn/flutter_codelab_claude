# Test Suite Documentation

This directory contains comprehensive unit and widget tests for the Firebase Flutter Codelab application, with a focus on Riverpod state management and Firebase integration.

## Test Structure

```
test/
├── README.md                           # This file
├── mock_firebase.dart                  # Firebase mocking utilities
├── home_page_test.dart                 # Widget tests for HomePage
└── providers/
    ├── firebase_providers_test.dart    # Firebase initialization tests
    ├── auth_providers_test.dart        # Authentication provider tests
    └── guestbook_providers_test.dart   # Guestbook provider tests
```

## Running Tests

### Run all tests
```bash
flutter test
```

### Run specific test file
```bash
flutter test test/providers/auth_providers_test.dart
```

### Run tests with coverage
```bash
flutter test --coverage
```

### View coverage report
```bash
# Generate HTML coverage report (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Test Categories

### 1. Provider Tests (`test/providers/`)

#### Firebase Providers Tests
- **File**: `firebase_providers_test.dart`
- **Coverage**:
  - Firebase initialization
  - Provider caching behavior
  - Multiple container independence
  - Firebase UI Auth configuration

#### Authentication Providers Tests
- **File**: `auth_providers_test.dart`
- **Coverage**:
  - `authStateProvider`:
    - Null state when not logged in
    - User state when logged in
    - Auth state change streaming
    - Firebase initialization dependency
  - `loggedInProvider`:
    - Boolean state derivation
    - Updates on auth changes
    - Loading state handling
    - Error state handling

#### Guestbook Providers Tests
- **File**: `guestbook_providers_test.dart`
- **Coverage**:
  - `guestbookMessagesProvider`:
    - Empty list when not logged in
    - Message streaming from Firestore
    - Timestamp-based ordering
    - Real-time updates
    - Loading and error states
  - `GuestbookService`:
    - Message creation
    - Authentication requirements
    - Data structure validation
  - Integration scenarios

### 2. Widget Tests

#### HomePage Widget Tests
- **File**: `home_page_test.dart`
- **Coverage**:
  - Login/logout button visibility
  - Discussion section display
  - Guestbook message rendering
  - Loading states
  - Error handling
  - Event information display
  - Scrolling behavior

## Testing Patterns

### Riverpod Testing Pattern

```dart
test('provider test', () {
  // Create a container with overrides
  final container = ProviderContainer(
    overrides: [
      myProvider.overrideWith((ref) => mockValue),
    ],
  );

  // Read provider value
  final value = container.read(myProvider);

  // Assert
  expect(value, expectedValue);

  // Clean up
  container.dispose();
});
```

### Widget Testing with Riverpod

```dart
testWidgets('widget test', (WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
      ],
      child: const MaterialApp(home: HomePage()),
    ),
  );

  await tester.pumpAndSettle();

  expect(find.text('Expected Text'), findsOneWidget);
});
```

### Stream Provider Testing

```dart
test('stream provider test', () async {
  final container = ProviderContainer(
    overrides: [
      streamProvider.overrideWith((ref) {
        return Stream.fromIterable([value1, value2, value3]);
      }),
    ],
  );

  final states = <MyType>[];
  final subscription = container.listen(
    streamProvider,
    (previous, next) {
      next.whenData((value) => states.add(value));
    },
  );

  await Future.delayed(const Duration(milliseconds: 100));

  expect(states, [value1, value2, value3]);

  subscription.close();
  container.dispose();
});
```

## Mock Dependencies

### Firebase Mocks
- **firebase_auth_mocks**: Mock Firebase Authentication
- **fake_cloud_firestore**: Fake Firestore implementation for testing
- **mocktail**: General-purpose mocking library

### Mock Setup
All tests use `setupFirebaseAuthMocks()` from `mock_firebase.dart` to initialize Firebase mocks before running tests.

## Best Practices

### 1. Provider Testing
- ✅ Always dispose containers after tests
- ✅ Override only the providers you need to test
- ✅ Test provider dependencies explicitly
- ✅ Test loading, error, and data states for async providers

### 2. Widget Testing
- ✅ Wrap widgets in `ProviderScope` for Riverpod access
- ✅ Use `pumpAndSettle()` to wait for async operations
- ✅ Override providers to control test data
- ✅ Test both logged-in and logged-out states

### 3. Firebase Testing
- ✅ Use mocks to avoid real Firebase calls
- ✅ Test authentication state changes
- ✅ Verify Firestore query structure
- ✅ Test error scenarios (network failures, permission errors)

### 4. General Guidelines
- ✅ Write descriptive test names
- ✅ Follow Arrange-Act-Assert pattern
- ✅ Test one thing per test
- ✅ Clean up resources (dispose containers, close streams)

## Common Issues and Solutions

### Issue: "Firebase not initialized" error
**Solution**: Ensure `setupFirebaseAuthMocks()` is called in `setUp()`:
```dart
setUp(() {
  setupFirebaseAuthMocks();
});
```

### Issue: Provider not updating in tests
**Solution**: Use `listen()` and wait for state changes:
```dart
final subscription = container.listen(
  myProvider,
  (previous, next) {
    // Handle state change
  },
);
await Future.delayed(const Duration(milliseconds: 50));
```

### Issue: Widget test fails with "No MaterialLocalizations found"
**Solution**: Wrap widget in `MaterialApp`:
```dart
await tester.pumpWidget(
  ProviderScope(
    child: const MaterialApp(home: MyWidget()),
  ),
);
```

## Test Coverage Goals

- **Providers**: 90%+ coverage
- **Widgets**: 80%+ coverage
- **Critical paths** (auth, data persistence): 100% coverage

## CI/CD Integration

These tests are designed to run in CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
- name: Run tests
  run: flutter test

- name: Upload coverage
  run: |
    flutter test --coverage
    bash <(curl -s https://codecov.io/bash)
```

## Further Reading

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Riverpod Testing Guide](https://riverpod.dev/docs/cookbooks/testing)
- [Firebase Testing](https://firebase.google.com/docs/emulator-suite)
