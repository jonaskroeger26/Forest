import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/auth/auth_bootstrap.dart';
import 'core/firebase/firebase_options.dart';
import 'core/telemetry/analytics_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = FirebaseCrashReporter.recordFlutterError;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await AuthBootstrap().signInAnonymouslyIfNeeded();
  } catch (_) {
    // Allows local UI work before real Firebase credentials are configured.
  }

  runApp(const ProviderScope(child: CityFocusApp()));
}
