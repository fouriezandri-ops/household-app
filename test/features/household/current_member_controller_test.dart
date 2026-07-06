import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_app/features/household/presentation/providers/current_member_provider.dart';

import 'fake_member_selection_repository.dart';

void main() {
  test('starts unpicked, then persists the selected member', () async {
    final container = ProviderContainer(
      overrides: [
        memberSelectionRepositoryProvider.overrideWithValue(FakeMemberSelectionRepository()),
      ],
    );
    addTearDown(container.dispose);

    expect(await container.read(currentMemberControllerProvider.future), isNull);

    await container.read(currentMemberControllerProvider.notifier).select('member-1');
    expect(container.read(currentMemberControllerProvider).value, 'member-1');
  });
}
