import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';

/// Re-locks the PIN gate after the app has been backgrounded for at least
/// [inactivityThreshold]. Briefly switching away (e.g. to check a
/// notification) does not force re-entry; only a longer absence does.
class InactivityLockObserver {
  InactivityLockObserver(
    this._ref, {
    this.inactivityThreshold = const Duration(minutes: 5),
  }) {
    _listener = AppLifecycleListener(onPause: _onPause, onResume: _onResume);
  }

  final WidgetRef _ref;
  final Duration inactivityThreshold;
  late final AppLifecycleListener _listener;
  DateTime? _pausedAt;

  void _onPause() => _pausedAt = DateTime.now();

  void _onResume() {
    final pausedAt = _pausedAt;
    _pausedAt = null;
    if (pausedAt == null) return;
    if (DateTime.now().difference(pausedAt) >= inactivityThreshold) {
      _ref.read(authControllerProvider.notifier).lock();
    }
  }

  void dispose() => _listener.dispose();
}
