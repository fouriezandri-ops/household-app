import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/lifecycle/inactivity_lock_observer.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    // Local Firestore/Storage emulators (see firebase.json) — swap
    // firebase_options.dart for a real project via `flutterfire configure`
    // and drop this block when moving off local dev.
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
  }

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
