import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/models/post_model.dart';

class SavedPostsRepository {
  SavedPostsRepository(this._client);

  final SupabaseClient _client;

  String get _requireUserId {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('Cannot manage saved posts without a signed-in user.');
    }
    return user.id;
  }

  Future<Set<String>> fetchSavedPostIds() async {
    final rows = await _client
        .from('post_saves')
        .select('post_id')
        .eq('user_id', _requireUserId);

    return rows.map((row) => row['post_id'] as String).toSet();
  }

  Future<void> savePost(String postId) async {
    await _client.from('post_saves').insert({
      'user_id': _requireUserId,
      'post_id': postId,
    });
  }

  Future<void> unsavePost(String postId) async {
    await _client
        .from('post_saves')
        .delete()
        .eq('user_id', _requireUserId)
        .eq('post_id', postId);
  }

  Future<List<PostModel>> fetchSavedPosts() async {
    final rows = await _client
        .from('post_saves')
        .select('created_at, posts(*)')
        .eq('user_id', _requireUserId)
        .order('created_at', ascending: false);

    return rows
        .where((row) => row['posts'] != null)
        .map((row) => PostModel.fromMap(row['posts'] as Map<String, dynamic>))
        .toList();
  }
}
