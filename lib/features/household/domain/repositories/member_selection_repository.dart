/// Persists which household member this device belongs to — a local
/// preference, not identity/auth (see CLAUDE.md decision #2: no auth at
/// all, not even a PIN). Chosen once via the "who are you?" screen on
/// first launch.
abstract interface class MemberSelectionRepository {
  /// The uid picked on this device, or null if not picked yet.
  Future<String?> getSelectedUid();

  Future<void> selectMember(String uid);

  Future<void> clearSelection();
}
