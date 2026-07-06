import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/current_member_provider.dart';

/// Shown once, after the PIN gate, on a device that hasn't picked a
/// household member yet. Renaming the seeded placeholder names/colors is a
/// Settings feature for a later milestone.
class PickMemberScreen extends ConsumerWidget {
  const PickMemberScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(householdMembersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Who are you?')),
      body: membersAsync.when(
        data: (members) => ListView(
          padding: const EdgeInsets.all(16),
          children: members
              .map(
                (member) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(
                        int.parse(member.colorTag.replaceFirst('#', '0xFF')),
                      ),
                    ),
                    title: Text(member.displayName),
                    onTap: () =>
                        ref.read(currentMemberControllerProvider.notifier).select(member.uid),
                  ),
                ),
              )
              .toList(),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Something went wrong: $error')),
      ),
    );
  }
}
