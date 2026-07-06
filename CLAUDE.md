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
10. ✅ **Products To Buy — done.** First list to use `imageUrl`, so this is
   where decision #1 (manual photo upload, Firebase Storage) actually gets
   built: `lib/core/data/image_upload_service.dart`
   (`ImageUploadService` interface + `FirebaseImageUploadService`, storing
   at `item_images/{itemId}.jpg`) and `lib/core/providers/
   storage_providers.dart`. `ItemListTile` (core, shared) grew an optional
   thumbnail next to the checkbox when `item.imageUrl` is set. Also added
   `url_launcher` so the website-URL field has an "open" button.
   `lib/features/products_to_buy/`: real screen + add/edit sheet (store,
   website URL, price, desired quantity, category, notes, photo — camera
   or gallery via `image_picker`, with preview/remove before saving). A
   new item's ID is pre-generated client-side (`collection.doc().id`,
   never written) so the photo can upload to its final path before the
   Firestore doc exists.
   **Two real bugs found while building/testing this and fixed across all
   four sheets (grocery/packing/admin/products):**
   1. `Item.copyWith(field: null)` could never actually clear a nullable
      field back to null — the usual `field ?? this.field` pattern just
      falls back to the old value. Every edit path that tried to clear a
      category/notes/priority was silently failing to. Fixed by deleting
      `copyWith` entirely and having each edit path construct a fresh
      `Item(...)` with every field explicit; locked in with a regression
      test (`test/features/grocery_list/grocery_list_screen_test.dart`:
      "editing an item can clear a previously-set category").
   2. None of the four sheets reset `_isSaving` or surfaced an error if
      `_save()` actually threw — a real failure would leave the spinner
      running forever. Caught because the products sheet unconditionally
      read `imageUploadServiceProvider` (→ real `FirebaseStorage.instance`)
      even when no photo was touched, which throws with no Firebase app
      initialized in tests, hanging `pumpAndSettle`. Fixed by making that
      read lazy (only touches Storage when a photo was actually
      added/removed) and wrapping all four `_save()` methods in
      try/catch/finally-equivalent handling that resets `_isSaving` and
      shows a SnackBar on failure.
   Tests under `test/features/products_to_buy/`: add with store/price,
   filter chip, thumbnail rendering. `flutter analyze` and `flutter test`
   both pass (37/37). Not verified: an actual photo pick/upload — that
   needs `image_picker`'s platform channel, which isn't mocked here, so
   the picker flow itself is untested (only the save path with no photo,
   and rendering an already-set `imageUrl`). Same device/emulator
   limitation as prior milestones otherwise.
11. ✅ **Wishlist — done. All five lists now built (milestones 7-11).**
   Wishlist and Products to Buy share almost every field (store,
   websiteUrl, price, imageUrl — only `desiredQuantity` is
   products-to-buy-only per the schema), and this was the third
   near-identical list in a row, so the add/edit sheet and tile moved to
   `lib/core/presentation/widgets/` as `ShoppableItemSheet`/
   `ShoppableItemTile`, parameterized by `listType`/`itemTypeLabel`/
   `fieldLabel`/`showDesiredQuantity`. Both `lib/features/products_to_buy/`
   and the new `lib/features/wishlist/` are now thin wrappers (a
   `showAddEditXSheet` function and a one-line tile class) over the shared
   widgets — products_to_buy's own sheet/tile were rewritten in place as
   part of this, no behavior change. This also directly sets up milestone
   12 (move-between-lists, especially Wishlist ↔ Products to Buy): since
   both lists already read/write the identical `ItemDetails` shape, a move
   between them won't need any field-translation logic.
   Wishlist screen: filter chips ("Not received" for the not-completed
   label), add/edit sheet without the quantity field.
   Tests: `test/features/wishlist/` covers add-with-store/price (and
   asserts the quantity field is absent), and the filter chip; the
   products_to_buy tests were unaffected by the refactor. `flutter analyze`
   and `flutter test` both pass (39/39). Not verified: real device/emulator
   run, same limitation as prior milestones.
12. ✅ **Move-between-lists — done.** The app's standout feature per the
   original brief. `ItemListTile`'s swipe-left now reveals **Move**
   alongside Delete (`extentRatio` widened to 0.5 for two actions); Move
   opens `lib/features/move_between_lists/presentation/widgets/
   move_item_sheet.dart` (`MoveItemSheet`), listing the other four lists.
   Picking a non-Packing target moves immediately; picking Packing opens a
   second step (`showTripPickerSheet`, `lib/features/packing_list/
   presentation/widgets/trip_picker_sheet.dart`, reusable wherever a trip
   needs picking) since a packing item needs a `tripId`.
   Field-carrying rule (`ItemDetails.filterForListType`, `lib/core/domain/
   entities/item.dart`): every top-level `Item` field (title, category,
   priority, notes, imageUrl, addedBy, dateAdded, completed,
   dateCompleted) always carries over unchanged; only `details` gets
   filtered down to whichever fields the destination list actually uses
   (e.g. wishlist -> products-to-buy keeps store/websiteUrl/price, adds no
   desiredQuantity; packing's `tripId` is replaced with the newly-picked
   one and dropped entirely for every other destination). `history` gets
   the new entry appended via the existing `ItemsRepository.moveToList`
   from milestone 6 — nothing new needed there.
   While adding this, also deleted `ItemDetails.copyWith` — same
   unused/never-actually-clears-null footgun as `Item.copyWith`, removed
   in milestone 10.
   Tests: pure unit tests for `filterForListType` (one per destination,
   proving irrelevant fields are actually dropped, not just absent to
   start with) in `test/core/domain/`; widget tests in
   `test/features/move_between_lists/` for both the direct-move and
   move-to-packing-via-trip-picker paths; an integration test in
   `test/core/presentation/item_list_tile_test.dart` proving the swipe
   action is actually wired (not just that the sheet works in isolation).
   **Test-writing pitfall hit and fixed:** that last test initially hung —
   `await Slidable.of(context)!.openEndActionPane()` awaits an animation
   that only advances via `tester.pump()`, so awaiting it directly before
   any pump deadlocks; fixed by firing it unawaited and driving the
   animation with `pumpAndSettle()` afterward instead.
   `flutter analyze` and `flutter test` both pass (47/47). Not verified:
   the actual swipe gesture or trip-picker UX on a real device/emulator —
   same limitation as prior milestones.
13. ✅ **Search — done.** Replaces the `/search` placeholder. Cross-list
   by design (the one screen not scoped to a single `listType`):
   `allItemsProvider` streams `ItemsRepository.watchAll()`, and a pure
   `searchItems(items, query)` function does a case-insensitive substring
   match against title/category/notes — client-side filtering, not a
   search index, since a household's item count doesn't warrant one.
   Empty query shows a prompt rather than every item. Each result
   (`SearchResultTile`) shows which list it's from and dispatches to that
   list's own add/edit sheet by `listType` when tapped — the one place
   that needs to switch on list type at runtime, since every other screen
   already knows its own type at compile time.
   Along the way, extracted the `ListType -> (label, icon)` mapping
   `MoveItemSheet` had inlined (milestone 12) into shared extensions:
   `ListTypeDisplayName` (`lib/core/domain/entities/list_type.dart`, no
   Flutter dependency) and `ListTypeIcon`
   (`lib/core/presentation/list_type_icons.dart`, split out specifically
   because `IconData` would otherwise pull Flutter into the domain layer).
   `MoveItemSheet` now uses these too instead of its own copy.
   Tests: pure tests for `searchItems` (empty query, case-insensitivity,
   category/notes matching, no-match) plus widget tests for the screen
   (filtering across lists, tapping a result opens the correct list's
   sheet) under `test/features/search/`. `flutter analyze` and `flutter
   test` both pass (53/53). Not verified: real device/emulator run, same
   limitation as prior milestones.
14. ✅ **Filters — done.** Upgrades the single-select filter chips every
   list screen got in milestones 7-11 (explicitly deferred there, "full
   combinable filtering is milestone 14") into real combinable filtering:
   `ItemFilterState` (`lib/core/domain/entities/item_filter.dart`) replaced
   the old sealed-class single-choice `ItemFilter` with a `notCompletedOnly`
   toggle AND any number of selected `categories` (categories OR'd
   together, the two dimensions AND'd) — "All" is a computed reset
   (`isEmpty`/`clear()`), not a stored state. `ItemFilterChipRow` switched
   from `ChoiceChip` (radio-button, one at a time) to `FilterChip`
   (independently toggleable). All five `XFilterController`s
   (grocery/packing/admin/products/wishlist) mechanically updated to the
   same new shape — each is still just `build() => const
   ItemFilterState()` + a single `update(value)` setter, no behavioral
   logic duplicated per list since `ItemFilterChipRow` computes the next
   state itself via `ItemFilterState`'s toggle methods.
   Tests: rewrote `test/core/domain/item_filter_test.dart` for the new
   combinable model (OR across categories, AND with notCompletedOnly,
   toggle-twice-clears, `clear()`); added a grocery widget test proving two
   filters combine rather than replace each other end-to-end (hit and fixed
   an ambiguous-widget-match failure along the way — an item's category
   subtitle text and the same-named filter chip both matched `find.text`,
   fixed with `find.widgetWithText(FilterChip, ...)`). `flutter analyze`
   and `flutter test` both pass (58/58). Not verified: real device/emulator
   interaction with the chips, same limitation as prior milestones.
15. ⏸️ **Notifications — deliberately deferred, not started.** Real push
   needs a server-side trigger (something must decide *when* to send —
   e.g. a Cloud Function reacting to Firestore writes for "assigned to
   you" alerts), which is new infrastructure beyond anything in CLAUDE.md's
   tech stack decisions, and this environment can't test real FCM delivery
   either way (no real Firebase project — decision #6 — and no device/
   simulator with Google Play services or APNs). Discussed the fork
   (admin due-date reminders vs. cross-device assigned-to-you alerts;
   local `flutter_local_notifications` vs. real `firebase_messaging`
   plumbing) and decided to skip it for now rather than build blind, and
   move on to milestone 16. Revisit once there's a real Firebase project
   and an actual decision on the trigger mechanism.
16. ✅ **UI polish — done (one concrete gap closed; more can follow on
   request).** The original wireframe called for Home cards showing "item
   count + completed count + recent activity" plus a floating add button
   — neither was ever built (Home shipped as bare navigation cards in
   milestone 4/5, and milestone 7 deliberately deferred its FAB pending
   all five lists existing). Closed both:
   `lib/features/home/domain/list_stats.dart` (`computeListStats`, a pure
   function bucketing all items by `listType` into total/completed/most-
   recent-title) now backs real card subtitles instead of nothing. The
   FAB opens `QuickAddSheet` (`lib/features/home/presentation/widgets/`):
   pick a list, add straight to it without leaving Home — Packing routes
   through the same trip-picker the Packing tab uses first, every other
   list opens its add sheet immediately. (Bug caught while writing this:
   the first draft popped the chooser sheet then reused its own
   `BuildContext` to open the next sheet — unsafe, since that context
   belongs to a widget being torn down. Fixed so the chooser only returns
   which list was picked, and the caller's own context does the
   dispatching once the chooser has fully closed.)
   Moved `allItemsProvider` from the search feature into
   `lib/core/providers/firestore_providers.dart` since Home now needs the
   same all-lists stream Search already did.
   Tests: pure tests for `computeListStats`, plus widget tests for the
   Home cards and both `QuickAddSheet` paths (direct-add and
   add-via-trip-picker) under `test/features/home/`. `flutter analyze` and
   `flutter test` both pass (63/63). Not verified: real device/emulator
   run, same limitation as prior milestones. Scope note: this closed the
   one concrete, spec'd gap (Home); no other polish (theming, animations,
   app icon/branding assets) was done speculatively — say the word if
   there's something specific to refine next.
17. ✅ **Code review — done.** Full-project review (8 independent finder
   angles across the whole codebase, then a 1-vote verification pass on
   each correctness candidate) surfaced 8 confirmed bugs and 2 duplication
   cleanups; all 10 were fixed with regression tests, per your direction.
   **Correctness fixes:**
   1. All four add/edit sheets did a full-document `.set()` on save using
      `completed`/`dateCompleted`/`history` captured when the sheet
      opened — a lost-update race where editing an item could silently
      revert a concurrent change (e.g. the other partner checking it off
      while you were mid-edit). Fixed by switching the edit path to a
      partial `updateFields()` that only touches the fields each form
      actually owns.
   2. `priority` (top-level, Admin-only in practice) was never cleared by
      `moveToList`, so it could linger forever on an item after moving off
      Admin. Added `Item.priorityForListType` (mirrors
      `ItemDetails.filterForListType`) and made `moveToList` always write
      priority explicitly.
   3. Swipe-to-delete never cleaned up Firebase Storage, leaking a photo
      blob forever for every deleted Products-to-Buy/Wishlist item.
      `ItemListTile`'s delete now best-effort deletes the image too.
   4. The PIN gate had no try/catch around `createPin`/`unlock` — a
      Keystore/Keychain failure would leave the spinner stuck forever,
      permanently freezing the keypad (the four list sheets got this fix
      back in milestone 10; the PIN gate never did). Now catches, shows an
      error, and resets.
   5. `MoveItemSheet`'s packing branch was missing the `context.mounted`
      check after awaiting the trip picker that `QuickAddSheet`'s
      identical branch already had — added it.
   6. Search's packing-item dispatch force-unwrapped `details.tripId!`;
      now shows a graceful error instead of crashing if a packing item is
      ever missing one.
   7. The Price field silently discarded unparseable input (e.g. typing
      "$19.99") with no feedback. Added a validator and a `$` prefix hint.
   8. A grocery item's unit only displayed if quantity was also set, so a
      unit-only entry (e.g. "bag" with no quantity) silently vanished from
      the tile. Fixed the subtitle logic to show whichever is set.
   **Cleanup:** the five `XFilterController`s (grocery/packing/admin/
   products/wishlist — byte-for-byte identical aside from generated
   names) collapsed into one family provider, `ListFilterController`
   (`lib/core/providers/list_filter_providers.dart`), keyed by `ListType`.
   The four near-identical list screens (grocery/admin/products/wishlist)
   collapsed into one generic `ItemListScreen`
   (`lib/core/presentation/widgets/`), each now a ~15-line wrapper
   supplying title/listType/label/tileBuilder/onAddPressed; a matching
   `itemsByListType` family provider replaced the four per-list item
   streams. Packing keeps its own screen (trip-specific chrome) but now
   shares the same filter controller.
   Tests: a regression test added for each of the 8 fixes (lost-update
   race, priority-cleared-on-move in both directions, storage cleanup on
   delete, PIN-gate recovery, tripId-missing graceful error, price
   validation, unit-only display); the cleanup required no new tests since
   existing per-list screen tests now exercise the shared implementation
   directly. `flutter analyze` and `flutter test` both pass (71/71).
18. ✅ **Performance optimization — done. This was the last milestone in the
   plan.** Rather than a fresh audit, acted on the three efficiency-angle
   findings the milestone-17 code review surfaced but didn't make the
   top-10 cut (correctness bugs were prioritized there):
   1. **Fixed** — `HouseholdRepository.ensureSeeded()` did 3 sequential
      `await`s (the household-doc check/set, then a `for` loop of 2
      member-doc checks/sets) on every cold start, even though all 3 are
      independent. Split into `_ensureHouseholdSeeded()` +
      `_ensureMemberSeeded()` and run all 3 concurrently via `Future.wait`,
      each still independently idempotent (check-then-set).
   2. **Fixed** — `Image.network`/`Image.memory` calls for item photos
      (manually uploaded, decision #1, so easily several megapixels) had
      no `cacheWidth`/`cacheHeight`, meaning Flutter fully decoded the
      source resolution just to downscale it for display. Added
      device-pixel-ratio-scaled `cacheWidth`/`cacheHeight` to
      `ItemListTile`'s 40x40 row thumbnail and `ShoppableItemSheet`'s
      120x120 add/edit preview (both the picked-photo `Image.memory` and
      the already-uploaded `Image.network` branch).
   3. **Won't fix (documented tradeoff)** — Home and Search watch
      `allItemsProvider` while each list screen watches
      `itemsByListTypeProvider(listType)`; because the bottom nav is a
      `StatefulShellRoute.indexedStack`, every tab you've visited stays
      mounted, so visiting Home (or Search) and any list screen in the
      same session runs two overlapping Firestore listeners over
      intersecting data. This is inherent to preserving tab/scroll state
      across the bottom nav (the explicit tradeoff `IndexedStack` makes),
      and at this app's real scale — two users, dozens of items — the
      extra listener is immaterial. Restructuring Home to derive its
      stats from 5 separate `itemsByListType` streams instead of 1
      `allItems` stream would add real complexity (juggling 5
      `AsyncValue`s instead of 1) for a gain that isn't worth it here, so
      left as-is rather than fixed speculatively.
   Tests: existing `household_repository_test.dart` coverage
   (`ensureSeeded` creates-both-docs and idempotent-second-call) continues
   to pass unchanged against the parallelized implementation, since both
   tests only assert on end state, not call order. No new tests needed for
   the image-decode-size fix — it's a rendering-hint parameter with no
   observable behavior change under `fake_cloud_firestore`/widget tests.
   `flutter analyze` and `flutter test` both pass (71/71).

**Ground rule carried over from the original brief:** after every milestone,
stop and wait for explicit approval before continuing to the next one. Always
explain pros/cons before choosing between implementation options. Produce
production-quality, commented code throughout.

## Next step

Milestone 18 is done — **this was the last milestone in the original
18-milestone plan.** The one deliberate exception is milestone 15
(Notifications/FCM), skipped per your explicit direction pending a real
Firebase project and a decision on the push trigger mechanism (see its
entry above). Everything else in the plan is built, tested, and committed.
No further milestone is queued — awaiting your direction on what's next
(e.g. revisiting milestone 15, setting up a real Firebase project per
decision #6, or a new feature/polish request).
