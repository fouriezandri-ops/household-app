import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/repositories/member_selection_repository.dart';

class MemberSelectionRepositoryImpl implements MemberSelectionRepository {
  MemberSelectionRepositoryImpl(this._storage);

  final FlutterSecureStorage _storage;

  static const _selectedUidKey = 'selected_member_uid';

  @override
  Future<String?> getSelectedUid() => _storage.read(key: _selectedUidKey);

  @override
  Future<void> selectMember(String uid) => _storage.write(key: _selectedUidKey, value: uid);

  @override
  Future<void> clearSelection() => _storage.delete(key: _selectedUidKey);
}
