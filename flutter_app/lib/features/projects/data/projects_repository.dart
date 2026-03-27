import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lupilup_flutter/core/providers/supabase_providers.dart';
import 'package:lupilup_flutter/features/projects/data/project.dart';
import 'package:lupilup_flutter/features/stash/data/stash_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class ProjectsRepository {
  ProjectsRepository(this._supabase, this._stashRepository) : _uuid = const Uuid();

  final SupabaseClient _supabase;
  final StashRepository _stashRepository;
  final Uuid _uuid;

  bool _isMissingProjectsTable(Object error) {
    return error is PostgrestException &&
        (error.code == '42P01' || error.message.contains('public.projects'));
  }

  String _requireUserId() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('No authenticated user.');
    }
    return userId;
  }

  Stream<List<Project>> watchProjects() async* {
    final userId = _requireUserId();
    try {
      yield* _supabase
          .from('projects')
          .stream(primaryKey: ['id'])
          .eq('user_id', userId)
          .map(
            (rows) => rows.map(Project.fromMap).toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
          );
    } catch (error) {
      if (_isMissingProjectsTable(error)) {
        yield const [];
        return;
      }
      rethrow;
    }
  }

  Future<Project?> fetchById(String id) async {
    final userId = _requireUserId();
    try {
      final row = await _supabase
          .from('projects')
          .select()
          .eq('user_id', userId)
          .eq('id', id)
          .maybeSingle();
      return row == null ? null : Project.fromMap(row);
    } catch (error) {
      if (_isMissingProjectsTable(error)) {
        return null;
      }
      rethrow;
    }
  }

  Future<List<Project>> fetchProjects() async {
    final userId = _requireUserId();
    try {
      final rows = await _supabase
          .from('projects')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return rows.map(Project.fromMap).toList();
    } catch (error) {
      if (_isMissingProjectsTable(error)) {
        return const [];
      }
      rethrow;
    }
  }

  Future<void> saveProject(Project project) async {
    final userId = _requireUserId();
    try {
      await _supabase.from('projects').upsert({
        ...project.toMap(),
        'user_id': userId,
      }, onConflict: 'id');
    } catch (error) {
      if (_isMissingProjectsTable(error)) {
        return;
      }
      rethrow;
    }
  }

  Future<Project> createProject({
    required String title,
    required List<String> yarnIds,
    int currentRow = 0,
  }) async {
    final userId = _requireUserId();
    final project = Project(
      id: _uuid.v4(),
      userId: userId,
      title: title.trim(),
      status: ProjectStatus.active,
      currentRow: currentRow,
      yarnIds: yarnIds,
      createdAt: DateTime.now(),
    );
    await saveProject(project);
    return project;
  }

  Future<void> deleteProject(String id) async {
    final userId = _requireUserId();
    try {
      await _supabase.from('projects').delete().eq('user_id', userId).eq('id', id);
    } catch (error) {
      if (_isMissingProjectsTable(error)) {
        return;
      }
      rethrow;
    }
  }

  Future<void> finishProject({
    required Project project,
    required Map<String, double> leftoverWeightByYarnId,
  }) async {
    for (final entry in leftoverWeightByYarnId.entries) {
      final stashItem = await _stashRepository.fetchById(entry.key);
      if (stashItem == null) continue;
      await _stashRepository.save(
        stashItem.copyWith(currentWeightG: entry.value),
      );
    }

    await saveProject(project.copyWith(status: ProjectStatus.finished));
  }
}

final projectsRepositoryProvider = Provider<ProjectsRepository>((ref) {
  return ProjectsRepository(
    ref.watch(supabaseProvider),
    ref.watch(stashRepositoryProvider),
  );
});

final projectsStreamProvider = StreamProvider<List<Project>>((ref) {
  return ref.watch(projectsRepositoryProvider).watchProjects();
});
