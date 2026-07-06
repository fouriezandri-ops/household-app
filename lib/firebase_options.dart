import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Real Android config for the `household_app1` Firebase project (manually
/// entered from the Firebase console's "Add app" screen — no
/// `flutterfire configure` needed, see the Android block below for which
/// fields are still placeholders). `main.dart` only points Firestore/Storage
/// at the local emulators in debug builds, so release builds (the ones
/// installed on the two phones) use this config directly.
///
/// The iOS block is still an unused placeholder — iOS isn't part of the
/// current plan (no Mac available), so it's left as-is rather than filled in
/// speculatively.
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
    // TODO: paste the "Web API Key" / apiKey value from the Firebase console.
    apiKey: 'TODO-apiKey',
    appId: '1:726684429457:android:e7d82ad22f6e53dec96330',
    // Derived from the appId above (the number between the two colons).
    messagingSenderId: '726684429457',
    // TODO: paste the Project ID (not the project number) from the console.
    projectId: 'TODO-projectId',
    // TODO: paste the Storage bucket name from the console — recent
    // projects use a `*.firebasestorage.app` bucket, not `*.appspot.com`.
    storageBucket: 'TODO-storageBucket',
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
