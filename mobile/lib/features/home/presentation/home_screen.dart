import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../blocking/application/blocked_apps_controller.dart';
import '../../city/application/city_controller.dart';
import '../../city/domain/city_state.dart';
import '../../focus/application/focus_session_controller.dart';
import '../../focus/domain/focus_session.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final city = ref.watch(cityControllerProvider);
    final session = ref.watch(focusSessionControllerProvider);
    final blockedApps = ref.watch(blockedAppsControllerProvider);
    final appChoices = ref.watch(availableAppsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('City Focus')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _CityHeader(city: city),
          const SizedBox(height: 16),
          _SessionCard(session: session),
          const SizedBox(height: 16),
          _StartSessionControls(
            session: session,
            onStart: (int minutes) {
              ref.read(focusSessionControllerProvider.notifier).start(
                    durationMinutes: minutes,
                    blockedApps: blockedApps.toList(),
                  );
            },
          ),
          const SizedBox(height: 16),
          _BlockedAppsCard(
            availableApps: appChoices,
            blockedApps: blockedApps,
            onToggle: (String packageName, bool shouldBlock) {
              ref.read(blockedAppsControllerProvider.notifier).toggle(packageName, shouldBlock);
            },
          ),
          const SizedBox(height: 16),
          _CityBuildingsCard(buildings: city.buildings, streakDays: city.streakDays),
        ],
      ),
    );
  }
}

class _CityHeader extends StatelessWidget {
  const _CityHeader({required this.city});

  final CityState city;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF5B8CFF), Color(0xFF8D6CFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('My City', style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              'Streak ${city.streakDays} day${city.streakDays == 1 ? '' : 's'}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: <Widget>[
                _Pill(label: '${city.coins} coins'),
                _Pill(label: '${city.materials} materials'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});

  final FocusSession? session;

  @override
  Widget build(BuildContext context) {
    final status = switch (session?.outcome) {
      SessionOutcome.active => 'Focusing',
      SessionOutcome.success => 'Victory',
      SessionOutcome.failedBlockedApp => 'Failed',
      SessionOutcome.cancelled => 'Cancelled',
      null => 'Ready',
    };

    final subtitle = switch (session?.outcome) {
      SessionOutcome.active =>
        '${session?.remainingSeconds ?? 0}s remaining - stay away from blocked apps.',
      SessionOutcome.success => 'Session completed. Your city just grew.',
      SessionOutcome.failedBlockedApp => 'Blocked app opened. Session failed instantly.',
      _ => 'Start a focus session in one tap.',
    };

    return Card(
      child: ListTile(
        title: Text(status, style: Theme.of(context).textTheme.titleLarge),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(subtitle),
        ),
        leading: Icon(
          status == 'Failed'
              ? Icons.close_rounded
              : status == 'Victory'
                  ? Icons.emoji_events_rounded
                  : Icons.timer_outlined,
        ),
      ),
    );
  }
}

class _StartSessionControls extends StatefulWidget {
  const _StartSessionControls({
    required this.session,
    required this.onStart,
  });

  final FocusSession? session;
  final ValueChanged<int> onStart;

  @override
  State<_StartSessionControls> createState() => _StartSessionControlsState();
}

class _StartSessionControlsState extends State<_StartSessionControls> {
  int minutes = 25;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Quick Start', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Slider(
              value: minutes.toDouble(),
              min: 10,
              max: 90,
              divisions: 16,
              label: '$minutes min',
              onChanged: widget.session?.isActive == true
                  ? null
                  : (double value) => setState(() => minutes = value.round()),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.session?.isActive == true ? null : () => widget.onStart(minutes),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text('Start $minutes-minute session'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlockedAppsCard extends StatelessWidget {
  const _BlockedAppsCard({
    required this.availableApps,
    required this.blockedApps,
    required this.onToggle,
  });

  final List<String> availableApps;
  final Set<String> blockedApps;
  final void Function(String packageName, bool shouldBlock) onToggle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Blocked Apps (auto-fail mode)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              'If one of these apps opens during focus on Android, the session fails immediately.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            ...availableApps.map((String app) {
              final active = blockedApps.contains(app);
              return SwitchListTile(
                value: active,
                onChanged: (bool value) => onToggle(app, value),
                title: Text(app),
                contentPadding: EdgeInsets.zero,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CityBuildingsCard extends StatelessWidget {
  const _CityBuildingsCard({
    required this.buildings,
    required this.streakDays,
  });

  final List<Building> buildings;
  final int streakDays;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('City Progress', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...buildings.map((Building building) {
              final unlocked = building.level > 0;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(building.name),
                subtitle: Text(
                  unlocked
                      ? 'Level ${building.level} - unlocked'
                      : 'Unlock at streak ${building.unlockStreak}',
                ),
                trailing: Icon(
                  unlocked ? Icons.apartment_rounded : Icons.lock_outline_rounded,
                ),
              );
            }),
            const SizedBox(height: 8),
            Text('Keep your streak alive to unlock more city content. Current: $streakDays.'),
          ],
        ),
      ),
    );
  }
}
