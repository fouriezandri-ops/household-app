import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_app/core/constants/household_constants.dart';
import 'package:household_app/core/data/repositories/household_repository.dart';

void main() {
  test('ensureSeeded creates the household and its two members', () async {
    final repository = HouseholdRepository(firestore: FakeFirebaseFirestore());

    await repository.ensureSeeded();

    final household = await repository.watchHousehold().first;
    expect(household, isNotNull);
    expect(household!.memberUids, [member1Uid, member2Uid]);

    final members = await repository.watchMembers().first;
    expect(members.map((member) => member.uid), containsAll([member1Uid, member2Uid]));
  });

  test('ensureSeeded is idempotent — a renamed member survives a second call', () async {
    final firestore = FakeFirebaseFirestore();
    final repository = HouseholdRepository(firestore: firestore);
    await repository.ensureSeeded();

    // Simulates the (not-yet-built) Settings rename feature having already
    // run — ensureSeeded must not stomp it back to the placeholder name.
    await firestore.collection('users').doc(member1Uid).update({'displayName': 'Renamed'});
    await repository.ensureSeeded();

    final members = await repository.watchMembers().first;
    final renamed = members.firstWhere((member) => member.uid == member1Uid);
    expect(renamed.displayName, 'Renamed');
  });
}
