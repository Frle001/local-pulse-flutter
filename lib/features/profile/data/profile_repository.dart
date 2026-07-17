import 'package:supabase_flutter/supabase_flutter.dart';

class Profile {
  const Profile({
    required this.id,
    required this.email,
    this.fullName,
    this.city,
    this.avatarUrl,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      email: map['email'] as String,
      fullName: map['full_name'] as String?,
      city: map['city'] as String?,
      avatarUrl: map['avatar_url'] as String?,
    );
  }

  final String id;
  final String email;
  final String? fullName;
  final String? city;
  final String? avatarUrl;
}

class ProfileRepository {
  ProfileRepository(this._client);

  final SupabaseClient _client;

  Future<Profile?> getProfile(String userId) async {
    final row = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (row == null) return null;
    return Profile.fromMap(row);
  }
}
