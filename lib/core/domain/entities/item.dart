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
    this.imageUrl,
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
  final String? imageUrl;
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

  static Item fromFirestore(Map<String, dynamic> data, String id) {
    return Item(
      id: id,
      listType: ListType.fromValue(data['listType'] as String),
      title: data['title'] as String,
      notes: data['notes'] as String?,
      category: data['category'] as String?,
      priority: Priority.fromValue(data['priority'] as String?),
      completed: data['completed'] as bool? ?? false,
      imageUrl: data['imageUrl'] as String?,
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
      'imageUrl': imageUrl,
      'addedBy': addedBy,
      'dateAdded': Timestamp.fromDate(dateAdded),
      'dateCompleted': dateCompleted == null ? null : Timestamp.fromDate(dateCompleted!),
      'details': details.toFirestore(),
      'history': history.map((entry) => entry.toFirestore()).toList(),
    };
  }
}

/// Fields specific to one or more list types — see the comment on each
/// field for which list(s) use it. Carried over (not reset) when an item
/// moves to a list that shares some of these fields, e.g. wishlist ->
/// products-to-buy keeps price/websiteUrl/store.
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

  ItemDetails copyWith({
    int? quantity,
    String? unit,
    String? tripId,
    String? description,
    DateTime? dueDate,
    String? assignedTo,
    String? store,
    String? websiteUrl,
    double? price,
    int? desiredQuantity,
  }) {
    return ItemDetails(
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      tripId: tripId ?? this.tripId,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      assignedTo: assignedTo ?? this.assignedTo,
      store: store ?? this.store,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      price: price ?? this.price,
      desiredQuantity: desiredQuantity ?? this.desiredQuantity,
    );
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
