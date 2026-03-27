import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lupilup_flutter/features/auth/data/auth_repository.dart';
import 'package:lupilup_flutter/features/settings/data/settings_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AppBootstrapTarget {
  login,
  onboarding,
  stash,
}

class BootstrapState {
  const BootstrapState({
    required this.target,
    this.session,
  });

  final AppBootstrapTarget target;
  final Session? session;
}

AppBootstrapTarget resolveBootstrapTarget({
  required bool hasSession,
  required bool hasSettings,
}) {
  if (!hasSession) {
    return AppBootstrapTarget.login;
  }
  if (!hasSettings) {
    return AppBootstrapTarget.onboarding;
  }
  return AppBootstrapTarget.stash;
}

final authStateStreamProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final currentSessionProvider = Provider<Session?>((ref) {
  ref.watch(authStateStreamProvider);
  return ref.watch(authRepositoryProvider).currentSession;
});

final bootstrapStateProvider = FutureProvider<BootstrapState>((ref) async {
  ref.watch(authStateStreamProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  final settingsRepository = ref.watch(settingsRepositoryProvider);
  final session = authRepository.currentSession;

  if (session == null) {
    return const BootstrapState(target: AppBootstrapTarget.login);
  }

  final settings = await settingsRepository.fetchCurrentUserSettings();
  return BootstrapState(
    target: resolveBootstrapTarget(
      hasSession: true,
      hasSettings: settings != null,
    ),
    session: session,
  );
});

final authRefreshListenableProvider = Provider<Stream<void>>((ref) {
  final controller = StreamController<void>();
  final sub = ref.watch(authRepositoryProvider).authStateChanges().listen((_) {
    controller.add(null);
  });
  ref.onDispose(() async {
    await sub.cancel();
    await controller.close();
  });
  return controller.stream;
});
