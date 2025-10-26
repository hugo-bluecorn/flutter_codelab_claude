// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../guest_book_message.dart';
import 'auth_providers.dart';

/// Provider that streams guestbook messages from Firestore
/// Only active when user is logged in
final guestbookMessagesProvider =
    StreamProvider<List<GuestBookMessage>>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) {
        // Not logged in - return empty stream
        return Stream.value(<GuestBookMessage>[]);
      }

      // Logged in - subscribe to Firestore
      return FirebaseFirestore.instance
          .collection('guestbook')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((document) {
          final data = document.data();
          return GuestBookMessage(
            name: data['name'] as String,
            message: data['text'] as String,
          );
        }).toList();
      });
    },
    loading: () => Stream.value(<GuestBookMessage>[]),
    error: (error, stack) => Stream.value(<GuestBookMessage>[]),
  );
});

/// Service provider for guestbook write operations
final guestbookServiceProvider = Provider<GuestbookService>((ref) {
  return GuestbookService();
});

/// Service class for guestbook operations
class GuestbookService {
  /// Adds a message to the guestbook
  /// Throws an exception if user is not logged in
  Future<DocumentReference> addMessageToGuestBook(String message) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception('Must be logged in');
    }

    return FirebaseFirestore.instance.collection('guestbook').add(<String, dynamic>{
      'text': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'name': currentUser.displayName,
      'userId': currentUser.uid,
    });
  }
}
