import 'package:household_app/features/household/domain/repositories/member_selection_repository.dart';

class FakeMemberSelectionRepository implements MemberSelectionRepository {
  String? _selectedUid;

  @override
  Future<String?> getSelectedUid() async => _selectedUid;

  @override
  Future<void> selectMember(String uid) async => _selectedUid = uid;

  @override
  Future<void> clearSelection() async => _selectedUid = null;
}
