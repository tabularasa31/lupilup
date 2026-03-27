import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lupilup_flutter/core/theme/app_theme.dart';
import 'package:lupilup_flutter/core/widgets/app_scaffold.dart';
import 'package:lupilup_flutter/core/widgets/section_card.dart';
import 'package:lupilup_flutter/features/projects/data/project.dart';
import 'package:lupilup_flutter/features/projects/data/projects_repository.dart';
import 'package:lupilup_flutter/features/projects/logic/project_providers.dart';
import 'package:lupilup_flutter/features/stash/data/stash_repository.dart';
import 'package:lupilup_flutter/features/stash/data/yarn_stash_item.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsStreamProvider);
    final stash = ref.watch(stashStreamProvider);
    final shouldShowCreateButton = projects.maybeWhen(
      data: (rows) => rows.isNotEmpty,
      orElse: () => false,
    );

    return AppScaffold(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      floatingActionButton: shouldShowCreateButton
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              onPressed: stash.hasValue
                  ? () => showDialog<void>(
                        context: context,
                        builder: (_) => _CreateProjectDialog(
                          stash: stash.value ?? const [],
                        ),
                      )
                  : null,
              label: const Text('New project'),
              icon: const Icon(Icons.add),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ProjectsHeader(),
          const SizedBox(height: 20),
          Expanded(
            child: projects.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
              error: (error, _) => _ProjectsStatusCard(
                title: 'Could not load projects',
                body: '$error',
                icon: Icons.error_outline_rounded,
              ),
              data: (rows) {
                if (rows.isEmpty) {
                  return _ProjectsStatusCard(
                    title: 'No projects yet',
                    body:
                        'Track active knits, link them to stash yarn, and record leftovers when you finish.',
                    icon: Icons.grid_view_rounded,
                    eyebrow: 'A gentle place to plan',
                    action: ElevatedButton(
                      onPressed: stash.hasValue
                          ? () => showDialog<void>(
                                context: context,
                                builder: (_) => _CreateProjectDialog(
                                  stash: stash.value ?? const [],
                                ),
                              )
                          : null,
                      child: const Text('Create project'),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final project = rows[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: () => context.push('/projects/${project.id}'),
                      child: _ProjectCard(project: project),
                    );
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

class _ProjectsHeader extends StatelessWidget {
  const _ProjectsHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Projects',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontSize: 38,
                height: 1,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Keep your works in progress close, with linked yarn and a clear sense of what comes next.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.55,
              ),
        ),
      ],
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final createdAt = DateFormat('MMM d').format(project.createdAt);
    final accentColor = switch (project.status) {
      ProjectStatus.active => const Color(0xFFD9C1BA),
      ProjectStatus.finished => const Color(0xFFD6E7D2),
      ProjectStatus.onHold => const Color(0xFFE9DFC7),
    };

    return SectionCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Icon(
                  switch (project.status) {
                    ProjectStatus.active => Icons.auto_awesome_motion_rounded,
                    ProjectStatus.finished => Icons.check_rounded,
                    ProjectStatus.onHold => Icons.pause_rounded,
                  },
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 22,
                            height: 1.15,
                          ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Started $createdAt',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_outward_rounded,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ProjectMetaPill(label: _statusLabel(project.status)),
              _ProjectMetaPill(label: '${project.yarnIds.length} yarns linked'),
              _ProjectMetaPill(label: 'Row ${project.currentRow}'),
            ],
          ),
        ],
      ),
    );
  }

  String _statusLabel(ProjectStatus status) => switch (status) {
        ProjectStatus.active => 'Active',
        ProjectStatus.finished => 'Finished',
        ProjectStatus.onHold => 'On hold',
      };
}

class _ProjectMetaPill extends StatelessWidget {
  const _ProjectMetaPill({required this.label});

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

class _ProjectsStatusCard extends StatelessWidget {
  const _ProjectsStatusCard({
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
                child: Icon(icon, size: 30, color: AppColors.textPrimary),
              ),
              if (eyebrow != null) ...[
                const SizedBox(height: 18),
                Text(
                  eyebrow!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
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
    );
  }
}

class _CreateProjectDialog extends ConsumerStatefulWidget {
  const _CreateProjectDialog({required this.stash});

  final List<YarnStashItem> stash;

  @override
  ConsumerState<_CreateProjectDialog> createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends ConsumerState<_CreateProjectDialog> {
  final _title = TextEditingController();
  final Set<String> _selectedYarns = {};
  bool _saving = false;

  bool get _canCreate => !_saving && _title.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _title.addListener(_handleTitleChanged);
  }

  @override
  void dispose() {
    _title.removeListener(_handleTitleChanged);
    _title.dispose();
    super.dispose();
  }

  void _handleTitleChanged() {
    setState(() {});
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a project title first.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final project = await ref.read(projectsRepositoryProvider).createProject(
            title: _title.text,
            yarnIds: _selectedYarns.toList(),
          );
      ref.invalidate(projectsStreamProvider);
      ref.invalidate(projectProvider(project.id));
      if (!mounted) return;
      Navigator.of(context).pop();
      context.push('/projects/${project.id}');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create project: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: const Text('New project'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Project title'),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Link yarn from stash',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              for (final yarn in widget.stash)
                CheckboxListTile(
                  value: _selectedYarns.contains(yarn.id),
                  contentPadding: EdgeInsets.zero,
                  title: Text(yarn.title),
                  subtitle: Text(yarn.colorName ?? yarn.source.name),
                  onChanged: (selected) {
                    setState(() {
                      if (selected ?? false) {
                        _selectedYarns.add(yarn.id);
                      } else {
                        _selectedYarns.remove(yarn.id);
                      }
                    });
                  },
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _canCreate ? _save : null,
          child: _saving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}
