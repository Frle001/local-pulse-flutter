import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/models/post_model.dart';

class PostsRepository {
  PostsRepository(this._client);

  final SupabaseClient _client;

  Future<List<PostModel>> fetchPosts() async {
    final rows = await _client
        .from('posts')
        .select()
        .eq('is_active', true)
        .eq('is_flagged', false)
        .order('created_at', ascending: false)
        .limit(50);

    return rows.map(PostModel.fromMap).toList();
  }

  Future<void> createPost({
    required String title,
    required String description,
    required String city,
    required String category,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('Cannot create a post without a signed-in user.');
    }

    await _client.from('posts').insert({
      'user_id': user.id,
      'title': title,
      'description': description,
      'city': city,
      'category': category,
    });
  }
}
