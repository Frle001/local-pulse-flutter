import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/post_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/saved_posts_repository.dart';

final savedPostsRepositoryProvider = Provider<SavedPostsRepository>((ref) {
  return SavedPostsRepository(ref.watch(supabaseClientProvider));
});

/// Tracks which post IDs are saved by the current user, with optimistic
/// toggling so the save icon reacts instantly and rolls back on failure.
///
/// This is the single source of truth for saved state: toggling here also
/// keeps [savedPostsControllerProvider]'s post list in sync, so Home and the
/// Saved screen never disagree without a manual refresh being required.
class SavedPostIdsController extends StateNotifier<AsyncValue<Set<String>>> {
  SavedPostIdsController(this._ref, this._repository)
      : super(const AsyncLoading()) {
    refresh();
  }

  final Ref _ref;
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

  Future<void> toggle(PostModel post) async {
    final previous = state.valueOrNull;
    if (previous == null) return;

    final wasSaved = previous.contains(post.id);
    final optimistic = {...previous};
    wasSaved ? optimistic.remove(post.id) : optimistic.add(post.id);
    state = AsyncData(optimistic);

    final savedPostsNotifier = _ref.read(savedPostsControllerProvider.notifier);
    if (wasSaved) {
      savedPostsNotifier.removeLocally(post.id);
    } else {
      savedPostsNotifier.addLocally(post);
    }

    try {
      if (wasSaved) {
        await _repository.unsavePost(post.id);
      } else {
        await _repository.savePost(post.id);
      }
    } catch (error) {
      // Roll back both the ID set and the post list so the two stay in sync.
      state = AsyncData(previous);
      if (wasSaved) {
        savedPostsNotifier.addLocally(post);
      } else {
        savedPostsNotifier.removeLocally(post.id);
      }
      rethrow;
    }
  }
}

final savedPostIdsProvider =
    StateNotifierProvider<SavedPostIdsController, AsyncValue<Set<String>>>((
  ref,
) {
  return SavedPostIdsController(ref, ref.watch(savedPostsRepositoryProvider));
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

  void addLocally(PostModel post) {
    final current = state.valueOrNull;
    if (current == null) return;
    if (current.any((existing) => existing.id == post.id)) return;
    state = AsyncData([post, ...current]);
  }
}

final savedPostsControllerProvider = StateNotifierProvider<
    SavedPostsController, AsyncValue<List<PostModel>>>((ref) {
  return SavedPostsController(ref.watch(savedPostsRepositoryProvider));
});
