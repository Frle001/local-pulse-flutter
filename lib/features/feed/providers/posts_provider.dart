import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/post_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/posts_repository.dart';

final postsRepositoryProvider = Provider<PostsRepository>((ref) {
  return PostsRepository(ref.watch(supabaseClientProvider));
});

class PostsController extends StateNotifier<AsyncValue<List<PostModel>>> {
  PostsController(this._repository) : super(const AsyncLoading()) {
    refresh();
  }

  final PostsRepository _repository;

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final posts = await _repository.fetchPosts();
      state = AsyncData(posts);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> createPost({
    required String title,
    required String description,
    required String city,
    required String category,
  }) async {
    await _repository.createPost(
      title: title,
      description: description,
      city: city,
      category: category,
    );
    await refresh();
  }
}

final postsControllerProvider =
    StateNotifierProvider<PostsController, AsyncValue<List<PostModel>>>((
  ref,
) {
  return PostsController(ref.watch(postsRepositoryProvider));
});
