import '../../domain/entities/post_entity.dart';

/// Data model for Post with JSON serialization.
///
/// Extends the domain entity with parsing capabilities.
/// Maps API response to domain entity.
class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.title,
    required super.body,
    required super.userId,
    required super.tags,
    required super.reactions,
    required super.likes,
    required super.dislikes,
    required super.views,
  });

  /// Factory constructor to parse JSON from DummyJSON API
  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Handle reactions — can be an object or int
    int likes = 0;
    int dislikes = 0;
    int totalReactions = 0;

    final reactions = json['reactions'];
    if (reactions is Map<String, dynamic>) {
      likes = reactions['likes'] as int? ?? 0;
      dislikes = reactions['dislikes'] as int? ?? 0;
      totalReactions = likes + dislikes;
    } else if (reactions is int) {
      totalReactions = reactions;
    }

    return PostModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      userId: json['userId'] as int? ?? 0,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      reactions: totalReactions,
      likes: likes,
      dislikes: dislikes,
      views: json['views'] as int? ?? 0,
    );
  }

  /// Convert back to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'type': 'post',
      'id': id,
      'title': title,
      'body': body,
      'userId': userId,
      'tags': tags,
      'reactions': reactions,
      'likes': likes,
      'dislikes': dislikes,
      'views': views,
    };
  }

  /// Create from cached JSON
  factory PostModel.fromCacheJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      userId: json['userId'] as int? ?? 0,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      reactions: json['reactions'] as int? ?? 0,
      likes: json['likes'] as int? ?? 0,
      dislikes: json['dislikes'] as int? ?? 0,
      views: json['views'] as int? ?? 0,
    );
  }
}
