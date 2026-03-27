import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lupilup_flutter/core/theme/app_theme.dart';
import 'package:lupilup_flutter/core/widgets/app_scaffold.dart';
import 'package:lupilup_flutter/core/widgets/section_card.dart';
import 'package:lupilup_flutter/features/stash/data/stash_repository.dart';
import 'package:lupilup_flutter/features/stash/data/yarn_stash_item.dart';
import 'package:lupilup_flutter/features/stash/logic/stash_providers.dart';

class StashScreen extends ConsumerWidget {
  const StashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(filteredStashProvider);
    final filter = ref.watch(stashFilterProvider);
    final shouldShowAddButton = items.maybeWhen(
      data: (rows) => rows.isNotEmpty,
      orElse: () => false,
    );

    return AppScaffold(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      floatingActionButton: shouldShowAddButton
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              onPressed: () => context.push('/stash/add-edit'),
              label: const Text('Add yarn'),
              icon: const Icon(Icons.add),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StashHeader(),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderStrong),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A241A17),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search brand, yarn, color, fiber, lot',
                prefixIcon: Icon(Icons.search, size: 22),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              ),
              onChanged: (value) {
                ref.read(stashFilterProvider.notifier).state = StashFilter(
                      sources: filter.sources,
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
  const _StashHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stash',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontSize: 38,
                height: 1,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'A calm overview of every skein, scan, and future project pairing.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.55,
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterPill(
            label: 'All',
            selected: filter.sources.isEmpty && filter.types.isEmpty,
            onTap: () => notifier.state = const StashFilter(),
          ),
          const SizedBox(width: 8),
          for (final source in YarnSource.values) ...[
            _FilterPill(
              label: source.name,
              selected: filter.sources.contains(source),
              onTap: () {
                final selected = !filter.sources.contains(source);
                final sources = {...filter.sources};
                if (selected) {
                  sources.add(source);
                } else {
                  sources.remove(source);
                }
                notifier.state = StashFilter(
                  sources: sources,
                  types: filter.types,
                  search: filter.search,
                );
              },
            ),
            const SizedBox(width: 8),
          ],
          for (final type in YarnType.values) ...[
            _FilterPill(
              label: type.name,
              selected: filter.types.contains(type),
              onTap: () {
                final selected = !filter.types.contains(type);
                final types = {...filter.types};
                if (selected) {
                  types.add(type);
                } else {
                  types.remove(type);
                }
                notifier.state = StashFilter(
                  sources: filter.sources,
                  types: types,
                  search: filter.search,
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
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
          color: selected ? const Color(0xFFF6D7D6) : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? const Color(0xFFF1C1BF) : AppColors.borderStrong,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check_rounded, size: 16, color: AppColors.textPrimary),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
            ),
          ],
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
    final date = DateFormat('MMM d').format(item.createdAt);
    return SectionCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 22,
                            height: 1.15,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        if ((item.colorName ?? '').isNotEmpty) item.colorName,
                        if ((item.lot ?? '').isNotEmpty) 'lot ${item.lot}',
                      ].whereType<String>().join(' · ').ifEmpty('Added $date'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                color: AppColors.surface,
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
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaPill(label: item.source.name),
              _MetaPill(label: item.type.name),
              if (item.currentWeightG != null) _MetaPill(label: '${item.currentWeightG} g'),
              if (item.lengthMPer100g != null) _MetaPill(label: '${item.lengthMPer100g} m/100g'),
            ],
          ),
          if ((item.fiberContent ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              item.fiberContent!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F4F0),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFF0E4DC)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
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
                          color: AppColors.accent,
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

extension on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}
