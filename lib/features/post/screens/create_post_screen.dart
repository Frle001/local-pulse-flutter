import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../feed/providers/posts_provider.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _categoryController = TextEditingController(text: 'general');
  final _imagePicker = ImagePicker();

  Uint8List? _imageBytes;
  String? _imageFileExtension;
  String? _imageMimeType;

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      final extension = _extensionFromName(picked.name);

      setState(() {
        _imageBytes = bytes;
        _imageFileExtension = extension;
        _imageMimeType = picked.mimeType;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Could not pick image: $error');
    }
  }

  void _removeImage() {
    setState(() {
      _imageBytes = null;
      _imageFileExtension = null;
      _imageMimeType = null;
    });
  }

  String? _extensionFromName(String name) {
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == name.length - 1) return null;
    return name.substring(dotIndex + 1).toLowerCase();
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await ref.read(postsControllerProvider.notifier).createPost(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            city: _cityController.text.trim(),
            category: _categoryController.text.trim(),
            imageBytes: _imageBytes,
            imageFileExtension: _imageFileExtension,
            imageContentType: _imageMimeType,
          );

      if (!mounted) return;
      context.pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Post')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ImagePickerPreview(
                imageBytes: _imageBytes,
                onPick: _isSubmitting ? null : _pickImage,
                onRemove: _isSubmitting ? null : _removeImage,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'City is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Category is required';
                  }
                  return null;
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePickerPreview extends StatelessWidget {
  const _ImagePickerPreview({
    required this.imageBytes,
    required this.onPick,
    required this.onRemove,
  });

  final Uint8List? imageBytes;
  final VoidCallback? onPick;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    if (imageBytes == null) {
      return OutlinedButton.icon(
        onPressed: onPick,
        icon: const Icon(Icons.image_outlined),
        label: const Text('Add Photo (optional)'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            imageBytes!,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onRemove,
            icon: const Icon(Icons.close),
            label: const Text('Remove Photo'),
          ),
        ),
      ],
    );
  }
}
