import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/post_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/saved_posts_repository.dart';

final savedPostsRepositoryProvider = Provider<SavedPostsRepository>((ref) {
  return SavedPostsRepository(ref.watch(supabaseClientProvider));
});

/// Tracks which post IDs are saved by the current user, with optimistic
/// toggling so the save icon reacts instantly and rolls back on failure.
class SavedPostIdsController extends StateNotifier<AsyncValue<Set<String>>> {
  SavedPostIdsController(this._repository) : super(const AsyncLoading()) {
    refresh();
  }

  final SavedPostsRepository _repository;

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final ids = await _repository.fetchSavedPostIds();
      state = AsyncData(ids);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  bool isSaved(String postId) => state.valueOrNull?.contains(postId) ?? false;

  Future<void> toggle(String postId) async {
    final previous = state.valueOrNull;
    if (previous == null) return;

    final wasSaved = previous.contains(postId);
    final optimistic = Set<String>.from(previous);
    wasSaved ? optimistic.remove(postId) : optimistic.add(postId);
    state = AsyncData(optimistic);

    try {
      if (wasSaved) {
        await _repository.unsavePost(postId);
      } else {
        await _repository.savePost(postId);
      }
    } catch (error) {
      state = AsyncData(previous);
      rethrow;
    }
  }
}

final savedPostIdsProvider =
    StateNotifierProvider<SavedPostIdsController, AsyncValue<Set<String>>>((
  ref,
) {
  return SavedPostIdsController(ref.watch(savedPostsRepositoryProvider));
});

/// Full saved-post list for the Saved screen.
class SavedPostsController extends StateNotifier<AsyncValue<List<PostModel>>> {
  SavedPostsController(this._repository) : super(const AsyncLoading()) {
    refresh();
  }

  final SavedPostsRepository _repository;

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final posts = await _repository.fetchSavedPosts();
      state = AsyncData(posts);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  void removeLocally(String postId) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.where((post) => post.id != postId).toList());
  }
}

final savedPostsControllerProvider = StateNotifierProvider<
    SavedPostsController, AsyncValue<List<PostModel>>>((ref) {
  return SavedPostsController(ref.watch(savedPostsRepositoryProvider));
});
