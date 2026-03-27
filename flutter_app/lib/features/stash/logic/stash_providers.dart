import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lupilup_flutter/features/stash/data/stash_repository.dart';
import 'package:lupilup_flutter/features/stash/data/yarn_stash_item.dart';

final stashFilterProvider = StateProvider<StashFilter>((ref) {
  return const StashFilter();
});

final filteredStashProvider = Provider<AsyncValue<List<YarnStashItem>>>((ref) {
  final filter = ref.watch(stashFilterProvider);
  final stash = ref.watch(stashStreamProvider);
  return stash.whenData(
    (items) => items.where(filter.matches).toList(),
  );
});

final stashItemProvider = FutureProvider.family<YarnStashItem?, String>((ref, id) {
  return ref.watch(stashRepositoryProvider).fetchById(id);
});

