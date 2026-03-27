import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lupilup_flutter/core/providers/supabase_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  const AuthRepository(this._supabase);

  final SupabaseClient _supabase;

  Stream<AuthState> authStateChanges() {
    return _supabase.auth.onAuthStateChange;
  }

  Session? get currentSession => _supabase.auth.currentSession;

  User? get currentUser => _supabase.auth.currentUser;

  Future<void> signInWithGoogle() async {
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'lupilup://auth/callback',
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  Future<void> sendMagicLink(String email) async {
    await _supabase.auth.signInWithOtp(
      email: email.trim().toLowerCase(),
      emailRedirectTo: 'lupilup://auth/callback',
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseProvider));
});
