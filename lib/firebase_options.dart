import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Emulator-only placeholder configuration. Every value below is a
/// throwaway that satisfies `Firebase.initializeApp()`'s shape without a
/// real Firebase project — this environment can't do the interactive
/// Google login `flutterfire configure` needs. `main.dart` points
/// Firestore/Storage at the local emulators in debug builds, so none of
/// these values are ever used to reach production.
///
/// To go live: run `flutterfire configure` against your real Firebase
/// project — it overwrites this exact file — and remove the emulator
/// wiring in `main.dart`.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web — run flutterfire configure.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for '
          '$defaultTargetPlatform — run flutterfire configure.',
        );
    }
  }

  static const android = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'demo-household-app',
    storageBucket: 'demo-household-app.appspot.com',
  );

  static const ios = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'demo-household-app',
    storageBucket: 'demo-household-app.appspot.com',
    iosBundleId: 'com.example.householdApp',
  );
}
