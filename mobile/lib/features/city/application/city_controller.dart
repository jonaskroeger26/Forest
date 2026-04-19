import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../rewards/domain/reward.dart';
import '../domain/city_state.dart';

class CityController extends StateNotifier<CityState> {
  CityController() : super(CityState.initial());

  void applyReward(Reward reward) {
    final newStreak = state.streakDays + reward.streakDelta;
    final upgradedBuildings = state.buildings.map((Building b) {
      if (newStreak >= b.unlockStreak && b.level == 0) {
        return b.copyWith(level: 1);
      }
      return b;
    }).toList();

    state = state.copyWith(
      coins: state.coins + reward.coins,
      materials: state.materials + reward.materials,
      streakDays: newStreak,
      buildings: upgradedBuildings,
    );
  }

  void handleFailure() {
    final reducedStreak = state.streakDays > 0 ? state.streakDays - 1 : 0;
    state = state.copyWith(streakDays: reducedStreak);
  }
}

final cityControllerProvider = StateNotifierProvider<CityController, CityState>(
  (_) => CityController(),
);
