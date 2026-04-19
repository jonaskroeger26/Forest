import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum AppViolationEvent { blockedAppOpened }

abstract class BlockedAppMonitor {
  Stream<AppViolationEvent> monitor(List<String> blockedPackages);
  Future<void> stop();
}

class DemoBlockedAppMonitor implements BlockedAppMonitor {
  final StreamController<AppViolationEvent> _controller = StreamController<AppViolationEvent>.broadcast();
  StreamSubscription<dynamic>? _channelSub;

  static const MethodChannel _channel = MethodChannel('city_focus/blocked_apps');
  static const EventChannel _eventChannel = EventChannel('city_focus/blocked_apps_events');

  @override
  Stream<AppViolationEvent> monitor(List<String> blockedPackages) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      _channel.invokeMethod<void>('startMonitoring', <String, dynamic>{
        'packages': blockedPackages,
      });
      _channelSub ??= _eventChannel.receiveBroadcastStream().listen((dynamic event) {
        if (event == 'blocked_app_opened') {
          _controller.add(AppViolationEvent.blockedAppOpened);
        }
      });
    }
    return _controller.stream;
  }

  @override
  Future<void> stop() async {
    await _channel.invokeMethod<void>('stopMonitoring');
    await _channelSub?.cancel();
    _channelSub = null;
  }
}
