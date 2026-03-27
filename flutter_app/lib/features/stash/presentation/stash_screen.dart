import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lupilup_flutter/core/theme/app_theme.dart';
import 'package:lupilup_flutter/core/widgets/app_scaffold.dart';
import 'package:lupilup_flutter/core/widgets/section_card.dart';
import 'package:lupilup_flutter/features/stash/data/stash_repository.dart';
import 'package:lupilup_flutter/features/stash/data/yarn_stash_item.dart';
import 'package:lupilup_flutter/features/stash/logic/stash_providers.dart';
import 'package:lupilup_flutter/features/stash/presentation/widgets/yarn_card.dart';

class StashScreen extends ConsumerWidget {
  const StashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(filteredStashProvider);
    final filter = ref.watch(stashFilterProvider);
    final totalItems = ref.watch(stashStreamProvider).valueOrNull?.length ?? 0;

    return AppScaffold(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StashHeader(count: totalItems),
          const SizedBox(height: 22),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.borderStrong),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by brand, fiber, color...',
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                prefixIcon: const Icon(Icons.search, size: 22),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              ),
              onChanged: (value) {
                ref.read(stashFilterProvider.notifier).state = StashFilter(
                      types: filter.types,
                      search: value,
                    );
              },
            ),
          ),
          const SizedBox(height: 12),
          _FilterBar(filter: filter),
          const SizedBox(height: 22),
          Expanded(
            child: items.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
              error: (error, _) => _StashStatusCard(
                title: 'Could not load stash',
                body: '$error',
                icon: Icons.error_outline_rounded,
              ),
              data: (rows) {
                if (rows.isEmpty) {
                  return _StashStatusCard(
                    title: 'Your stash is ready for its first skein',
                    body: 'Add yarn manually, import from Ravelry, or use the scanner to build your inventory.',
                    icon: Icons.spa_outlined,
                    action: ElevatedButton(
                      onPressed: () => context.push('/stash/add-edit'),
                      child: const Text('Add first yarn'),
                    ),
                    eyebrow: 'A soft place to begin',
                  );
                }

                return ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = rows[index];
                    return _StashCard(item: item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StashHeader extends StatelessWidget {
  const _StashHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'my stash',
                style: GoogleFonts.ptSerif(
                  color: const Color(0xFFBBBBBB),
                  fontSize: 10,
                  height: 1,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Yarn',
                style: GoogleFonts.playfairDisplay(
                  color: AppColors.textPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  height: 0.96,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            '$count',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.filter});

  final StashFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(stashFilterProvider.notifier);
    const pillSpacing = SizedBox(width: 8);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterPill(
            label: 'All',
            selected: filter.types.isEmpty,
            onTap: () => notifier.state = const StashFilter(),
          ),
          pillSpacing,
          for (final type in YarnType.values) ...[
            _FilterPill(
              label: _typeLabel(type),
              selected: filter.types.length == 1 && filter.types.contains(type),
              onTap: () {
                notifier.state = StashFilter(
                  types: {type},
                  search: filter.search,
                );
              },
            ),
            pillSpacing,
          ],
        ],
      ),
    );
  }

  String _typeLabel(YarnType type) => switch (type) {
        YarnType.skein => 'Skeins',
        YarnType.bobbin => 'Bobbins',
        YarnType.blend => 'Blends',
      };
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? AppColors.textPrimary : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.textPrimary : AppColors.borderStrong,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: selected ? Colors.white : const Color(0xFFAAAAAA),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

class _StashCard extends ConsumerWidget {
  const _StashCard({required this.item});

  final YarnStashItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return YarnCard(
      item: item,
      onTap: () => context.push('/stash/add-edit?id=${Uri.encodeComponent(item.id)}'),
      trailing: PopupMenuButton<String>(
        color: AppColors.surface,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 120),
        icon: const Icon(
          Icons.more_horiz_rounded,
          color: AppColors.textSecondary,
          size: 18,
        ),
        onSelected: (value) async {
          if (value == 'edit') {
            context.push('/stash/add-edit?id=${Uri.encodeComponent(item.id)}');
          } else if (value == 'delete') {
            await ref.read(stashRepositoryProvider).delete(item.id);
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'edit', child: Text('Edit')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
    );
  }
}

class _StashStatusCard extends StatelessWidget {
  const _StashStatusCard({
    required this.title,
    required this.body,
    required this.icon,
    this.action,
    this.eyebrow,
  });

  final String title;
  final String body;
  final IconData icon;
  final Widget? action;
  final String? eyebrow;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: SectionCard(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F4F0),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.borderStrong),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: AppColors.textPrimary, size: 30),
                ),
                if (eyebrow != null) ...[
                  const SizedBox(height: 18),
                  Text(
                    eyebrow!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                  ),
                ],
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 34,
                        height: 1.12,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.65,
                      ),
                ),
                if (action != null) ...[
                  const SizedBox(height: 22),
                  SizedBox(width: double.infinity, child: action!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
