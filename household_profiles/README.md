# Household profiles

Each file here (except `_example.json`) is one household's config: their own
Firebase project (so their data is fully isolated from every other
household — nothing is shared except this codebase) plus their household
name and member names. `.github/workflows/build-apk.yml` builds one APK per
profile automatically, on every push.

## Adding a new household

1. Have that household create their own free Firebase project
   (console.firebase.google.com → Add project → enable Firestore) and
   register an Android app in it (any package name — this repo currently
   builds under `com.example.household_app1` for every profile; see
   `android/app/build.gradle.kts` if a household ever needs their own).
2. Copy `_example.json` to `<their-id>.json` (short, filesystem-safe — this
   becomes part of the artifact name in CI) and fill in the `REPLACE-*`
   placeholders: the 4 Firebase values from their project settings, their
   household name, and their member names/colors.
3. Deploy `firestore.rules`/`firestore.indexes.json` to their project —
   same steps as the primary household (`firebase login` +
   `firebase deploy`, or paste the rules into the console by hand).
4. Commit and push the new profile file. The next `build-apk.yml` run
   builds an APK for every profile in this directory, including the new
   one, uploaded as a separate artifact named
   `household-app-release-apk-<their-id>`.

## Local testing

`dart run tool/apply_household_profile.dart household_profiles/<id>.json`
regenerates `lib/firebase_options.dart` and
`lib/core/constants/household_constants.dart` from a profile — run this
before `flutter run`/`flutter build` to test against a specific household.
The committed versions of those two generated files currently match
`zandri-renier.json`; running `flutter analyze`/`flutter test` without
applying a profile first still works, since they're just regular (if
generated) source files.
