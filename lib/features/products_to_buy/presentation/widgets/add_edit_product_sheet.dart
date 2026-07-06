import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/domain/entities/item.dart';
import '../../../../core/domain/entities/list_type.dart';
import '../../../../core/providers/firestore_providers.dart';
import '../../../../core/providers/storage_providers.dart';
import '../../../household/presentation/providers/current_member_provider.dart';

/// Modal bottom sheet for adding a product to buy, or editing [existing]
/// one (preserving its `addedBy`/`dateAdded`/`history`).
Future<void> showAddEditProductSheet(BuildContext context, {Item? existing}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => AddEditProductSheet(existing: existing),
  );
}

class AddEditProductSheet extends ConsumerStatefulWidget {
  const AddEditProductSheet({super.key, this.existing});

  final Item? existing;

  @override
  ConsumerState<AddEditProductSheet> createState() =>
      _AddEditProductSheetState();
}

class _AddEditProductSheetState extends ConsumerState<AddEditProductSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _titleController = TextEditingController(
    text: widget.existing?.title,
  );
  late final _storeController = TextEditingController(
    text: widget.existing?.details.store,
  );
  late final _websiteUrlController = TextEditingController(
    text: widget.existing?.details.websiteUrl,
  );
  late final _priceController = TextEditingController(
    text: widget.existing?.details.price?.toString(),
  );
  late final _desiredQuantityController = TextEditingController(
    text: widget.existing?.details.desiredQuantity?.toString(),
  );
  late final _categoryController = TextEditingController(
    text: widget.existing?.category,
  );
  late final _notesController = TextEditingController(
    text: widget.existing?.notes,
  );

  String? _existingImageUrl;
  Uint8List? _pickedImageBytes;
  bool _removeExistingImage = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _existingImageUrl = widget.existing?.imageUrl;
  }

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

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _pickedImageBytes = bytes;
      _removeExistingImage = false;
    });
  }

  Future<void> _showImageSourcePicker() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source != null) await _pickImage(source);
  }

  void _removeImage() {
    setState(() {
      _pickedImageBytes = null;
      _removeExistingImage = true;
    });
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

      // Only touches Firebase Storage if a photo was actually added/removed
      // — most saves don't, and the provider shouldn't be instantiated for
      // them.
      var imageUrl = _existingImageUrl;
      if (_removeExistingImage && imageUrl != null) {
        await ref.read(imageUploadServiceProvider).deleteItemImage(id);
        imageUrl = null;
      }
      if (_pickedImageBytes != null) {
        imageUrl = await ref
            .read(imageUploadServiceProvider)
            .uploadItemImage(id, _pickedImageBytes!);
      }

      final store = _storeController.text.trim().isEmpty
          ? null
          : _storeController.text.trim();
      final websiteUrl = _websiteUrlController.text.trim().isEmpty
          ? null
          : _websiteUrlController.text.trim();
      final category = _categoryController.text.trim().isEmpty
          ? null
          : _categoryController.text.trim();
      final notes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();
      final details = ItemDetails(
        store: store,
        websiteUrl: websiteUrl,
        price: double.tryParse(_priceController.text),
        desiredQuantity: int.tryParse(_desiredQuantityController.text),
      );

      if (existing == null) {
        final addedBy = await ref.read(currentMemberControllerProvider.future);
        await repository.set(
          id,
          Item(
            id: id,
            listType: ListType.productsToBuy,
            title: _titleController.text.trim(),
            addedBy: addedBy ?? '',
            dateAdded: DateTime.now(),
            category: category,
            notes: notes,
            imageUrl: imageUrl,
            details: details,
          ),
        );
      } else {
        await repository.set(
          id,
          Item(
            id: id,
            listType: existing.listType,
            title: _titleController.text.trim(),
            addedBy: existing.addedBy,
            dateAdded: existing.dateAdded,
            category: category,
            notes: notes,
            priority: existing.priority,
            completed: existing.completed,
            imageUrl: imageUrl,
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

  @override
  Widget build(BuildContext context) {
    final hasImage =
        _pickedImageBytes != null ||
        (_existingImageUrl != null && !_removeExistingImage);

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
                widget.existing == null ? 'Add product to buy' : 'Edit product',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Center(
                child: Stack(
                  children: [
                    _ImagePreview(
                      bytes: _pickedImageBytes,
                      existingUrl: _removeExistingImage
                          ? null
                          : _existingImageUrl,
                      onTap: _showImageSourcePicker,
                    ),
                    if (hasImage)
                      Positioned(
                        top: -8,
                        right: -8,
                        child: IconButton(
                          icon: const Icon(Icons.cancel),
                          onPressed: _removeImage,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Product'),
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
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _desiredQuantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity wanted',
                      ),
                      keyboardType: TextInputType.number,
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

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({
    required this.bytes,
    required this.existingUrl,
    required this.onTap,
  });

  final Uint8List? bytes;
  final String? existingUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (bytes != null) {
      content = Image.memory(
        bytes!,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    } else if (existingUrl != null) {
      content = Image.network(
        existingUrl!,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image_outlined, size: 48),
      );
    } else {
      content = const Icon(Icons.add_a_photo_outlined, size: 48);
    }

    return InkWell(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 120,
          height: 120,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: content,
        ),
      ),
    );
  }
}
