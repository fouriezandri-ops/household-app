import 'package:cloud_firestore/cloud_firestore.dart';

/// Generic CRUD + stream base for a Firestore collection of [T]. Concrete
/// repositories (see `lib/core/data/repositories/`) supply the collection
/// path and the (de)serialization, then add whatever queries are specific
/// to that collection on top.
abstract class FirestoreRepository<T> {
  FirestoreRepository({
    required FirebaseFirestore firestore,
    required String collectionPath,
    required T Function(Map<String, dynamic> data, String id) fromFirestore,
    required Map<String, dynamic> Function(T value) toFirestore,
  }) : collection = firestore.collection(collectionPath).withConverter<T>(
         fromFirestore: (snapshot, _) => fromFirestore(snapshot.data()!, snapshot.id),
         toFirestore: (value, _) => toFirestore(value),
       );

  /// Exposed (not private) so subclasses can build queries beyond the
  /// generic ones below, e.g. `collection.where(...)`.
  final CollectionReference<T> collection;

  /// Creates a new document with an auto-generated ID, returning it.
  Future<String> add(T value) async {
    final doc = await collection.add(value);
    return doc.id;
  }

  /// Creates or overwrites the document at [id].
  Future<void> set(String id, T value) => collection.doc(id).set(value);

  /// Patches specific fields without touching the rest of the document.
  Future<void> updateFields(String id, Map<String, Object?> fields) =>
      collection.doc(id).update(fields);

  Future<void> delete(String id) => collection.doc(id).delete();

  Future<T?> getById(String id) async {
    final snapshot = await collection.doc(id).get();
    return snapshot.data();
  }

  Stream<List<T>> watchAll() {
    return collection.snapshots().map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
