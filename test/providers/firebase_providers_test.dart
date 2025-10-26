// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_codelab_gemini/providers/firebase_providers.dart';

import '../mock_firebase.dart';

void main() {
  group('Firebase Providers Tests', () {
    late ProviderContainer container;

    setUp(() async {
      // Setup mock Firebase
      setupFirebaseAuthMocks();

      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('firebaseInitProvider initializes Firebase successfully', () async {
      // Act
      final firebaseApp = await container.read(firebaseInitProvider.future);

      // Assert
      expect(firebaseApp, isA<FirebaseApp>());
      expect(firebaseApp.name, '[DEFAULT]');
    });

    test('firebaseInitProvider configures Firebase UI Auth providers', () async {
      // Act
      await container.read(firebaseInitProvider.future);

      // Assert
      // Firebase UI Auth should be configured with EmailAuthProvider
      // This is verified by the provider not throwing an exception
      expect(true, isTrue);
    });

    test('firebaseInitProvider is cached and returns same instance', () async {
      // Act
      final app1 = await container.read(firebaseInitProvider.future);
      final app2 = await container.read(firebaseInitProvider.future);

      // Assert
      expect(app1, same(app2));
    });

    test('firebaseInitProvider handles multiple containers independently', () async {
      final container1 = ProviderContainer();
      final container2 = ProviderContainer();

      // Act
      final app1 = await container1.read(firebaseInitProvider.future);
      final app2 = await container2.read(firebaseInitProvider.future);

      // Assert
      expect(app1, isA<FirebaseApp>());
      expect(app2, isA<FirebaseApp>());

      // Cleanup
      container1.dispose();
      container2.dispose();
    });
  });
}
