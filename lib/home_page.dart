// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'guest_book.dart';
import 'providers/auth_providers.dart';
import 'providers/guestbook_providers.dart';
import 'src/authentication.dart';
import 'src/widgets.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loggedIn = ref.watch(loggedInProvider);
    final messagesAsync = ref.watch(guestbookMessagesProvider);
    final guestbookService = ref.watch(guestbookServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Meetup')),
      body: ListView(
        children: <Widget>[
          Image.asset('assets/codelab.png'),
          const SizedBox(height: 8),
          const IconAndDetail(Icons.calendar_today, 'October 30'),
          const IconAndDetail(Icons.location_city, 'San Francisco'),
          AuthFunc(
            loggedIn: loggedIn,
            signOut: () {
              FirebaseAuth.instance.signOut();
            },
          ),
          const Divider(
            height: 8,
            thickness: 1,
            indent: 8,
            endIndent: 8,
            color: Colors.grey,
          ),
          const Header("What we'll be doing"),
          const Paragraph(
            'Join us for a day full of Firebase Workshops and Pizza!',
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (loggedIn) ...[
                const Header('Discussion'),
                messagesAsync.when(
                  data: (messages) => GuestBook(
                    addMessage: (message) =>
                        guestbookService.addMessageToGuestBook(message),
                    messages: messages,
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Text('Error: $error'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
