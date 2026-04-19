import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  AnalyticsService(this._analytics);

  final FirebaseAnalytics _analytics;

  Future<void> trackSessionStart({required int durationMinutes}) {
    return _analytics.logEvent(
      name: 'session_start',
      parameters: <String, Object>{'duration_minutes': durationMinutes},
    );
  }

  Future<void> trackSessionResult({required String outcome, required int focusSeconds}) {
    return _analytics.logEvent(
      name: 'session_result',
      parameters: <String, Object>{'outcome': outcome, 'focus_seconds': focusSeconds},
    );
  }

  Future<void> trackReward(int coins, int materials) {
    return _analytics.logEvent(
      name: 'reward_granted',
      parameters: <String, Object>{'coins': coins, 'materials': materials},
    );
  }
}

class FirebaseCrashReporter {
  static Future<void> recordFlutterError(FlutterErrorDetails details) async {
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
      return;
    }
    await FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  }
}
