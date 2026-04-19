import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/home_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';

final _hasSeenOnboardingProvider = StateProvider<bool>((_) => false);

final appRouterProvider = Provider<GoRouter>((ref) {
  final hasSeenOnboarding = ref.watch(_hasSeenOnboardingProvider);

  return GoRouter(
    initialLocation: hasSeenOnboarding ? '/home' : '/onboarding',
    routes: <RouteBase>[
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => OnboardingScreen(
          onContinue: () {
            ref.read(_hasSeenOnboardingProvider.notifier).state = true;
          },
        ),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeScreen(),
      ),
    ],
    redirect: (_, state) {
      if (!hasSeenOnboarding && state.fullPath != '/onboarding') {
        return '/onboarding';
      }
      if (hasSeenOnboarding && state.fullPath == '/onboarding') {
        return '/home';
      }
      return null;
    },
  );
});
