import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/entities/item.dart';
import '../../../../core/domain/entities/list_type.dart';
import '../../../../core/providers/firestore_providers.dart';
import '../../../household/presentation/providers/current_member_provider.dart';

/// Modal bottom sheet for adding a packing item to [tripId], or editing
/// [existing] one (preserving its `addedBy`/`dateAdded`/`history`/`tripId`).
Future<void> showAddEditPackingItemSheet(
  BuildContext context, {
  required String tripId,
  Item? existing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) =>
        AddEditPackingItemSheet(tripId: tripId, existing: existing),
  );
}

class AddEditPackingItemSheet extends ConsumerStatefulWidget {
  const AddEditPackingItemSheet({
    super.key,
    required this.tripId,
    this.existing,
  });

  final String tripId;
  final Item? existing;

  @override
  ConsumerState<AddEditPackingItemSheet> createState() =>
      _AddEditPackingItemSheetState();
}

class _AddEditPackingItemSheetState
    extends ConsumerState<AddEditPackingItemSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _titleController = TextEditingController(
    text: widget.existing?.title,
  );
  late final _categoryController = TextEditingController(
    text: widget.existing?.category,
  );
  late final _notesController = TextEditingController(
    text: widget.existing?.notes,
  );
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final repository = ref.read(itemsRepositoryProvider);
    final category = _categoryController.text.trim().isEmpty
        ? null
        : _categoryController.text.trim();
    final notes = _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim();

    final existing = widget.existing;
    if (existing == null) {
      final addedBy = await ref.read(currentMemberControllerProvider.future);
      await repository.add(
        Item(
          id: '',
          listType: ListType.packing,
          title: _titleController.text.trim(),
          addedBy: addedBy ?? '',
          dateAdded: DateTime.now(),
          category: category,
          notes: notes,
          details: ItemDetails(tripId: widget.tripId),
        ),
      );
    } else {
      await repository.set(
        existing.id,
        existing.copyWith(
          title: _titleController.text.trim(),
          category: category,
          notes: notes,
        ),
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.existing == null
                    ? 'Add packing item'
                    : 'Edit packing item',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Item'),
                autofocus: widget.existing == null,
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
