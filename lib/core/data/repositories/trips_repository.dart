import '../../domain/entities/trip.dart';
import '../firestore_repository.dart';

class TripsRepository extends FirestoreRepository<Trip> {
  TripsRepository({required super.firestore, required String householdId})
    : super(
        collectionPath: 'households/$householdId/trips',
        fromFirestore: Trip.fromFirestore,
        toFirestore: (trip) => trip.toFirestore(),
      );

  /// Most recent trips first, for the packing trip-picker (`/home/packing`).
  Stream<List<Trip>> watchAllByStartDate() {
    return collection
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
