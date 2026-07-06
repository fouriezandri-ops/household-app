import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod/riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants/household_constants.dart';
import '../data/repositories/household_repository.dart';
import '../data/repositories/items_repository.dart';
import '../data/repositories/trips_repository.dart';
import '../domain/entities/item.dart';

part 'firestore_providers.g.dart';

/// `FirebaseFirestore.instance` is already pointed at the emulator (or, in
/// release, real Cloud Firestore) by the time this is first read — see the
/// bootstrap in `main.dart`.
@Riverpod(keepAlive: true)
FirebaseFirestore firebaseFirestore(Ref ref) => FirebaseFirestore.instance;

@Riverpod(keepAlive: true)
ItemsRepository itemsRepository(Ref ref) {
  return ItemsRepository(
    firestore: ref.watch(firebaseFirestoreProvider),
    householdId: defaultHouseholdId,
  );
}

@Riverpod(keepAlive: true)
TripsRepository tripsRepository(Ref ref) {
  return TripsRepository(
    firestore: ref.watch(firebaseFirestoreProvider),
    householdId: defaultHouseholdId,
  );
}

@Riverpod(keepAlive: true)
HouseholdRepository householdRepository(Ref ref) {
  return HouseholdRepository(firestore: ref.watch(firebaseFirestoreProvider));
}

/// A single item by ID, for deep links into a specific item (e.g. the
/// reserved `/home/admin/:itemId` route, ahead of FCM — milestone 15).
@riverpod
Stream<Item?> itemById(Ref ref, String itemId) {
  return ref.watch(itemsRepositoryProvider).watchById(itemId);
}

/// Every item across all five lists — used by Search (not scoped to a
/// single `listType` by design) and by Home's per-list stats cards.
@riverpod
Stream<List<Item>> allItems(Ref ref) {
  return ref.watch(itemsRepositoryProvider).watchAll();
}
