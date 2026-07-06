import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod/riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/entities/household_member.dart';
import '../../../../core/providers/firestore_providers.dart';
import '../../data/repositories/member_selection_repository_impl.dart';
import '../../domain/repositories/member_selection_repository.dart';

part 'current_member_provider.g.dart';

@riverpod
MemberSelectionRepository memberSelectionRepository(Ref ref) {
  return MemberSelectionRepositoryImpl(const FlutterSecureStorage());
}

/// The two household members, seeding `/households/default` and their
/// `/users/{uid}` docs on first read if they don't exist yet (see
/// [HouseholdRepository.ensureSeeded]).
@riverpod
Stream<List<HouseholdMember>> householdMembers(Ref ref) async* {
  final householdRepository = ref.watch(householdRepositoryProvider);
  await householdRepository.ensureSeeded();
  yield* householdRepository.watchMembers();
}

/// Which household member this device belongs to — a local preference set
/// once via [PickMemberScreen], not identity/auth.
@riverpod
class CurrentMemberController extends _$CurrentMemberController {
  @override
  Future<String?> build() async {
    final repository = ref.watch(memberSelectionRepositoryProvider);
    return repository.getSelectedUid();
  }

  Future<void> select(String uid) async {
    final repository = ref.read(memberSelectionRepositoryProvider);
    await repository.selectMember(uid);
    state = AsyncData(uid);
  }
}
