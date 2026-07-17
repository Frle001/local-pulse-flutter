import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth_repository.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});

final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateChangesProvider).valueOrNull;
  return authState?.session?.user ??
      ref.watch(authRepositoryProvider).currentUser();
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this._repository) : super(const AsyncData(null));

  final AuthRepository _repository;

  Future<bool> signIn(String email, String password) async {
    state = const AsyncLoading();
    try {
      await _repository.signInWithEmailPassword(email, password);
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String city,
  }) async {
    state = const AsyncLoading();
    try {
      await _repository.signUpWithEmailPassword(
        email: email,
        password: password,
        fullName: fullName,
        city: city,
      );
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});
