import 'package:flutter_riverpod/flutter_riverpod.dart';

final availableAppsProvider = Provider<List<String>>((_) {
  return <String>[
    'com.snapchat.android',
    'com.instagram.android',
    'com.zhiliaoapp.musically',
    'com.twitter.android',
  ];
});

class BlockedAppsController extends StateNotifier<Set<String>> {
  BlockedAppsController() : super(<String>{'com.snapchat.android'});

  void toggle(String packageName, bool shouldBlock) {
    final next = Set<String>.from(state);
    if (shouldBlock) {
      next.add(packageName);
    } else {
      next.remove(packageName);
    }
    state = next;
  }
}

final blockedAppsControllerProvider =
    StateNotifierProvider<BlockedAppsController, Set<String>>((_) => BlockedAppsController());
