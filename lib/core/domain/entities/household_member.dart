/// `/users/{uid}` — one of the (exactly two) people sharing this household.
class HouseholdMember {
  const HouseholdMember({
    required this.uid,
    required this.displayName,
    required this.colorTag,
    this.fcmToken,
  });

  final String uid;
  final String displayName;
  final String colorTag;
  final String? fcmToken;

  static HouseholdMember fromFirestore(Map<String, dynamic> data, String id) {
    return HouseholdMember(
      uid: id,
      displayName: data['displayName'] as String,
      colorTag: data['colorTag'] as String,
      fcmToken: data['fcmToken'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'displayName': displayName, 'colorTag': colorTag, 'fcmToken': fcmToken};
  }
}
