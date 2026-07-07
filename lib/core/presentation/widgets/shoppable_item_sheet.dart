import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../features/household/presentation/providers/current_member_provider.dart';
import '../../domain/entities/item.dart';
import '../../domain/entities/list_type.dart';
import '../../providers/firestore_providers.dart';

/// Shared add/edit sheet for the two lists that track a shoppable thing —
/// Products to Buy and Wishlist. They differ only in [listType] and
/// whether a desired quantity makes sense (Products to Buy only); every
/// other field (store, website, price, category, notes) is identical,
/// which matters beyond just not repeating the form: it's what lets
/// move-between-lists (milestone 12) carry a whole item over with no
/// field translation needed.
Future<void> showAddEditShoppableItemSheet(
  BuildContext context, {
  required ListType listType,
  required String itemTypeLabel,
  required String fieldLabel,
  bool showDesiredQuantity = true,
  Item? existing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => ShoppableItemSheet(
      listType: listType,
      itemTypeLabel: itemTypeLabel,
      fieldLabel: fieldLabel,
      showDesiredQuantity: showDesiredQuantity,
      existing: existing,
    ),
  );
}

class ShoppableItemSheet extends ConsumerStatefulWidget {
  const ShoppableItemSheet({
    super.key,
    required this.listType,
    required this.itemTypeLabel,
    required this.fieldLabel,
    this.showDesiredQuantity = true,
    this.existing,
  });

  final ListType listType;
  final String itemTypeLabel;
  final String fieldLabel;
  final bool showDesiredQuantity;
  final Item? existing;

  @override
  ConsumerState<ShoppableItemSheet> createState() => _ShoppableItemSheetState();
}

class _ShoppableItemSheetState extends ConsumerState<ShoppableItemSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _titleController = TextEditingController(text: widget.existing?.title);
  late final _storeController = TextEditingController(text: widget.existing?.details.store);
  late final _websiteUrlController = TextEditingController(
    text: widget.existing?.details.websiteUrl,
  );
  late final _priceController = TextEditingController(
    text: widget.existing?.details.price?.toString(),
  );
  late final _desiredQuantityController = TextEditingController(
    text: widget.existing?.details.desiredQuantity?.toString(),
  );
  late final _categoryController = TextEditingController(text: widget.existing?.category);
  late final _notesController = TextEditingController(text: widget.existing?.notes);

  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _storeController.dispose();
    _websiteUrlController.dispose();
    _priceController.dispose();
    _desiredQuantityController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _openWebsite() async {
    final uri = Uri.tryParse(_websiteUrlController.text.trim());
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final repository = ref.read(itemsRepositoryProvider);
      final existing = widget.existing;
      final id = existing?.id ?? repository.collection.doc().id;

      final store = _storeController.text.trim().isEmpty ? null : _storeController.text.trim();
      final websiteUrl = _websiteUrlController.text.trim().isEmpty
          ? null
          : _websiteUrlController.text.trim();
      final category = _categoryController.text.trim().isEmpty
          ? null
          : _categoryController.text.trim();
      final notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();
      final details = ItemDetails(
        store: store,
        websiteUrl: websiteUrl,
        price: double.tryParse(_priceController.text),
        desiredQuantity: widget.showDesiredQuantity
            ? int.tryParse(_desiredQuantityController.text)
            : null,
      );

      if (existing == null) {
        final addedBy = await ref.read(currentMemberControllerProvider.future);
        await repository.set(
          id,
          Item(
            id: id,
            listType: widget.listType,
            title: _titleController.text.trim(),
            addedBy: addedBy ?? '',
            dateAdded: DateTime.now(),
            category: category,
            notes: notes,
            details: details,
          ),
        );
      } else {
        // A partial update — see add_edit_grocery_item_sheet.dart for why
        // this isn't a full-document `set()`.
        await repository.updateFields(id, {
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
                    ? 'Add ${widget.itemTypeLabel}'
                    : 'Edit ${widget.itemTypeLabel}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: widget.fieldLabel),
                autofocus: widget.existing == null,
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _storeController,
                decoration: const InputDecoration(labelText: 'Store'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _websiteUrlController,
                decoration: InputDecoration(
                  labelText: 'Website URL',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.open_in_new),
                    onPressed: _openWebsite,
                  ),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Price', prefixText: 'R '),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return null;
                        return double.tryParse(value.trim()) == null ? 'Enter a valid number' : null;
                      },
                    ),
                  ),
                  if (widget.showDesiredQuantity) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _desiredQuantityController,
                        decoration: const InputDecoration(labelText: 'Quantity wanted'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
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
