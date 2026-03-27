import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lupilup_flutter/core/theme/app_theme.dart';
import 'package:lupilup_flutter/core/widgets/app_scaffold.dart';
import 'package:lupilup_flutter/core/widgets/section_card.dart';
import 'package:lupilup_flutter/features/projects/data/project.dart';
import 'package:lupilup_flutter/features/projects/data/projects_repository.dart';
import 'package:lupilup_flutter/features/projects/logic/project_providers.dart';
import 'package:lupilup_flutter/features/stash/data/stash_repository.dart';
import 'package:lupilup_flutter/features/stash/data/yarn_stash_item.dart';

class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({required this.projectId, super.key});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider(projectId));
    final stash = ref.watch(stashStreamProvider);

    return project.when(
      data: (value) {
        if (value == null) {
          return const AppScaffold(
            child: Center(child: Text('Project not found.')),
          );
        }
        return _ProjectDetailView(project: value, stash: stash.value ?? const []);
      },
      loading: () => const AppScaffold(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => AppScaffold(
        child: Center(child: Text('Could not load project: $error')),
      ),
    );
  }
}

class _ProjectDetailView extends ConsumerStatefulWidget {
  const _ProjectDetailView({
    required this.project,
    required this.stash,
  });

  final Project project;
  final List<YarnStashItem> stash;

  @override
  ConsumerState<_ProjectDetailView> createState() => _ProjectDetailViewState();
}

class _ProjectDetailViewState extends ConsumerState<_ProjectDetailView> {
  late final TextEditingController _title;
  late final TextEditingController _currentRow;
  late ProjectStatus _status;
  final Map<String, TextEditingController> _leftovers = {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.project.title);
    _currentRow = TextEditingController(text: widget.project.currentRow.toString());
    _status = widget.project.status;
  }

  @override
  void dispose() {
    _title.dispose();
    _currentRow.dispose();
    for (final controller in _leftovers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _leftoverController(String yarnId) {
    return _leftovers.putIfAbsent(yarnId, () => TextEditingController());
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final updatedProject = widget.project.copyWith(
        title: _title.text.trim(),
        currentRow: int.tryParse(_currentRow.text.trim()) ?? 0,
        status: _status,
      );
      await ref.read(projectsRepositoryProvider).saveProject(
            updatedProject,
          );
      ref.invalidate(projectsStreamProvider);
      ref.invalidate(projectProvider(widget.project.id));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project updated.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update project: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    try {
      final leftovers = <String, double>{};
      for (final yarnId in widget.project.yarnIds) {
        final value = double.tryParse(_leftoverController(yarnId).text.trim());
        if (value != null) {
          leftovers[yarnId] = value;
        }
      }

      await ref.read(projectsRepositoryProvider).finishProject(
            project: widget.project.copyWith(
              title: _title.text.trim(),
              currentRow: int.tryParse(_currentRow.text.trim()) ?? 0,
            ),
            leftoverWeightByYarnId: leftovers,
          );
      ref.invalidate(projectsStreamProvider);
      ref.invalidate(projectProvider(widget.project.id));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project finished.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not finish project: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final linkedYarn = widget.stash
        .where((item) => widget.project.yarnIds.contains(item.id))
        .toList();

    return AppScaffold(
      title: widget.project.title,
      child: ListView(
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Project title'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ProjectStatus>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: ProjectStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _status = value ?? _status),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _currentRow,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Current row'),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: const Text('Save changes'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Linked yarn', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                if (linkedYarn.isEmpty)
                  Text(
                    'No stash yarn linked yet.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  )
                else
                  for (final yarn in linkedYarn) ...[
                    Text(yarn.title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _leftoverController(yarn.id),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Leftover weight for ${yarn.title} (g)',
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _saving ? null : _finish,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Finish project and update leftovers'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _saving
                ? null
                : () async {
                    await ref.read(projectsRepositoryProvider).deleteProject(widget.project.id);
                    ref.invalidate(projectsStreamProvider);
                    ref.invalidate(projectProvider(widget.project.id));
                    if (context.mounted) {
                      context.pop();
                    }
                  },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete project'),
          ),
        ],
      ),
    );
  }
}
