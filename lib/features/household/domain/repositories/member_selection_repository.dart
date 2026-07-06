/// Persists which household member this device belongs to — a local
/// preference, not identity/auth (see CLAUDE.md decision #2: PIN only, no
/// Firebase Auth). Chosen once via the "who are you?" screen on first
/// launch after the PIN gate.
abstract interface class MemberSelectionRepository {
  /// The uid picked on this device, or null if not picked yet.
  Future<String?> getSelectedUid();

  Future<void> selectMember(String uid);

  Future<void> clearSelection();
}
