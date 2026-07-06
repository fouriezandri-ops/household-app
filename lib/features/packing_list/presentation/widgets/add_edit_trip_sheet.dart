import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/entities/trip.dart';
import '../../../../core/providers/firestore_providers.dart';
import '../../../household/presentation/providers/current_member_provider.dart';

/// Modal bottom sheet for creating a new trip, or editing [existing] one
/// (preserving its `createdBy`/`createdAt`).
Future<void> showAddEditTripSheet(BuildContext context, {Trip? existing}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => AddEditTripSheet(existing: existing),
  );
}

class AddEditTripSheet extends ConsumerStatefulWidget {
  const AddEditTripSheet({super.key, this.existing});

  final Trip? existing;

  @override
  ConsumerState<AddEditTripSheet> createState() => _AddEditTripSheetState();
}

class _AddEditTripSheetState extends ConsumerState<AddEditTripSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.existing?.name,
  );
  late final _destinationController = TextEditingController(
    text: widget.existing?.destination,
  );
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _startDate = widget.existing?.startDate;
    _endDate = widget.existing?.endDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStartDate}) async {
    final initial = (isStartDate ? _startDate : _endDate) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() => isStartDate ? _startDate = picked : _endDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final repository = ref.read(tripsRepositoryProvider);
    final destination = _destinationController.text.trim().isEmpty
        ? null
        : _destinationController.text.trim();

    final existing = widget.existing;
    if (existing == null) {
      final createdBy = await ref.read(currentMemberControllerProvider.future);
      await repository.add(
        Trip(
          id: '',
          name: _nameController.text.trim(),
          destination: destination,
          startDate: _startDate,
          endDate: _endDate,
          createdBy: createdBy ?? '',
          createdAt: DateTime.now(),
        ),
      );
    } else {
      await repository.set(
        existing.id,
        Trip(
          id: existing.id,
          name: _nameController.text.trim(),
          destination: destination,
          startDate: _startDate,
          endDate: _endDate,
          createdBy: existing.createdBy,
          createdAt: existing.createdAt,
        ),
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not set';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
                widget.existing == null ? 'New trip' : 'Edit trip',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Trip name'),
                autofocus: widget.existing == null,
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _destinationController,
                decoration: const InputDecoration(labelText: 'Destination'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Start date'),
                      subtitle: Text(_formatDate(_startDate)),
                      onTap: () => _pickDate(isStartDate: true),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('End date'),
                      subtitle: Text(_formatDate(_endDate)),
                      onTap: () => _pickDate(isStartDate: false),
                    ),
                  ),
                ],
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
