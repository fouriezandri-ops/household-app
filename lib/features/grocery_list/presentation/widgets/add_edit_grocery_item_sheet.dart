import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/entities/item.dart';
import '../../../../core/domain/entities/list_type.dart';
import '../../../../core/providers/firestore_providers.dart';
import '../../../household/presentation/providers/current_member_provider.dart';

/// Modal bottom sheet for adding a new grocery item, or editing [existing]
/// one (preserving its `addedBy`/`dateAdded`/`history`).
Future<void> showAddEditGroceryItemSheet(
  BuildContext context, {
  Item? existing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => AddEditGroceryItemSheet(existing: existing),
  );
}

class AddEditGroceryItemSheet extends ConsumerStatefulWidget {
  const AddEditGroceryItemSheet({super.key, this.existing});

  final Item? existing;

  @override
  ConsumerState<AddEditGroceryItemSheet> createState() =>
      _AddEditGroceryItemSheetState();
}

class _AddEditGroceryItemSheetState
    extends ConsumerState<AddEditGroceryItemSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _titleController = TextEditingController(
    text: widget.existing?.title,
  );
  late final _quantityController = TextEditingController(
    text: widget.existing?.details.quantity?.toString(),
  );
  late final _unitController = TextEditingController(
    text: widget.existing?.details.unit,
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
    _quantityController.dispose();
    _unitController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final repository = ref.read(itemsRepositoryProvider);
      final details = ItemDetails(
        quantity: int.tryParse(_quantityController.text),
        unit: _unitController.text.trim().isEmpty
            ? null
            : _unitController.text.trim(),
      );
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
            listType: ListType.grocery,
            title: _titleController.text.trim(),
            addedBy: addedBy ?? '',
            dateAdded: DateTime.now(),
            category: category,
            notes: notes,
            details: details,
          ),
        );
      } else {
        // A partial update — not a full-document `set()` — so a concurrent
        // change to fields this form doesn't touch (completed, dateCompleted,
        // history) from the other household member isn't silently reverted.
        await repository.updateFields(existing.id, {
          'title': _titleController.text.trim(),
          'category': category,
          'notes': notes,
          'details': details.toFirestore(),
        });
      }

      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not save: $error')));
        setState(() => _isSaving = false);
      }
    }
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
                    ? 'Add grocery item'
                    : 'Edit grocery item',
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
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _unitController,
                      decoration: const InputDecoration(labelText: 'Unit'),
                    ),
                  ),
                ],
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
