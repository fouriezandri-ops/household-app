import 'package:cloud_firestore/cloud_firestore.dart';

/// `/households/{householdId}` — there is exactly one of these for this
/// app (see `lib/core/constants/household_constants.dart` for why the ID
/// is a fixed constant rather than something created through auth).
class Household {
  const Household({
    required this.id,
    required this.name,
    required this.memberUids,
    required this.createdAt,
  });

  final String id;
  final String name;
  final List<String> memberUids;
  final DateTime createdAt;

  static Household fromFirestore(Map<String, dynamic> data, String id) {
    return Household(
      id: id,
      name: data['name'] as String,
      memberUids: List<String>.from(data['memberUids'] as List<dynamic>),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'memberUids': memberUids,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
