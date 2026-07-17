import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  Stream<AuthState> authStateChanges() => _client.auth.onAuthStateChange;

  User? currentUser() => _client.auth.currentUser;

  Future<void> signInWithEmailPassword(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUpWithEmailPassword({
    required String email,
    required String password,
    required String fullName,
    required String city,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException(
        'Sign up did not return a user. Please try again.',
      );
    }

    await _client.from('profiles').insert({
      'id': user.id,
      'email': email,
      'full_name': fullName,
      'city': city,
    });
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
