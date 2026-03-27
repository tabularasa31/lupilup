import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lupilup_flutter/core/providers/supabase_providers.dart';
import 'package:lupilup_flutter/features/settings/data/user_settings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsRepository {
  const SettingsRepository(this._supabase);

  final SupabaseClient _supabase;

  bool _isMissingUserSettingsTable(Object error) {
    return error is PostgrestException &&
        (error.code == '42P01' || error.message.contains('public.user_settings'));
  }

  String _requireUserId() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('No authenticated user.');
    }
    return userId;
  }

  UserSettings _fallbackSettings(String userId) {
    return UserSettings(
      userId: userId,
      unitSystem: UnitSystem.metric,
      aiScansUsed: 0,
      isPremium: false,
      ravelryToken: null,
      createdAt: DateTime.now(),
    );
  }

  Future<UserSettings?> fetchCurrentUserSettings() async {
    final userId = _requireUserId();
    try {
      final response = await _supabase
          .from('user_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        return null;
      }
      return UserSettings.fromMap(response);
    } catch (error) {
      if (_isMissingUserSettingsTable(error)) {
        return _fallbackSettings(userId);
      }
      rethrow;
    }
  }

  Stream<UserSettings?> watchCurrentUserSettings() async* {
    final initial = await fetchCurrentUserSettings();
    yield initial;

    final userId = _requireUserId();
    try {
      yield* _supabase
          .from('user_settings')
          .stream(primaryKey: ['user_id'])
          .eq('user_id', userId)
          .map((rows) {
            if (rows.isEmpty) {
              return null;
            }
            return UserSettings.fromMap(rows.first);
          });
    } catch (error) {
      if (_isMissingUserSettingsTable(error)) {
        yield _fallbackSettings(userId);
        return;
      }
      rethrow;
    }
  }

  Future<void> upsertSettings({
    required UnitSystem unitSystem,
    String? ravelryToken,
    bool clearRavelryToken = false,
  }) async {
    final userId = _requireUserId();
    try {
      await _supabase.from('user_settings').upsert({
        'user_id': userId,
        'unit_system': unitSystem.name,
        'ravelry_token': clearRavelryToken ? null : ravelryToken,
      }, onConflict: 'user_id');
    } catch (error) {
      if (_isMissingUserSettingsTable(error)) {
        return;
      }
      rethrow;
    }
  }

  Future<void> completeOnboardingWithoutRavelry() async {
    await upsertSettings(unitSystem: UnitSystem.metric);
  }

  Future<void> updateUnitSystem(UnitSystem unitSystem) async {
    await upsertSettings(unitSystem: unitSystem);
  }

  Future<void> disconnectRavelry(UnitSystem unitSystem) async {
    await upsertSettings(
      unitSystem: unitSystem,
      clearRavelryToken: true,
    );
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(supabaseProvider));
});

final currentUserSettingsProvider = StreamProvider<UserSettings?>((ref) {
  return ref.watch(settingsRepositoryProvider).watchCurrentUserSettings();
});
