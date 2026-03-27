import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lupilup_flutter/core/theme/app_theme.dart';
import 'package:lupilup_flutter/core/widgets/app_scaffold.dart';
import 'package:lupilup_flutter/core/widgets/section_card.dart';
import 'package:lupilup_flutter/features/onboarding/logic/ravelry_onboarding_controller.dart';

class RavelryOnboardingScreen extends ConsumerWidget {
  const RavelryOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ravelryOnboardingControllerProvider);

    ref.listen(ravelryOnboardingControllerProvider, (previous, next) {
      final didCompleteRequest = previous?.isLoading ?? false;
      if (!didCompleteRequest) return;

      next.whenOrNull(
        data: (_) => context.go('/stash'),
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not complete Ravelry import: $error')),
          );
        },
      );
    });

    final isLoading = state.isLoading;

    return AppScaffold(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SectionCard(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2ECE6),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'ravelry',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Import your stash',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  'Connect Ravelry and bring your yarn stash in seconds. The import is read-only and keeps your existing Supabase backend.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Read-only import · no write-back',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () => ref
                          .read(ravelryOnboardingControllerProvider.notifier)
                          .connectAndImport(),
                  child: isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Connect Ravelry'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => ref
                          .read(ravelryOnboardingControllerProvider.notifier)
                          .skip(),
                  child: const Text('I\'ll do this later'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
