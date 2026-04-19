import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/telemetry/telemetry_providers.dart';
import '../../blocking/data/blocked_app_monitor.dart';
import '../../city/application/city_controller.dart';
import '../../rewards/application/reward_engine.dart';
import '../data/session_repository.dart';
import '../domain/focus_session.dart';

final blockedAppMonitorProvider = Provider<BlockedAppMonitor>((_) => DemoBlockedAppMonitor());

final sessionRepositoryProvider = Provider<SessionRepository>(
  (_) => FirestoreSessionRepository(FirebaseFirestore.instance),
);

final rewardEngineProvider = Provider<RewardEngine>((_) => const RewardEngine());

class FocusSessionController extends StateNotifier<FocusSession?> {
  FocusSessionController(this.ref) : super(null);

  final Ref ref;
  Timer? _ticker;
  StreamSubscription<AppViolationEvent>? _monitorSub;

  Future<void> start({
    required int durationMinutes,
    required List<String> blockedApps,
  }) async {
    if (state?.isActive == true) {
      return;
    }

    final session = FocusSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startedAt: DateTime.now(),
      durationSeconds: durationMinutes * 60,
      elapsedSeconds: 0,
      outcome: SessionOutcome.active,
    );
    state = session;

    await ref.read(analyticsServiceProvider).trackSessionStart(durationMinutes: durationMinutes);

    _monitorSub?.cancel();
    _monitorSub = ref.read(blockedAppMonitorProvider).monitor(blockedApps).listen((event) {
      if (event == AppViolationEvent.blockedAppOpened) {
        failDueToBlockedApp();
      }
    });

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  Future<void> _tick() async {
    final current = state;
    if (current == null || !current.isActive) {
      return;
    }

    final nextElapsed = current.elapsedSeconds + 1;
    if (nextElapsed >= current.durationSeconds) {
      await completeSuccess();
      return;
    }
    state = current.copyWith(elapsedSeconds: nextElapsed);
  }

  Future<void> completeSuccess() async {
    final current = state;
    if (current == null || !current.isActive) {
      return;
    }

    _ticker?.cancel();
    await _monitorSub?.cancel();
    await ref.read(blockedAppMonitorProvider).stop();

    final successSession = current.copyWith(
      elapsedSeconds: current.durationSeconds,
      outcome: SessionOutcome.success,
    );
    state = successSession;
    await ref.read(sessionRepositoryProvider).save(successSession);

    final cityState = ref.read(cityControllerProvider);
    final reward = ref.read(rewardEngineProvider).rewardForSuccess(
          sessionMinutes: successSession.durationSeconds ~/ 60,
          currentStreak: cityState.streakDays,
        );
    ref.read(cityControllerProvider.notifier).applyReward(reward);

    await ref.read(analyticsServiceProvider).trackReward(reward.coins, reward.materials);
    await ref.read(analyticsServiceProvider).trackSessionResult(
          outcome: successSession.outcome.name,
          focusSeconds: successSession.elapsedSeconds,
        );
  }

  Future<void> failDueToBlockedApp() async {
    final current = state;
    if (current == null || !current.isActive) {
      return;
    }

    _ticker?.cancel();
    await _monitorSub?.cancel();
    await ref.read(blockedAppMonitorProvider).stop();

    final failed = current.copyWith(
      outcome: SessionOutcome.failedBlockedApp,
      failureReason: 'Opened blocked app while focus session was active.',
    );
    state = failed;
    ref.read(cityControllerProvider.notifier).handleFailure();
    await ref.read(sessionRepositoryProvider).save(failed);
    await ref.read(analyticsServiceProvider).trackSessionResult(
          outcome: failed.outcome.name,
          focusSeconds: failed.elapsedSeconds,
        );
  }
}

final focusSessionControllerProvider = StateNotifierProvider<FocusSessionController, FocusSession?>(
  (ref) => FocusSessionController(ref),
);
