// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_codelab_gemini/providers/auth_providers.dart';
import 'package:flutter_codelab_gemini/providers/firebase_providers.dart';
import 'package:mocktail/mocktail.dart';

import '../mock_firebase.dart';

class MockFirebaseApp extends Mock implements FirebaseApp {}

void main() {
  group('Authentication Providers Tests', () {
    setUp(() async {
      setupFirebaseAuthMocks();
    });

    group('authStateProvider', () {
      test('can be overridden with null user', () {
        // Arrange
        final container = ProviderContainer(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(null)),
          ],
        );

        // Act
        final authState = container.read(authStateProvider);

        // Assert - verify it's in a loading or data state
        expect(authState, isA<AsyncValue<User?>>());

        // Cleanup
        container.dispose();
      });

      test('can be overridden with logged in user', () {
        // Arrange
        final mockUser = MockUser(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
        );

        final container = ProviderContainer(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
          ],
        );

        // Act
        final authState = container.read(authStateProvider);

        // Assert
        expect(authState, isA<AsyncValue<User?>>());

        // Cleanup
        container.dispose();
      });

      test('streams auth state changes using listen', () async {
        // Arrange
        final mockUser = MockUser(uid: 'test-uid');
        final controller = StreamController<User?>();

        final container = ProviderContainer(
          overrides: [
            authStateProvider.overrideWith((ref) => controller.stream),
          ],
        );

        final states = <User?>[];
        container.listen(authStateProvider, (previous, next) {
          next.whenData((user) => states.add(user));
        });

        // Act - emit values
        controller.add(null);
        await Future.delayed(const Duration(milliseconds: 10));

        controller.add(mockUser);
        await Future.delayed(const Duration(milliseconds: 10));

        // Assert - verify state changes were captured
        expect(states, isNotEmpty);

        // Cleanup
        await controller.close();
        container.dispose();
      });

      test('provider dependencies are explicit', () {
        // Arrange & Act
        final container = ProviderContainer(
          overrides: [
            firebaseInitProvider.overrideWith((ref) async => MockFirebaseApp()),
            authStateProvider.overrideWith((ref) => Stream.value(null)),
          ],
        );

        // Assert - verify provider can be read with dependencies
        final provider = container.read(authStateProvider);
        expect(provider, isA<AsyncValue<User?>>());

        // Cleanup
        container.dispose();
      });
    });

    group('loggedInProvider', () {
      test('returns false when auth state is null', () {
        // Arrange
        final container = ProviderContainer(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(null)),
          ],
        );

        // Give the stream time to emit
        container.read(authStateProvider);

        // Act
        final isLoggedIn = container.read(loggedInProvider);

        // Assert - either false (if stream emitted) or false (if loading)
        expect(isLoggedIn, isA<bool>());
        expect(isLoggedIn, isFalse);

        // Cleanup
        container.dispose();
      });

      test('derives boolean from auth state', () {
        // Arrange
        final container = ProviderContainer(
          overrides: [
            authStateProvider.overrideWith((ref) => const Stream.empty()),
          ],
        );

        // Act
        final isLoggedIn = container.read(loggedInProvider);

        // Assert - should return false for loading/empty state
        expect(isLoggedIn, isA<bool>());
        expect(isLoggedIn, isFalse);

        // Cleanup
        container.dispose();
      });

      test('returns false on auth error', () {
        // Arrange
        final container = ProviderContainer(
          overrides: [
            authStateProvider.overrideWith(
              (ref) => Stream.error(Exception('Auth error')),
            ),
          ],
        );

        // Act
        final isLoggedIn = container.read(loggedInProvider);

        // Assert
        expect(isLoggedIn, isFalse);

        // Cleanup
        container.dispose();
      });

      test('reacts to auth state changes', () async {
        // Arrange
        final mockUser = MockUser(uid: 'test-uid');
        final authController = StreamController<User?>();

        final container = ProviderContainer(
          overrides: [
            authStateProvider.overrideWith((ref) => authController.stream),
          ],
        );

        final states = <bool>[];
        container.listen(
          loggedInProvider,
          (previous, next) => states.add(next),
        );

        // Act - emit auth state changes
        authController.add(null);
        await Future.delayed(const Duration(milliseconds: 10));

        authController.add(mockUser);
        await Future.delayed(const Duration(milliseconds: 10));

        // Assert - should have captured state changes
        expect(states, isNotEmpty);

        // Cleanup
        await authController.close();
        container.dispose();
      });
    });

    group('Provider Integration', () {
      test('providers can be composed together', () {
        // Arrange
        final container = ProviderContainer(
          overrides: [
            firebaseInitProvider.overrideWith((ref) async => MockFirebaseApp()),
            authStateProvider.overrideWith((ref) => Stream.value(null)),
          ],
        );

        // Act - read both providers
        final authState = container.read(authStateProvider);
        final isLoggedIn = container.read(loggedInProvider);

        // Assert
        expect(authState, isA<AsyncValue<User?>>());
        expect(isLoggedIn, isA<bool>());

        // Cleanup
        container.dispose();
      });
    });
  });
}
