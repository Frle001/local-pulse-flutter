import 'package:flutter/material.dart';

class PostImage extends StatelessWidget {
  const PostImage({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          height: 200,
          alignment: Alignment.center,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const CircularProgressIndicator(),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 200,
          alignment: Alignment.center,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Icon(Icons.broken_image_outlined, size: 40),
        );
      },
    );
  }
}
