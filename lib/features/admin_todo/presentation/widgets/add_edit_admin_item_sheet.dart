import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/entities/item.dart';
import '../../../../core/domain/entities/list_type.dart';
import '../../../../core/domain/entities/priority.dart';
import '../../../../core/providers/firestore_providers.dart';
import '../../../household/presentation/providers/current_member_provider.dart';

/// Modal bottom sheet for adding a new admin to-do, or editing [existing]
/// one (preserving its `addedBy`/`dateAdded`/`history`).
Future<void> showAddEditAdminItemSheet(BuildContext context, {Item? existing}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => AddEditAdminItemSheet(existing: existing),
  );
}

class AddEditAdminItemSheet extends ConsumerStatefulWidget {
  const AddEditAdminItemSheet({super.key, this.existing});

  final Item? existing;

  @override
  ConsumerState<AddEditAdminItemSheet> createState() =>
      _AddEditAdminItemSheetState();
}

class _AddEditAdminItemSheetState extends ConsumerState<AddEditAdminItemSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _titleController = TextEditingController(
    text: widget.existing?.title,
  );
  late final _descriptionController = TextEditingController(
    text: widget.existing?.details.description,
  );
  late final _categoryController = TextEditingController(
    text: widget.existing?.category,
  );
  late final _notesController = TextEditingController(
    text: widget.existing?.notes,
  );
  late DateTime? _dueDate = widget.existing?.details.dueDate;
  late Priority? _priority = widget.existing?.priority;
  late String? _assignedTo = widget.existing?.details.assignedTo;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final repository = ref.read(itemsRepositoryProvider);
      final category = _categoryController.text.trim().isEmpty
          ? null
          : _categoryController.text.trim();
      final notes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();
      final description = _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim();
      final details = ItemDetails(
        description: description,
        dueDate: _dueDate,
        assignedTo: _assignedTo,
      );

      final existing = widget.existing;
      if (existing == null) {
        final addedBy = await ref.read(currentMemberControllerProvider.future);
        await repository.add(
          Item(
            id: '',
            listType: ListType.admin,
            title: _titleController.text.trim(),
            addedBy: addedBy ?? '',
            dateAdded: DateTime.now(),
            category: category,
            notes: notes,
            priority: _priority,
            details: details,
          ),
        );
      } else {
        await repository.set(
          existing.id,
          Item(
            id: existing.id,
            listType: existing.listType,
            title: _titleController.text.trim(),
            addedBy: existing.addedBy,
            dateAdded: existing.dateAdded,
            category: category,
            notes: notes,
            priority: _priority,
            completed: existing.completed,
            imageUrl: existing.imageUrl,
            dateCompleted: existing.dateCompleted,
            details: details,
            history: existing.history,
          ),
        );
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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(householdMembersProvider);

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
                    ? 'Add admin to-do'
                    : 'Edit admin to-do',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                autofocus: widget.existing == null,
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Due date'),
                      subtitle: Text(
                        _dueDate == null ? 'Not set' : _formatDate(_dueDate!),
                      ),
                      onTap: _pickDueDate,
                    ),
                  ),
                  if (_dueDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _dueDate = null),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('None'),
                    selected: _priority == null,
                    onSelected: (_) => setState(() => _priority = null),
                  ),
                  for (final priority in Priority.values)
                    ChoiceChip(
                      label: Text(priority.name),
                      selected: _priority == priority,
                      onSelected: (_) => setState(() => _priority = priority),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              membersAsync.when(
                data: (members) => DropdownButtonFormField<String?>(
                  initialValue: _assignedTo,
                  decoration: const InputDecoration(labelText: 'Assigned to'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Unassigned'),
                    ),
                    for (final member in members)
                      DropdownMenuItem(
                        value: member.uid,
                        child: Text(member.displayName),
                      ),
                  ],
                  onChanged: (value) => setState(() => _assignedTo = value),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (error, stackTrace) =>
                    Text('Could not load household members: $error'),
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
