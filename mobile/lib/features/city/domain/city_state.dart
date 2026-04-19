class Building {
  const Building({
    required this.id,
    required this.name,
    required this.level,
    required this.unlockStreak,
  });

  final String id;
  final String name;
  final int level;
  final int unlockStreak;

  Building copyWith({int? level}) {
    return Building(
      id: id,
      name: name,
      level: level ?? this.level,
      unlockStreak: unlockStreak,
    );
  }
}

class CityState {
  const CityState({
    required this.coins,
    required this.materials,
    required this.streakDays,
    required this.buildings,
  });

  factory CityState.initial() => const CityState(
        coins: 0,
        materials: 0,
        streakDays: 0,
        buildings: <Building>[
          Building(id: 'townhall', name: 'Town Hall', level: 1, unlockStreak: 0),
          Building(id: 'park', name: 'City Park', level: 0, unlockStreak: 2),
          Building(id: 'library', name: 'Library', level: 0, unlockStreak: 4),
          Building(id: 'tower', name: 'Sky Tower', level: 0, unlockStreak: 7),
        ],
      );

  final int coins;
  final int materials;
  final int streakDays;
  final List<Building> buildings;

  CityState copyWith({
    int? coins,
    int? materials,
    int? streakDays,
    List<Building>? buildings,
  }) {
    return CityState(
      coins: coins ?? this.coins,
      materials: materials ?? this.materials,
      streakDays: streakDays ?? this.streakDays,
      buildings: buildings ?? this.buildings,
    );
  }
}
