import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/lifecycle/inactivity_lock_observer.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: HouseholdApp()));
}

class HouseholdApp extends ConsumerStatefulWidget {
  const HouseholdApp({super.key});

  @override
  ConsumerState<HouseholdApp> createState() => _HouseholdAppState();
}

class _HouseholdAppState extends ConsumerState<HouseholdApp> {
  late final InactivityLockObserver _inactivityLockObserver;

  @override
  void initState() {
    super.initState();
    _inactivityLockObserver = InactivityLockObserver(ref);
  }

  @override
  void dispose() {
    _inactivityLockObserver.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Household',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
