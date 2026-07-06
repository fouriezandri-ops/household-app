import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_app/core/data/repositories/trips_repository.dart';
import 'package:household_app/core/domain/entities/trip.dart';

void main() {
  test('watchAllByStartDate orders trips newest-start-date first', () async {
    final firestore = FakeFirebaseFirestore();
    final repository = TripsRepository(firestore: firestore, householdId: 'test-household');

    await repository.add(
      Trip(
        id: '',
        name: 'Older trip',
        createdBy: 'member-1',
        createdAt: DateTime(2026, 1, 1),
        startDate: DateTime(2026, 3, 1),
      ),
    );
    await repository.add(
      Trip(
        id: '',
        name: 'Newer trip',
        createdBy: 'member-1',
        createdAt: DateTime(2026, 1, 1),
        startDate: DateTime(2027, 1, 1),
      ),
    );

    final trips = await repository.watchAllByStartDate().first;
    expect(trips.map((trip) => trip.name), ['Newer trip', 'Older trip']);
  });
}
