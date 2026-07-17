class PostModel {
  const PostModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.city,
    required this.category,
    required this.imageUrl,
    required this.createdAt,
  });

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      city: map['city'] as String,
      category: map['category'] as String,
      imageUrl: map['image_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  final String id;
  final String userId;
  final String title;
  final String? description;
  final String city;
  final String category;
  final String? imageUrl;
  final DateTime createdAt;
}
