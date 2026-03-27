import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lupilup_flutter/core/theme/app_theme.dart';
import 'package:lupilup_flutter/core/widgets/app_scaffold.dart';
import 'package:lupilup_flutter/core/widgets/empty_state.dart';
import 'package:lupilup_flutter/core/widgets/section_card.dart';
import 'package:lupilup_flutter/features/scanner/logic/scanner_controller.dart';

class ScannerScreen extends ConsumerWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scannerControllerProvider);

    ref.listen(scannerControllerProvider, (_, next) {
      next.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Scanner failed: $error')),
          );
        },
      );
    });

    return AppScaffold(
      title: 'Scan',
      child: state.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (error, _) => EmptyState(
          title: 'Scanner error',
          body: '$error',
          icon: Icons.error_outline,
        ),
        data: (draft) {
          if (draft == null) {
            return Center(
              child: SectionCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Turn a yarn label into stash data',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Scanner is temporarily running in safe mode while the Flutter migration is getting iOS simulator support. You can still attach a photo draft or jump to manual stash entry.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => ref
                          .read(scannerControllerProvider.notifier)
                          .pickAndScan(ImageSource.camera),
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: const Text('Use camera'),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => ref
                          .read(scannerControllerProvider.notifier)
                          .pickAndScan(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Choose photo draft'),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/stash/add-edit'),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Add manually'),
                    ),
                  ],
                ),
              ),
            );
          }

          final suggested = draft.suggestedItem;
          return ListView(
            children: [
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Suggested stash item',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'OCR is temporarily disabled, so this is a placeholder scan draft. Finish the details manually before saving.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                    ),
                    const SizedBox(height: 14),
                    _ReviewRow(label: 'Brand', value: suggested.brand),
                    _ReviewRow(label: 'Name', value: suggested.name),
                    _ReviewRow(label: 'Color', value: suggested.colorName),
                    _ReviewRow(label: 'Fiber', value: suggested.fiberContent),
                    _ReviewRow(label: 'Lot', value: suggested.lot),
                    _ReviewRow(
                      label: 'Current weight',
                      value: suggested.currentWeightG?.toString(),
                    ),
                    _ReviewRow(
                      label: 'Length m/100g',
                      value: suggested.lengthMPer100g?.toString(),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: () => context.push('/stash/add-edit'),
                      child: const Text('Open manual editor'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () =>
                          ref.read(scannerControllerProvider.notifier).clear(),
                      child: const Text('Start a new scan'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => context.push('/stash/add-edit'),
                      child: const Text('Add manually instead'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Possible duplicates', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    if (draft.duplicates.isEmpty)
                      Text(
                        'Duplicate suggestions are paused while scanner OCR is disabled.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      )
                    else
                      for (final item in draft.duplicates) ...[
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(item.title),
                          subtitle: Text(
                            [
                              item.colorName,
                              if (item.lot != null) 'lot ${item.lot}',
                            ].whereType<String>().join(' · '),
                          ),
                        ),
                        if (item != draft.duplicates.last) const Divider(height: 1),
                      ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recognized text', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    Text(
                      draft.rawText.isEmpty ? 'No text detected.' : draft.rawText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              (value ?? '').trim().isEmpty ? '—' : value!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
