import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/models/post_model.dart';

const _postImagesBucket = 'post-images';

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

  Future<String> uploadPostImage({
    required Uint8List bytes,
    required String fileExtension,
    String? contentType,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('Cannot upload an image without a signed-in user.');
    }

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
    final path = 'posts/${user.id}/$fileName';

    await _client.storage.from(_postImagesBucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: contentType ?? 'image/$fileExtension',
            upsert: true,
          ),
        );

    return _client.storage.from(_postImagesBucket).getPublicUrl(path);
  }

  Future<void> createPost({
    required String title,
    required String description,
    required String city,
    required String category,
    String? imageUrl,
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
      'image_url': imageUrl,
    });
  }
}
