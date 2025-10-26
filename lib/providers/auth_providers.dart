// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_providers.dart';

/// Provider that streams the current authentication state
/// Returns User? (null if not logged in)
final authStateProvider = StreamProvider<User?>((ref) {
  // Ensure Firebase is initialized first
  ref.watch(firebaseInitProvider);

  return FirebaseAuth.instance.userChanges();
});

/// Derived provider that returns a simple boolean for logged-in state
final loggedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    data: (user) => user != null,
    orElse: () => false,
  );
});
