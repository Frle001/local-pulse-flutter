import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/models/post_model.dart';
import '../../saved/providers/saved_posts_provider.dart';
import '../providers/posts_provider.dart';

class HomeFeedScreen extends ConsumerWidget {
  const HomeFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Pulse'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            tooltip: 'Saved posts',
            onPressed: () => context.push('/saved'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: postsAsync.when(
        data: (posts) {
          if (posts.isEmpty) {
            return _EmptyState(
              onRefresh: () =>
                  ref.read(postsControllerProvider.notifier).refresh(),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(postsControllerProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              itemBuilder: (context, index) => _PostCard(post: posts[index]),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref.read(postsControllerProvider.notifier).refresh(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-post'),
        icon: const Icon(Icons.add),
        label: const Text('New Post'),
      ),
    );
  }
}

class _PostCard extends ConsumerWidget {
  const _PostCard({required this.post});

  final PostModel post;

  Future<void> _toggleSave(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(savedPostIdsProvider.notifier).toggle(post.id);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update saved posts: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedIdsAsync = ref.watch(savedPostIdsProvider);
    final isSaved = savedIdsAsync.valueOrNull?.contains(post.id) ?? false;
    final savedIdsLoaded = savedIdsAsync.hasValue;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
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
                  icon: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_outline,
                  ),
                  tooltip: isSaved ? 'Unsave' : 'Save',
                  onPressed:
                      savedIdsLoaded ? () => _toggleSave(context, ref) : null,
                ),
              ],
            ),
            if (post.description != null && post.description!.isNotEmpty) ...[
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
            const SizedBox(height: 6),
            Text(
              _formatTimestamp(post.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final local = dateTime.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text('No posts yet. Be the first to share something!'),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRefresh, child: const Text('Refresh')),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              'Could not load posts.\n$message',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
