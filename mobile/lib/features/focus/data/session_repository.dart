import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../domain/focus_session.dart';

abstract class SessionRepository {
  Future<void> save(FocusSession session);
}

class FirestoreSessionRepository implements SessionRepository {
  FirestoreSessionRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<void> save(FocusSession session) async {
    try {
      await _firestore.collection('sessions').doc(session.id).set(<String, dynamic>{
        'uid': FirebaseAuth.instance.currentUser?.uid,
        'startedAt': session.startedAt.toIso8601String(),
        'durationSeconds': session.durationSeconds,
        'elapsedSeconds': session.elapsedSeconds,
        'outcome': session.outcome.name,
        'failureReason': session.failureReason,
      });
    } catch (_) {
      if (kDebugMode) {
        return;
      }
      rethrow;
    }
  }
}
