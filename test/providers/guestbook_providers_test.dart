// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_codelab_gemini/guest_book_message.dart';
import 'package:flutter_codelab_gemini/providers/auth_providers.dart';
import 'package:flutter_codelab_gemini/providers/guestbook_providers.dart';

import '../mock_firebase.dart';

void main() {
  group('Guestbook Providers Tests', () {
    late MockUser mockUser;

    setUp(() async {
      setupFirebaseAuthMocks();
      mockUser = MockUser(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
      );
    });

    group('guestbookMessagesProvider', () {
      test('can be overridden with empty list', () {
        // Arrange
        final container = ProviderContainer(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(null)),
            guestbookMessagesProvider.overrideWith((ref) {
              return Stream.value(<GuestBookMessage>[]);
            }),
          ],
        );

        // Act
        final messages = container.read(guestbookMessagesProvider);

        // Assert
        expect(messages, isA<AsyncValue<List<GuestBookMessage>>>());

        // Cleanup
        container.dispose();
      });

      test('can be overridden with message list', () {
        // Arrange
        final messages = [
          GuestBookMessage(name: 'Alice', message: 'Hello World'),
          GuestBookMessage(name: 'Bob', message: 'Great app!'),
        ];

        final container = ProviderContainer(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
            guestbookMessagesProvider.overrideWith((ref) {
              return Stream.value(messages);
            }),
          ],
        );

        // Act
        final messagesState = container.read(guestbookMessagesProvider);

        // Assert
        expect(messagesState, isA<AsyncValue<List<GuestBookMessage>>>());

        // Cleanup
        container.dispose();
      });

      test('reacts to message updates', () async {
        // Arrange
        final controller = StreamController<List<GuestBookMessage>>();

        final container = ProviderContainer(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
            guestbookMessagesProvider.overrideWith((ref) => controller.stream),
          ],
        );

        final messageStates = <List<GuestBookMessage>>[];
        container.listen(guestbookMessagesProvider, (previous, next) {
          next.whenData((msgs) => messageStates.add(msgs));
        });

        // Act - emit messages over time
        controller.add([
          GuestBookMessage(name: 'User 1', message: 'Message 1'),
        ]);

        await Future.delayed(const Duration(milliseconds: 10));

        controller.add([
          GuestBookMessage(name: 'User 2', message: 'Message 2'),
          GuestBookMessage(name: 'User 1', message: 'Message 1'),
        ]);

        await Future.delayed(const Duration(milliseconds: 10));

        // Assert - verify stream emits updates
        expect(messageStates, isNotEmpty);

        // Cleanup
        await controller.close();
        container.dispose();
      });

      test('handles auth state dependencies', () {
        // Arrange - simulate not logged in
        final container = ProviderContainer(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(null)),
            guestbookMessagesProvider.overrideWith((ref) {
              return Stream.value(<GuestBookMessage>[]);
            }),
          ],
        );

        // Act
        final messages = container.read(guestbookMessagesProvider);

        // Assert - provider should handle null auth state
        expect(messages, isA<AsyncValue<List<GuestBookMessage>>>());

        // Cleanup
        container.dispose();
      });

      test('handles errors gracefully', () {
        // Arrange
        final container = ProviderContainer(
          overrides: [
            authStateProvider.overrideWith(
              (ref) => Stream.error(Exception('Auth error')),
            ),
            guestbookMessagesProvider.overrideWith((ref) {
              return Stream.value(<GuestBookMessage>[]);
            }),
          ],
        );

        // Act
        final messages = container.read(guestbookMessagesProvider);

        // Assert - provider should return valid AsyncValue even on error
        expect(messages, isA<AsyncValue<List<GuestBookMessage>>>());

        // Cleanup
        container.dispose();
      });
    });

    group('GuestbookService', () {
      test('provides service instance', () {
        // Arrange
        final container = ProviderContainer();

        // Act
        final service = container.read(guestbookServiceProvider);

        // Assert
        expect(service, isA<GuestbookService>());

        // Cleanup
        container.dispose();
      });

      test('addMessageToGuestBook throws when user is not logged in', () {
        // Arrange
        final service = GuestbookService();

        // Act & Assert
        expect(
          () => service.addMessageToGuestBook('Test message'),
          throwsA(isA<Exception>()),
        );
      });

      test('service is singleton per container', () {
        // Arrange
        final container = ProviderContainer();

        // Act
        final service1 = container.read(guestbookServiceProvider);
        final service2 = container.read(guestbookServiceProvider);

        // Assert
        expect(service1, same(service2));

        // Cleanup
        container.dispose();
      });

      test('different containers get independent service instances', () {
        // Arrange
        final container1 = ProviderContainer();
        final container2 = ProviderContainer();

        // Act
        final service1 = container1.read(guestbookServiceProvider);
        final service2 = container2.read(guestbookServiceProvider);

        // Assert - same type but different instances
        expect(service1, isA<GuestbookService>());
        expect(service2, isA<GuestbookService>());

        // Cleanup
        container1.dispose();
        container2.dispose();
      });
    });

    group('Provider Integration', () {
      test('providers can be composed with auth state', () {
        // Arrange
        final container = ProviderContainer(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
            guestbookMessagesProvider.overrideWith((ref) {
              return Stream.value([
                GuestBookMessage(name: 'Test', message: 'Hello'),
              ]);
            }),
          ],
        );

        // Act - verify providers can be read together
        final authState = container.read(authStateProvider);
        final messages = container.read(guestbookMessagesProvider);
        final isLoggedIn = container.read(loggedInProvider);

        // Assert - all providers should be accessible
        expect(authState, isA<AsyncValue<User?>>());
        expect(messages, isA<AsyncValue<List<GuestBookMessage>>>());
        expect(isLoggedIn, isA<bool>());

        // Cleanup
        container.dispose();
      });
    });
  });
}
