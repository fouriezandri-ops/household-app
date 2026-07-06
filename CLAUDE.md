# Household app — project context

This file summarizes everything decided so far in planning. Read this at the
start of every session before touching code.

## What we're building

A private, shared household management app for two users (a couple). Five
synced lists: Grocery, Packing (per-trip), Admin To-Do, Products to Buy, and
Wishlist. The standout feature is moving items between lists (especially
Wishlist ↔ Products to Buy) without losing any data. Realtime sync between
both users is required. Eventually intended for the App Store and Play Store,
but today it's just for the two of us.

## Tech stack (confirmed)

- **Frontend**: Flutter
- **Backend**: Firebase (Cloud Firestore, Firebase Storage, FCM for push later)
- **State management**: Riverpod (`AsyncNotifier` + `riverpod_generator` for
  Firestore streams)
- **Navigation**: go_router
- **Architecture**: Clean Architecture + Repository Pattern
  - `lib/core/` — theme, routing, shared widgets, utils
  - `lib/features/{feature}/domain|data|presentation/` — one folder per
    feature (auth, grocery_list, packing_list, admin_todo, products_to_buy,
    wishlist, search, move_between_lists)
- **Offline**: Firestore's built-in offline persistence (no separate local DB
  like Drift/Isar needed for v1)

## Key decisions made during planning

1. **Images (Products to Buy / Wishlist)**: manual photo upload only for v1
   (stored in Firebase Storage). Auto-fetching website preview images/favicons
   is a nice-to-have for a later polish milestone, not v1.
2. **Auth**: PIN/passcode only — **no real Firebase Auth**. This was a
   deliberate, informed choice: it means Firestore security rules cannot
   verify identity via `request.auth.uid`, so rules are open
   (`allow read, write: if true`). This is acceptable for a private
   two-person app but would need revisiting before any public release.
3. **Bottom nav**: Home / Search / Settings tabs. The five lists are reached
   by tapping a card on the Home screen, not via five separate tabs (five tabs
   doesn't fit comfortably in a MD3 bottom bar). Open to revisiting if a
   "favourite list" shortcut tab is wanted later.
4. **Completed items**: shown inline, grayed out with strikethrough (not
   hidden or collapsed into a separate "Completed" section) — pending final
   confirmation, this was the working assumption in wireframes.
5. **Move between lists**: implemented as swipe-left (reveals move + delete
   actions) or long-press (context menu) on any list row.
6. **Firebase project**: this dev environment can't do the interactive
   Google login `flutterfire configure` needs, so there's no real Firebase
   project yet. The app runs against the local Firestore/Storage emulators
   (`firebase.json`, `demo-household-app` project ID in
   `lib/firebase_options.dart`) until you run `flutterfire configure`
   yourself against a real project — see milestone 6 below.
7. **Per-device identity without auth**: no Firebase Auth means no
   `request.auth.uid` to derive `addedBy`/`assignedTo`/`memberUids` from.
   Household and member IDs are fixed constants (`lib/core/constants/
   household_constants.dart`) so both partners' installs converge on the
   same `/households/default` doc with no pairing step, and each device
   picks "who it is" once via a local-only (not synced) screen after the
   PIN gate, storing the choice in secure storage.

## Firestore schema (confirmed — see full detail below)

Single shared `items` collection per household, discriminated by a `listType`
field, rather than five separate collections — this is what makes moving
items between lists a single field update instead of a delete-and-recreate.

```
/households/{householdId}
    name: string
    memberUids: [uid1, uid2]
    createdAt: timestamp

/households/{householdId}/items/{itemId}
    id: string
    listType: "grocery" | "packing" | "admin" | "products_to_buy" | "wishlist"
    title: string
    notes: string | null
    category: string | null
    priority: "low" | "medium" | "high" | null
    completed: boolean
    imageUrl: string | null
    addedBy: uid
    dateAdded: timestamp
    dateCompleted: timestamp | null
    details: {
      quantity: number | null            // grocery
      unit: string | null                // grocery
      tripId: string | null              // packing -> /trips/{tripId}
      description: string | null         // admin
      dueDate: timestamp | null          // admin
      assignedTo: uid | null             // admin
      store: string | null               // products_to_buy / wishlist
      websiteUrl: string | null          // products_to_buy / wishlist
      price: number | null               // products_to_buy / wishlist
      desiredQuantity: number | null     // products_to_buy
    }
    history: [ { listType: string, movedAt: timestamp } ]

/households/{householdId}/trips/{tripId}
    name: string              // e.g. "Japan 2027"
    destination: string | null
    startDate: timestamp | null
    endDate: timestamp | null
    createdBy: uid
    createdAt: timestamp

/users/{uid}
    displayName: string
    colorTag: string
    fcmToken: string | null
```

Moving an item (e.g. Wishlist → Products to Buy):
1. Update `listType`.
2. Carry over the fields common to both lists (price, websiteUrl, notes,
   category, priority).
3. Append `{ listType, movedAt: now }` to `history` — nothing is overwritten.

**Composite indexes needed** (`firestore.indexes.json`; no `householdId` field
in the index definitions themselves — `items`/`trips` are subcollections
under `/households/{householdId}`, so the parent path already scopes every
query and a collection-scoped composite index is enough):
- `items`: `listType` + `completed` + `dateAdded` (desc) — for the "not
  purchased" filter chip, milestone 14
- `items`: `listType` + `priority`
- `items`: `listType` + `category`
- `trips`: single-field `startDate` (desc) ordering only — Firestore
  auto-indexes this, no composite index needed

**Security rules (open, per decision #2 above):**
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

## Wireframes (agreed direction)

- **Home screen**: five rounded cards (Grocery, Packing, Admin, Products to
  Buy, Wishlist), each showing item count + completed count + recent
  activity. Floating add button bottom-right. Bottom nav: Home / Search /
  Settings.
- **List detail screen** (e.g. Grocery): filter chips at top (All / Not
  purchased / category chips), rows with a checkbox-style completion toggle,
  "added by" tag on the right, swipe-left to reveal move/delete actions.

## Milestone plan and status

1. ✅ Project plan
2. ✅ Wireframes (home screen, grocery list detail)
3. ✅ Firestore schema design
4. ✅ **Navigation design — finalized.** go_router with a
   `StatefulShellRoute.indexedStack` for the bottom-nav tabs (Home / Search /
   Settings), each of the five lists as a pushed route from Home, Packing
   nested under a trip-picker (`/home/packing` → `/home/packing/:tripId`),
   a reserved deep-link route for admin items (`/home/admin/:itemId`) ahead
   of FCM, add/edit/move/trip-create all as modal bottom sheets, and a PIN
   gate (`/pin`) guarded by a `GoRouter` redirect on cold start plus a
   lifecycle-based re-lock after an inactivity threshold. Full route table
   and rationale in `docs/navigation.md`.
5. ✅ **Authentication — done.** Flutter project scaffolded (`flutter create`,
   org `com.example` — placeholder, change before store submission) as the
   prerequisite for any code. PIN gate implemented per `docs/navigation.md`:
   `lib/features/auth/` (domain `PinRepository` interface, data layer
   hashing the PIN with salted PBKDF2-HMAC-SHA256 and storing it via
   `flutter_secure_storage` — Keychain/Keystore, never plaintext —
   presentation layer with a Riverpod `AuthController` AsyncNotifier and the
   `PinGateScreen`/keypad UI). `lib/core/router/app_router.dart` wires the
   go_router redirect + `lib/core/lifecycle/inactivity_lock_observer.dart`
   handles the inactivity re-lock. `firestore.rules` added at repo root with
   the open rules from decision #2. Unit + widget tests in `test/features/auth/`;
   `flutter analyze` and `flutter test` both pass. Not verified: an actual
   run on a device/emulator/Chrome — this environment has no Android/iOS/
   Chrome toolchain installed, only the Dart/Flutter SDK for analysis and
   testing.
6. ✅ **Shared database setup — done.** No real Firebase project (decision
   #6 above) — wired to the local emulators instead: `firebase_core`,
   `cloud_firestore`, `firebase_storage` added; `lib/firebase_options.dart`
   is a placeholder `demo-household-app` config; `main.dart` calls
   `Firebase.initializeApp()` then points Firestore/Storage at
   `localhost:8080`/`:9199` in debug builds; `firebase.json` +
   `firestore.indexes.json` + `storage.rules` added at repo root for
   `firebase emulators:start`.
   Domain entities (`lib/core/domain/entities/`): `Item` (+ `ItemDetails`,
   `HistoryEntry`, `ListType`, `Priority`), `Trip`, `Household`,
   `HouseholdMember` — hand-written `fromFirestore`/`toFirestore`, no
   codegen. Repository pattern (`lib/core/data/`): a generic
   `FirestoreRepository<T>` base (CRUD + `watchAll`) built on
   `withConverter`, with `ItemsRepository` (`watchByListType`,
   `moveToList` — updates `listType` + optional `details` + appends to
   `history`) and `TripsRepository` extending it, plus a standalone
   `HouseholdRepository` (spans the `households` and `users` top-level
   collections; `ensureSeeded()` idempotently creates the fixed household +
   two members per decision #7). Riverpod providers wiring these in
   `lib/core/providers/firestore_providers.dart`.
   Identity feature (`lib/features/household/`): a local-only
   `MemberSelectionRepository` (secure storage, mirrors the PIN
   repository's shape) + `CurrentMemberController`, and a `PickMemberScreen`
   wired into the router (`/pick-member`, gated after `/pin` — see
   `lib/core/router/app_router.dart`'s expanded redirect).
   Tests: `fake_cloud_firestore`-backed repository tests (CRUD, list-type
   filtering/ordering, move-between-lists, idempotent seeding) plus a
   controller test for member selection, all under `test/core/data/` and
   `test/features/household/`. `flutter analyze` and `flutter test` both
   pass. Not verified: the emulators actually running end-to-end against
   the compiled app (no Android/iOS/Chrome toolchain in this environment —
   same limitation noted in milestone 5).
7. ✅ **Grocery List — done.** `lib/features/grocery_list/`: real
   `GroceryListScreen` replacing the placeholder, streaming
   `ItemsRepository.watchByListType(ListType.grocery)`. Filter chips (All /
   Not purchased / one per distinct category present) via a
   `GroceryFilterController` + pure `applyGroceryFilter` function — a
   single active filter, not combinable (full combinable filtering is
   milestone 14). Rows (`GroceryListTile`): checkbox toggles `completed`,
   strikethrough + greyed when done (decision #4), "added by" chip resolved
   from `householdMembersProvider`, swipe-left (via `flutter_slidable`) to
   reveal **Delete** with a confirmation dialog — **Move** is deliberately
   not wired here (would be a stub); it lands with the destination-picker
   UX in milestone 12. Add/edit is a modal bottom sheet
   (`AddEditGroceryItemSheet`, per the navigation design) covering
   title/quantity/unit/category/notes; editing preserves `addedBy`/
   `dateAdded`/`history`.
   Tests: pure filter-logic tests, plus `fake_cloud_firestore`-backed widget
   tests (add via FAB, toggle complete, filter chip) under
   `test/features/grocery_list/`. `flutter analyze` and `flutter test` both
   pass. Not verified: real device/emulator run, or the swipe gesture and
   keyboard/focus behavior interactively — same toolchain limitation as
   prior milestones.
8. ✅ **Packing List — done.** Since this is the second list built (with
   three more to come), first extracted the reusable pieces from Grocery
   into `lib/core/`: `ItemFilter`/`applyItemFilter` (generalized from
   `GroceryFilter`, `lib/core/domain/entities/item_filter.dart`),
   `ItemFilterChipRow` and `ItemListTile` (`lib/core/presentation/widgets/`
   — completion checkbox, strikethrough, added-by chip, swipe-left delete
   with confirmation; Move still deliberately omitted, same reasoning as
   milestone 7). Grocery now consumes these shared pieces instead of its
   own copies. Added `FirestoreRepository.watchById` and
   `ItemsRepository.watchByTripId` (+ its composite index in
   `firestore.indexes.json`).
   `lib/features/packing_list/`: `PackingTripsScreen` (trip picker,
   `TripsRepository.watchAllByStartDate`, add-trip modal sheet) and
   `PackingTripDetailScreen` (`/home/packing/:tripId` — items for that trip,
   filter chips, add-item modal sheet, edit-trip action in the app bar).
   Packing items only ever use `details.tripId` (no quantity/unit — those
   are grocery-only per the schema).
   Tests: repository test for `watchByTripId`, plus
   `fake_cloud_firestore`-backed widget tests for both screens under
   `test/features/packing_list/`; the filter-logic test moved to
   `test/core/domain/item_filter_test.dart` since the logic it covers is no
   longer grocery-specific. `flutter analyze` and `flutter test` both pass
   (30/30). Not verified: real device/emulator run, same toolchain
   limitation as prior milestones.
9. ✅ **Admin List — done.** `lib/features/admin_todo/`: real
   `AdminTodoScreen` (filter chips, shared `ItemListTile`) and a fuller
   add/edit sheet than grocery/packing — title, description
   (`details.description` — a separate field from the generic top-level
   `notes` also on the form; both exist per the confirmed schema, even
   though that reads as some overlap), due date (with a clear button),
   priority (chip row: None/Low/Medium/High), and an "assigned to" dropdown
   over the two household members. `AdminTodoTile` shows due date/
   priority/assigned-to in its subtitle.
   Also finished the reserved `/home/admin/:itemId` deep-link route from
   milestone 4: `AdminItemDetailScreen` now actually resolves the item
   (via a new generic `itemByIdProvider` in `lib/core/providers/
   firestore_providers.dart`) and auto-opens the edit sheet on top of the
   admin list once it loads, instead of the placeholder text — ready for
   milestone 15 (FCM) to link into it, with nothing to retrofit.
   **Bug found and fixed while testing:** all four add/edit bottom sheets
   (grocery, trip, packing item, admin) had their `Form` content in a bare
   `Column` with no scroll container — fine when the form is short, but
   the admin sheet (the tallest one) actually overflowed and threw a
   `RenderFlex` error in a test. Fixed by wrapping all four in
   `SingleChildScrollView`, so none of them can overflow once the
   on-screen keyboard eats into the available height.
   Tests: widget tests for both admin screens (add with priority, filter
   chip, deep-link auto-open) under `test/features/admin_todo/`. `flutter
   analyze` and `flutter test` both pass (33/33). Not verified: real
   device/emulator run, same toolchain limitation as prior milestones.
10. ⬜ Products To Buy
11. ⬜ Wishlist
12. ⬜ Move-between-lists functionality
13. ⬜ Search
14. ⬜ Filters
15. ⬜ Notifications (FCM)
16. ⬜ UI polish
17. ⬜ Code review
18. ⬜ Performance optimization

**Ground rule carried over from the original brief:** after every milestone,
stop and wait for explicit approval before continuing to the next one. Always
explain pros/cons before choosing between implementation options. Produce
production-quality, commented code throughout.

## Next step

Milestone 9 is done. Awaiting explicit approval to start milestone 10
(Products To Buy), per the ground rule.
