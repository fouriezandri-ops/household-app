import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/item.dart';
import '../../domain/entities/list_type.dart';
import '../../domain/entities/priority.dart';
import '../firestore_repository.dart';

/// All five lists live in one `/households/{householdId}/items` collection,
/// discriminated by `listType` — see CLAUDE.md's schema section for why.
class ItemsRepository extends FirestoreRepository<Item> {
  ItemsRepository({required super.firestore, required String householdId})
    : super(
        collectionPath: 'households/$householdId/items',
        fromFirestore: Item.fromFirestore,
        toFirestore: (item) => item.toFirestore(),
      );

  /// Items on a single list, newest first — the shape every list screen
  /// (grocery, packing, ...) streams from.
  Stream<List<Item>> watchByListType(ListType listType) {
    return collection
        .where('listType', isEqualTo: listType.value)
        .orderBy('dateAdded', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Packing items for a single trip, newest first. `details.tripId` is
  /// only ever set on packing-list items, so filtering on it alone would
  /// be enough, but including `listType` keeps the query's intent explicit
  /// and matches the composite index in firestore.indexes.json.
  Stream<List<Item>> watchByTripId(String tripId) {
    return collection
        .where('listType', isEqualTo: ListType.packing.value)
        .where('details.tripId', isEqualTo: tripId)
        .orderBy('dateAdded', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Moves [itemId] to [newListType], patching `details` and `priority` at
  /// the same time (the move-between-lists feature decides — via
  /// [Item.filterForListType]/[Item.priorityForListType] — which fields
  /// carry over and which get cleared), and appends a [HistoryEntry] —
  /// never overwriting prior history.
  ///
  /// [newPriority] is always written (including `null`, to clear it) rather
  /// than only-if-non-null, since every move must explicitly decide whether
  /// priority still applies — leaving it unspecified is how a stale
  /// priority ends up stuck on a list that never shows it.
  Future<void> moveToList(
    String itemId, {
    required ListType newListType,
    ItemDetails? newDetails,
    Priority? newPriority,
  }) {
    return collection.doc(itemId).update({
      'listType': newListType.value,
      'priority': newPriority?.name,
      if (newDetails != null) 'details': newDetails.toFirestore(),
      'history': FieldValue.arrayUnion([
        HistoryEntry(listType: newListType, movedAt: DateTime.now()).toFirestore(),
      ]),
    });
  }
}
