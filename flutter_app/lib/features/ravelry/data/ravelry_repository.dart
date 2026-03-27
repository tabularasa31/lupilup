import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:lupilup_flutter/core/config/app_env.dart';
import 'package:lupilup_flutter/core/providers/supabase_providers.dart';
import 'package:lupilup_flutter/features/ravelry/domain/ravelry_mapper.dart';
import 'package:lupilup_flutter/features/ravelry/domain/ravelry_models.dart';
import 'package:lupilup_flutter/features/settings/data/user_settings.dart';
import 'package:lupilup_flutter/features/stash/data/stash_repository.dart';
import 'package:lupilup_flutter/features/stash/data/yarn_stash_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class RavelryRepository {
  RavelryRepository(this._supabase, this._stashRepository) : _uuid = const Uuid();

  final SupabaseClient _supabase;
  final StashRepository _stashRepository;
  final Uuid _uuid;

  Uri buildAuthorizationUri() {
    final state = DateTime.now().millisecondsSinceEpoch.toString();
    return Uri.parse(AppEnv.ravelryAuthorizeUrl).replace(queryParameters: {
      'client_id': AppEnv.ravelryClientId,
      'redirect_uri': AppEnv.ravelryRedirectScheme,
      'response_type': 'code',
      'state': state,
      'scope': 'read',
    });
  }

  Future<String> exchangeCodeForToken(String code) async {
    final response = await _supabase.functions.invoke(
      AppEnv.ravelryExchangeFunction,
      body: {
        'code': code,
        'redirect_uri': AppEnv.ravelryRedirectScheme,
      },
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw StateError('Unexpected Ravelry exchange response.');
    }

    final accessToken = data['access_token'] as String?;
    if (accessToken == null || accessToken.isEmpty) {
      throw StateError('Ravelry exchange did not return an access token.');
    }
    return accessToken;
  }

  Future<RavelryImportResult> importStash(String accessToken) async {
    final currentUserJson = await _getJson(
      Uri.parse('https://api.ravelry.com/current_user.json'),
      accessToken,
    );
    final username = extractRavelryUsername(currentUserJson);
    final stashJson = await _getJson(
      Uri.parse(
        'https://api.ravelry.com/people/${Uri.encodeComponent(username)}/stash.json',
      ),
      accessToken,
    );

    final unitSystem = detectRavelryUnitSystem(
      stashJson is Map<String, dynamic> ? stashJson['length_unit'] : null,
    );
    final rows = _mapStashToRows(stashJson, unitSystem);
    return RavelryImportResult(rows: rows, unitSystem: unitSystem);
  }

  Future<dynamic> _getJson(Uri uri, String accessToken) async {
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Ravelry request failed with ${response.statusCode}.');
    }

    return jsonDecode(response.body);
  }

  List<YarnStashItem> _mapStashToRows(dynamic stashJson, UnitSystem unitSystem) {
    final userId = _supabase.auth.currentUser?.id ?? '';
    final rows = mapRavelryStashRows(stashJson, unitSystem);

    return rows
        .map(
          (row) => _stashRepository
              .makeDraft(
                source: YarnSource.ravelry,
                brand: row.brand,
                name: row.name,
                colorName: row.colorName,
                fiberContent: row.fiberContent,
                lengthMPer100g: row.lengthMPer100g,
                currentWeightG: row.currentWeightG,
                originalWeightG: row.originalWeightG,
                lot: row.lot,
              )
              .copyWith(
                id: _uuid.v4(),
                userId: userId,
              ),
        )
        .toList();
  }
}

final ravelryRepositoryProvider = Provider<RavelryRepository>((ref) {
  return RavelryRepository(
    ref.watch(supabaseProvider),
    ref.watch(stashRepositoryProvider),
  );
});
