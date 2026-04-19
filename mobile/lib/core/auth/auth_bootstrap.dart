import 'package:firebase_auth/firebase_auth.dart';

class AuthBootstrap {
  Future<void> signInAnonymouslyIfNeeded() async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      return;
    }
    await auth.signInAnonymously();
  }
}
