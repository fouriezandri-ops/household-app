import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/household_constants.dart';
import '../../domain/entities/household.dart';
import '../../domain/entities/household_member.dart';

/// The household + its two members span two top-level collections
/// (`households`, `users`), so unlike [ItemsRepository]/[TripsRepository]
/// this doesn't extend the single-collection `FirestoreRepository` base.
class HouseholdRepository {
  HouseholdRepository({required FirebaseFirestore firestore, this.householdId = defaultHouseholdId})
    : _households = firestore.collection('households').withConverter<Household>(
        fromFirestore: (snapshot, _) => Household.fromFirestore(snapshot.data()!, snapshot.id),
        toFirestore: (value, _) => value.toFirestore(),
      ),
      _users = firestore.collection('users').withConverter<HouseholdMember>(
        fromFirestore: (snapshot, _) => HouseholdMember.fromFirestore(snapshot.data()!, snapshot.id),
        toFirestore: (value, _) => value.toFirestore(),
      );

  final String householdId;
  final CollectionReference<Household> _households;
  final CollectionReference<HouseholdMember> _users;

  /// Creates `/households/default` and the two seeded `/users/{uid}` docs
  /// if they don't already exist. Idempotent and safe to call from both
  /// partners' devices on first launch — see household_constants.dart for
  /// why the IDs are fixed rather than generated. The household doc and
  /// each member doc are independent, so their check-then-set operations
  /// run concurrently rather than one after another.
  Future<void> ensureSeeded() async {
    await Future.wait([_ensureHouseholdSeeded(), ...defaultMemberSeeds.map(_ensureMemberSeeded)]);
  }

  Future<void> _ensureHouseholdSeeded() async {
    final householdDoc = _households.doc(householdId);
    if (!(await householdDoc.get()).exists) {
      await householdDoc.set(
        Household(
          id: householdId,
          name: 'Our Household',
          memberUids: defaultMemberSeeds.map((seed) => seed.uid).toList(),
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> _ensureMemberSeeded(({String uid, String displayName, String colorTag}) seed) async {
    final memberDoc = _users.doc(seed.uid);
    if (!(await memberDoc.get()).exists) {
      await memberDoc.set(
        HouseholdMember(uid: seed.uid, displayName: seed.displayName, colorTag: seed.colorTag),
      );
    }
  }

  Stream<Household?> watchHousehold() {
    return _households.doc(householdId).snapshots().map((snapshot) => snapshot.data());
  }

  Stream<List<HouseholdMember>> watchMembers() {
    final memberUids = defaultMemberSeeds.map((seed) => seed.uid).toList();
    return _users
        .where(FieldPath.documentId, whereIn: memberUids)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
