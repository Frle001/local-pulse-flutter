import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/post_model.dart';
import '../../../shared/widgets/post_image.dart';
import '../providers/saved_posts_provider.dart';

class SavedPostsScreen extends ConsumerWidget {
  const SavedPostsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedPostsAsync = ref.watch(savedPostsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Posts')),
      body: savedPostsAsync.when(
        data: (posts) {
          if (posts.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bookmark_border, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('No saved posts yet.'),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(savedPostsControllerProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              itemBuilder: (context, index) =>
                  _SavedPostCard(post: posts[index]),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(
                  'Could not load saved posts.\n$error',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(savedPostsControllerProvider.notifier).refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SavedPostCard extends ConsumerWidget {
  const _SavedPostCard({required this.post});

  final PostModel post;

  Future<void> _unsave(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(savedPostIdsProvider.notifier).toggle(post);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not unsave post: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
            PostImage(imageUrl: post.imageUrl!),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        post.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.bookmark),
                      tooltip: 'Unsave',
                      onPressed: () => _unsave(context, ref),
                    ),
                  ],
                ),
                if (post.description != null &&
                    post.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(post.description!),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Chip(
                      label: Text(post.city),
                      avatar: const Icon(Icons.place_outlined, size: 16),
                      visualDensity: VisualDensity.compact,
                    ),
                    Chip(
                      label: Text(post.category),
                      avatar: const Icon(Icons.label_outline, size: 16),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
