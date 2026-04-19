enum SessionOutcome { active, success, failedBlockedApp, cancelled }

class FocusSession {
  const FocusSession({
    required this.id,
    required this.startedAt,
    required this.durationSeconds,
    required this.elapsedSeconds,
    required this.outcome,
    this.failureReason,
  });

  final String id;
  final DateTime startedAt;
  final int durationSeconds;
  final int elapsedSeconds;
  final SessionOutcome outcome;
  final String? failureReason;

  bool get isActive => outcome == SessionOutcome.active;
  int get remainingSeconds => (durationSeconds - elapsedSeconds).clamp(0, durationSeconds);

  FocusSession copyWith({
    int? elapsedSeconds,
    SessionOutcome? outcome,
    String? failureReason,
  }) {
    return FocusSession(
      id: id,
      startedAt: startedAt,
      durationSeconds: durationSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      outcome: outcome ?? this.outcome,
      failureReason: failureReason ?? this.failureReason,
    );
  }
}
