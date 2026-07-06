import 'package:cloud_firestore/cloud_firestore.dart';

/// A packing trip — `/households/{householdId}/trips/{tripId}`. Packing
/// list items reference one via `ItemDetails.tripId`.
class Trip {
  const Trip({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.createdAt,
    this.destination,
    this.startDate,
    this.endDate,
  });

  final String id;
  final String name;
  final String? destination;
  final DateTime? startDate;
  final DateTime? endDate;
  final String createdBy;
  final DateTime createdAt;

  static Trip fromFirestore(Map<String, dynamic> data, String id) {
    return Trip(
      id: id,
      name: data['name'] as String,
      destination: data['destination'] as String?,
      startDate: (data['startDate'] as Timestamp?)?.toDate(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      createdBy: data['createdBy'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'destination': destination,
      'startDate': startDate == null ? null : Timestamp.fromDate(startDate!),
      'endDate': endDate == null ? null : Timestamp.fromDate(endDate!),
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
