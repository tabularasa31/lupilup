import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lupilup_flutter/core/widgets/app_scaffold.dart';
import 'package:lupilup_flutter/core/widgets/section_card.dart';
import 'package:lupilup_flutter/features/stash/data/stash_repository.dart';
import 'package:lupilup_flutter/features/stash/data/yarn_stash_item.dart';
import 'package:lupilup_flutter/features/stash/logic/stash_providers.dart';

class StashEditorScreen extends ConsumerWidget {
  const StashEditorScreen({super.key, this.itemId});

  final String? itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (itemId == null) {
      return const _StashEditorForm();
    }

    final stash = ref.watch(stashStreamProvider);
    final liveItem = stash.valueOrNull
        ?.where((item) => item.id == itemId)
        .cast<YarnStashItem?>()
        .firstOrNull;

    if (liveItem != null) {
      return _StashEditorForm(initialItem: liveItem);
    }

    final item = ref.watch(stashItemProvider(itemId!));
    return item.when(
      data: (value) => _StashEditorForm(initialItem: value),
      loading: () => const AppScaffold(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => AppScaffold(
        child: Center(child: Text('Could not load yarn: $error')),
      ),
    );
  }
}

class _StashEditorForm extends ConsumerStatefulWidget {
  const _StashEditorForm({this.initialItem});

  final YarnStashItem? initialItem;

  @override
  ConsumerState<_StashEditorForm> createState() => _StashEditorFormState();
}

class _StashEditorFormState extends ConsumerState<_StashEditorForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _brand;
  late final TextEditingController _name;
  late final TextEditingController _colorName;
  late final TextEditingController _fiberContent;
  late final TextEditingController _length;
  late final TextEditingController _currentWeight;
  late final TextEditingController _originalWeight;
  late final TextEditingController _lot;
  late YarnType _type;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    _brand = TextEditingController(text: item?.brand ?? '');
    _name = TextEditingController(text: item?.name ?? '');
    _colorName = TextEditingController(text: item?.colorName ?? '');
    _fiberContent = TextEditingController(text: item?.fiberContent ?? '');
    _length = TextEditingController(text: item?.lengthMPer100g?.toString() ?? '');
    _currentWeight = TextEditingController(text: item?.currentWeightG?.toString() ?? '');
    _originalWeight = TextEditingController(text: item?.originalWeightG?.toString() ?? '');
    _lot = TextEditingController(text: item?.lot ?? '');
    _type = item?.type ?? YarnType.skein;
  }

  @override
  void dispose() {
    _brand.dispose();
    _name.dispose();
    _colorName.dispose();
    _fiberContent.dispose();
    _length.dispose();
    _currentWeight.dispose();
    _originalWeight.dispose();
    _lot.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _StashEditorForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    final previous = oldWidget.initialItem;
    final next = widget.initialItem;
    if (previous == null || next == null) return;
    if (identical(previous, next)) return;
    if (previous.id != next.id ||
        previous.type != next.type ||
        previous.brand != next.brand ||
        previous.name != next.name ||
        previous.colorName != next.colorName ||
        previous.fiberContent != next.fiberContent ||
        previous.lengthMPer100g != next.lengthMPer100g ||
        previous.currentWeightG != next.currentWeightG ||
        previous.originalWeightG != next.originalWeightG ||
        previous.lot != next.lot) {
      _syncFromItem(next);
    }
  }

  void _syncFromItem(YarnStashItem item) {
    _brand.text = item.brand ?? '';
    _name.text = item.name ?? '';
    _colorName.text = item.colorName ?? '';
    _fiberContent.text = item.fiberContent ?? '';
    _length.text = item.lengthMPer100g?.toString() ?? '';
    _currentWeight.text = item.currentWeightG?.toString() ?? '';
    _originalWeight.text = item.originalWeightG?.toString() ?? '';
    _lot.text = item.lot ?? '';
    _type = item.type;
    setState(() {});
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final repository = ref.read(stashRepositoryProvider);
      final initial = widget.initialItem;
      if (initial == null) {
        await repository.createManualItem(
          type: _type,
          brand: _brand.text,
          name: _name.text,
          colorName: _colorName.text,
          fiberContent: _fiberContent.text,
          lengthMPer100g: int.tryParse(_length.text.trim()),
          currentWeightG: double.tryParse(_currentWeight.text.trim()),
          originalWeightG: double.tryParse(_originalWeight.text.trim()),
          lot: _lot.text,
        );
      } else {
        await repository.save(
          initial.copyWith(
            type: _type,
            brand: _brand.text.trim(),
            name: _name.text.trim(),
            colorName: _colorName.text.trim(),
            fiberContent: _fiberContent.text.trim(),
            lengthMPer100g: int.tryParse(_length.text.trim()),
            currentWeightG: double.tryParse(_currentWeight.text.trim()),
            originalWeightG: double.tryParse(_originalWeight.text.trim()),
            lot: _lot.text.trim(),
          ),
        );
      }
      ref.invalidate(stashStreamProvider);
      if (initial != null) {
        ref.invalidate(stashItemProvider(initial.id));
      }
      if (!mounted) return;
      context.pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save yarn: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.initialItem == null ? 'Add yarn' : 'Edit yarn',
      child: ListView(
        children: [
          SectionCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<YarnType>(
                    initialValue: _type,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: YarnType.values
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _type = value ?? YarnType.skein),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _brand,
                    decoration: const InputDecoration(labelText: 'Brand'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Yarn name'),
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty && _brand.text.trim().isEmpty) {
                        return 'Add at least a brand or a yarn name.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _colorName,
                    decoration: const InputDecoration(labelText: 'Color'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _fiberContent,
                    decoration: const InputDecoration(labelText: 'Fiber content'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _length,
                    decoration: const InputDecoration(labelText: 'Length (m / 100g)'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _currentWeight,
                    decoration: const InputDecoration(labelText: 'Current weight (g)'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _originalWeight,
                    decoration: const InputDecoration(labelText: 'Original weight (g)'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _lot,
                    decoration: const InputDecoration(labelText: 'Dye lot'),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save yarn'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
