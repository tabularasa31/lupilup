import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lupilup_flutter/features/projects/data/project.dart';
import 'package:lupilup_flutter/features/projects/data/projects_repository.dart';

final projectProvider = FutureProvider.family<Project?, String>((ref, id) {
  return ref.watch(projectsRepositoryProvider).fetchById(id);
});

