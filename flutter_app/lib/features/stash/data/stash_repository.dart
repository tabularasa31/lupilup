import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lupilup_flutter/core/providers/supabase_providers.dart';
import 'package:lupilup_flutter/features/stash/domain/duplicate_detection.dart';
import 'package:lupilup_flutter/features/stash/data/yarn_stash_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class StashRepository {
  StashRepository(this._supabase) : _uuid = const Uuid();

  final SupabaseClient _supabase;
  final Uuid _uuid;

  bool _isMissingYarnStashTable(Object error) {
    return error is PostgrestException &&
        (error.code == '42P01' || error.message.contains('public.yarn_stash'));
  }

  String _requireUserId() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('No authenticated user.');
    }
    return userId;
  }

  Stream<List<YarnStashItem>> watchStash() {
    final userId = _requireUserId();
    return Stream.multi((controller) async {
      List<YarnStashItem>? lastEmitted;
      var closed = false;

      void emitIfChanged(List<YarnStashItem> rows) {
        final normalized = [...rows]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        if (_sameItems(lastEmitted, normalized)) return;
        lastEmitted = normalized;
        if (!closed) {
          controller.add(normalized);
        }
      }

      Future<void> refreshFromFetch() async {
        try {
          emitIfChanged(await fetchStash());
        } catch (error, stackTrace) {
          if (_isMissingYarnStashTable(error)) {
            emitIfChanged(const []);
            return;
          }
          if (!closed) {
            controller.addError(error, stackTrace);
          }
        }
      }

      final realtime = _supabase
          .from('yarn_stash')
          .stream(primaryKey: ['id'])
          .eq('user_id', userId)
          .listen(
        (rows) {
          emitIfChanged(rows.map((row) => YarnStashItem.fromMap(row)).toList());
        },
        onError: (Object error, StackTrace stackTrace) {
          if (_isMissingYarnStashTable(error)) {
            emitIfChanged(const []);
            return;
          }
          if (!closed) {
            controller.addError(error, stackTrace);
          }
        },
      );

      await refreshFromFetch();
      final timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => refreshFromFetch(),
      );

      controller.onCancel = () async {
        closed = true;
        timer.cancel();
        await realtime.cancel();
      };
    });
  }

  bool _sameItems(List<YarnStashItem>? previous, List<YarnStashItem> next) {
    if (previous == null || previous.length != next.length) return false;
    for (var i = 0; i < previous.length; i++) {
      if (_itemSignature(previous[i]) != _itemSignature(next[i])) {
        return false;
      }
    }
    return true;
  }

  String _itemSignature(YarnStashItem item) {
    return [
      item.id,
      item.userId,
      item.type.name,
      item.source.name,
      item.createdAt.toIso8601String(),
      item.brand ?? '',
      item.name ?? '',
      item.colorName ?? '',
      item.colorHex ?? '',
      item.fiberContent ?? '',
      '${item.lengthMPer100g ?? ''}',
      '${item.currentWeightG ?? ''}',
      '${item.originalWeightG ?? ''}',
      item.lot ?? '',
      item.parentIds.join(','),
    ].join('|');
  }

  Future<List<YarnStashItem>> fetchStash() async {
    final userId = _requireUserId();
    try {
      final rows = await _supabase
          .from('yarn_stash')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return rows.map(YarnStashItem.fromMap).toList();
    } catch (error) {
      if (_isMissingYarnStashTable(error)) {
        return const [];
      }
      rethrow;
    }
  }

  Future<YarnStashItem?> fetchById(String id) async {
    final userId = _requireUserId();
    try {
      final row = await _supabase
          .from('yarn_stash')
          .select()
          .eq('user_id', userId)
          .eq('id', id)
          .maybeSingle();
      return row == null ? null : YarnStashItem.fromMap(row);
    } catch (error) {
      if (_isMissingYarnStashTable(error)) {
        return null;
      }
      rethrow;
    }
  }

  Future<void> save(YarnStashItem item) async {
    final userId = _requireUserId();
    final upsertItem = item.userId.isEmpty
        ? item.copyWith(userId: userId)
        : item;
    try {
      await _supabase
          .from('yarn_stash')
          .upsert(upsertItem.toInsertMap(), onConflict: 'id');
    } catch (error) {
      if (_isMissingYarnStashTable(error)) {
        return;
      }
      rethrow;
    }
  }

  Future<void> createManualItem({
    required YarnType type,
    required String brand,
    required String name,
    String? colorName,
    String? fiberContent,
    int? lengthMPer100g,
    double? currentWeightG,
    double? originalWeightG,
    String? lot,
  }) async {
    final userId = _requireUserId();
    String? normalize(String? value) {
      final trimmed = value?.trim() ?? '';
      return trimmed.isEmpty ? null : trimmed;
    }

    final item = YarnStashItem(
      id: _uuid.v4(),
      userId: userId,
      type: type,
      source: YarnSource.manual,
      createdAt: DateTime.now(),
      brand: normalize(brand),
      name: normalize(name),
      colorName: normalize(colorName),
      fiberContent: normalize(fiberContent),
      lengthMPer100g: lengthMPer100g,
      currentWeightG: currentWeightG,
      originalWeightG: originalWeightG,
      lot: normalize(lot),
    );
    await save(item);
  }

  Future<void> importRows(List<YarnStashItem> items) async {
    if (items.isEmpty) return;
    try {
      await _supabase
          .from('yarn_stash')
          .insert(items.map((item) => item.toInsertMap()).toList());
    } catch (error) {
      if (_isMissingYarnStashTable(error)) {
        return;
      }
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    final userId = _requireUserId();
    try {
      await _supabase
          .from('yarn_stash')
          .delete()
          .eq('id', id)
          .eq('user_id', userId);
    } catch (error) {
      if (_isMissingYarnStashTable(error)) {
        return;
      }
      rethrow;
    }
  }

  Future<List<YarnStashItem>> suggestDuplicates({
    String? brand,
    String? colorName,
    String? lot,
  }) async {
    final rows = await fetchStash();
    final scored = rows
        .map(
          (item) => (
            item: item,
            score: duplicateScore(
              item,
              brand: brand,
              colorName: colorName,
              lot: lot,
            ),
          ),
        )
        .where((entry) => entry.score > 0.34)
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    return scored.take(10).map((entry) => entry.item).toList();
  }

  YarnStashItem makeDraft({
    required YarnSource source,
    YarnType type = YarnType.skein,
    String? brand,
    String? name,
    String? colorName,
    String? fiberContent,
    int? lengthMPer100g,
    double? currentWeightG,
    double? originalWeightG,
    String? lot,
  }) {
    final userId = _supabase.auth.currentUser?.id ?? '';
    return YarnStashItem(
      id: _uuid.v4(),
      userId: userId,
      type: type,
      source: source,
      createdAt: DateTime.now(),
      brand: brand,
      name: name,
      colorName: colorName,
      fiberContent: fiberContent,
      lengthMPer100g: lengthMPer100g,
      currentWeightG: currentWeightG,
      originalWeightG: originalWeightG,
      lot: lot,
    );
  }
}

final stashRepositoryProvider = Provider<StashRepository>((ref) {
  return StashRepository(ref.watch(supabaseProvider));
});

final stashStreamProvider = StreamProvider<List<YarnStashItem>>((ref) {
  return ref.watch(stashRepositoryProvider).watchStash();
});
