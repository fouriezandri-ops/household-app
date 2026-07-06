import 'package:cloud_firestore/cloud_firestore.dart';

import 'list_type.dart';
import 'priority.dart';

/// A single row in a list. All five lists (grocery, packing, admin,
/// products-to-buy, wishlist) share this shape — [listType] is what puts it
/// on a given list, and [details] holds the fields specific to that list.
/// Moving an item between lists is just changing [listType] (see
/// [ItemsRepository.moveToList]); [history] records every move so nothing
/// is lost.
class Item {
  const Item({
    required this.id,
    required this.listType,
    required this.title,
    required this.addedBy,
    required this.dateAdded,
    this.notes,
    this.category,
    this.priority,
    this.completed = false,
    this.dateCompleted,
    this.details = const ItemDetails(),
    this.history = const [],
  });

  final String id;
  final ListType listType;
  final String title;
  final String? notes;
  final String? category;
  final Priority? priority;
  final bool completed;
  final String addedBy;
  final DateTime dateAdded;
  final DateTime? dateCompleted;
  final ItemDetails details;
  final List<HistoryEntry> history;

  // Deliberately no `copyWith`: a hand-written one that follows the usual
  // `field: field ?? this.field` pattern can't ever clear a nullable field
  // back to null (edit screens construct a fresh `Item(...)` instead, with
  // every field explicit — see the add/edit sheets for grocery/packing/
  // admin/products for the pattern).

  /// `priority` only has UI meaning on the Admin list (only its add/edit
  /// sheet sets or displays it) even though the field lives at the top
  /// level rather than in [ItemDetails] — like
  /// [ItemDetails.filterForListType], this is applied on every move so a
  /// priority set on an Admin task doesn't linger, unseen and unclearable,
  /// on a list that never shows it.
  Priority? priorityForListType(ListType listType) =>
      listType == ListType.admin ? priority : null;

  static Item fromFirestore(Map<String, dynamic> data, String id) {
    return Item(
      id: id,
      listType: ListType.fromValue(data['listType'] as String),
      title: data['title'] as String,
      notes: data['notes'] as String?,
      category: data['category'] as String?,
      priority: Priority.fromValue(data['priority'] as String?),
      completed: data['completed'] as bool? ?? false,
      addedBy: data['addedBy'] as String,
      dateAdded: (data['dateAdded'] as Timestamp).toDate(),
      dateCompleted: (data['dateCompleted'] as Timestamp?)?.toDate(),
      details: ItemDetails.fromFirestore(
        data['details'] as Map<String, dynamic>? ?? const {},
      ),
      history: (data['history'] as List<dynamic>? ?? const [])
          .map((entry) => HistoryEntry.fromFirestore(entry as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'listType': listType.value,
      'title': title,
      'notes': notes,
      'category': category,
      'priority': priority?.name,
      'completed': completed,
      'addedBy': addedBy,
      'dateAdded': Timestamp.fromDate(dateAdded),
      'dateCompleted': dateCompleted == null ? null : Timestamp.fromDate(dateCompleted!),
      'details': details.toFirestore(),
      'history': history.map((entry) => entry.toFirestore()).toList(),
    };
  }
}

/// Fields specific to one or more list types — see the comment on each
/// field for which list(s) use it. [filterForListType] keeps whichever of
/// these apply to a destination list and drops the rest, e.g. wishlist ->
/// products-to-buy keeps price/websiteUrl/store but adds no desiredQuantity.
class ItemDetails {
  const ItemDetails({
    this.quantity,
    this.unit,
    this.tripId,
    this.description,
    this.dueDate,
    this.assignedTo,
    this.store,
    this.websiteUrl,
    this.price,
    this.desiredQuantity,
  });

  final int? quantity; // grocery
  final String? unit; // grocery
  final String? tripId; // packing -> /trips/{tripId}
  final String? description; // admin
  final DateTime? dueDate; // admin
  final String? assignedTo; // admin (uid)
  final String? store; // products_to_buy / wishlist
  final String? websiteUrl; // products_to_buy / wishlist
  final double? price; // products_to_buy / wishlist
  final int? desiredQuantity; // products_to_buy

  // No `copyWith` here either — see the note on `Item` above; unused, and
  // the same nullable-field footgun. `filterForListType` below builds a
  // fresh `ItemDetails` for exactly the same reason.

  /// Keeps only the fields relevant to [listType], dropping the rest —
  /// used when moving an item to a different list (see
  /// `ItemsRepository.moveToList` and `MoveItemSheet`), so e.g. a trip's
  /// `tripId` doesn't linger on an item after it's moved out of Packing.
  ItemDetails filterForListType(ListType listType) {
    return switch (listType) {
      ListType.grocery => ItemDetails(quantity: quantity, unit: unit),
      ListType.packing => ItemDetails(tripId: tripId),
      ListType.admin => ItemDetails(
        description: description,
        dueDate: dueDate,
        assignedTo: assignedTo,
      ),
      ListType.productsToBuy => ItemDetails(
        store: store,
        websiteUrl: websiteUrl,
        price: price,
        desiredQuantity: desiredQuantity,
      ),
      ListType.wishlist => ItemDetails(store: store, websiteUrl: websiteUrl, price: price),
    };
  }

  static ItemDetails fromFirestore(Map<String, dynamic> data) {
    return ItemDetails(
      quantity: (data['quantity'] as num?)?.toInt(),
      unit: data['unit'] as String?,
      tripId: data['tripId'] as String?,
      description: data['description'] as String?,
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      assignedTo: data['assignedTo'] as String?,
      store: data['store'] as String?,
      websiteUrl: data['websiteUrl'] as String?,
      price: (data['price'] as num?)?.toDouble(),
      desiredQuantity: (data['desiredQuantity'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'quantity': quantity,
      'unit': unit,
      'tripId': tripId,
      'description': description,
      'dueDate': dueDate == null ? null : Timestamp.fromDate(dueDate!),
      'assignedTo': assignedTo,
      'store': store,
      'websiteUrl': websiteUrl,
      'price': price,
      'desiredQuantity': desiredQuantity,
    };
  }
}

/// One entry in an item's move history — appended, never overwritten.
class HistoryEntry {
  const HistoryEntry({required this.listType, required this.movedAt});

  final ListType listType;
  final DateTime movedAt;

  static HistoryEntry fromFirestore(Map<String, dynamic> data) {
    return HistoryEntry(
      listType: ListType.fromValue(data['listType'] as String),
      movedAt: (data['movedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'listType': listType.value, 'movedAt': Timestamp.fromDate(movedAt)};
  }
}
