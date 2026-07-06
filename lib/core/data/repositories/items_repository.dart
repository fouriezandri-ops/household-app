import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/item.dart';
import '../../domain/entities/list_type.dart';
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

  /// Moves [itemId] to [newListType], optionally patching `details` at the
  /// same time (the move-between-lists feature decides which fields carry
  /// over), and appends a [HistoryEntry] — never overwriting prior history.
  Future<void> moveToList(
    String itemId, {
    required ListType newListType,
    ItemDetails? newDetails,
  }) {
    return collection.doc(itemId).update({
      'listType': newListType.value,
      if (newDetails != null) 'details': newDetails.toFirestore(),
      'history': FieldValue.arrayUnion([
        HistoryEntry(listType: newListType, movedAt: DateTime.now()).toFirestore(),
      ]),
    });
  }
}
