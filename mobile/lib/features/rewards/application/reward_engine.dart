import '../domain/reward.dart';

class RewardEngine {
  const RewardEngine();

  Reward rewardForSuccess({
    required int sessionMinutes,
    required int currentStreak,
  }) {
    final baseCoins = (sessionMinutes * 2).clamp(10, 120);
    final streakBonus = (currentStreak * 2).clamp(0, 50);
    final materials = (sessionMinutes / 10).ceil() + (currentStreak >= 3 ? 1 : 0);
    return Reward(
      coins: baseCoins + streakBonus,
      materials: materials,
      streakDelta: 1,
    );
  }
}
