import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:lupilup_flutter/features/ravelry/data/ravelry_repository.dart';
import 'package:lupilup_flutter/features/settings/data/settings_repository.dart';
import 'package:lupilup_flutter/features/settings/data/user_settings.dart';
import 'package:lupilup_flutter/features/stash/data/stash_repository.dart';

class RavelryOnboardingController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> skip() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(settingsRepositoryProvider).completeOnboardingWithoutRavelry();
    });
  }

  Future<void> connectAndImport() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(ravelryRepositoryProvider);
      final authorizationUrl = repository.buildAuthorizationUri();
      final callbackUrl = await FlutterWebAuth2.authenticate(
        url: authorizationUrl.toString(),
        callbackUrlScheme: 'lupilup',
      );

      final callbackUri = Uri.parse(callbackUrl);
      final code = callbackUri.queryParameters['code'];
      if (code == null || code.isEmpty) {
        throw StateError('Missing authorization code in Ravelry callback.');
      }

      final accessToken = await repository.exchangeCodeForToken(code);
      final result = await repository.importStash(accessToken);

      await ref.read(settingsRepositoryProvider).upsertSettings(
            unitSystem: result.unitSystem,
            ravelryToken: accessToken,
          );
      await ref.read(stashRepositoryProvider).importRows(result.rows);
    });
  }

  Future<void> disconnect(UnitSystem unitSystem) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(settingsRepositoryProvider).disconnectRavelry(unitSystem);
    });
  }
}

final ravelryOnboardingControllerProvider =
    AsyncNotifierProvider<RavelryOnboardingController, void>(
  RavelryOnboardingController.new,
);

