// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase_options.dart';

/// Provider that initializes Firebase and configures FirebaseUI Auth
/// This must complete before other Firebase-dependent providers can work
///
/// Includes timeout handling to prevent indefinite hangs
final firebaseInitProvider = FutureProvider<FirebaseApp>((ref) async {
  try {
    // Add 30-second timeout for Firebase initialization
    final app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw Exception(
          'Firebase initialization timed out after 30 seconds. '
          'Please check your internet connection and try again.',
        );
      },
    );

    // Configure Firestore with timeout settings
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    FirebaseUIAuth.configureProviders([EmailAuthProvider()]);

    return app;
  } catch (e) {
    // Re-throw with more context
    throw Exception('Firebase initialization failed: $e');
  }
});
