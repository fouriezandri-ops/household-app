import 'package:flutter/material.dart';

/// Shared error view for the `error` branch of `AsyncValue.when`/`.maybeWhen`
/// across list/detail screens. Uses `SelectableText` rather than a plain
/// `Text` — Firestore errors (e.g. a missing-index failure) include a
/// "create this index" URL in the message, and a plain `Text` widget can't
/// be long-pressed to copy on a phone with no other way to reach that link.
class AsyncErrorView extends StatelessWidget {
  const AsyncErrorView({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SelectableText('Something went wrong: $error', textAlign: TextAlign.center),
      ),
    );
  }
}
