/// Domain entity representing a Post in the feed.
///
/// Pure domain object — no JSON parsing logic here.
/// Models in the data layer handle serialization.
class PostEntity {
  final int id;
  final String title;
  final String body;
  final int userId;
  final List<String> tags;
  final int reactions;
  final int likes;
  final int dislikes;
  final int views;

  const PostEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
    required this.tags,
    required this.reactions,
    required this.likes,
    required this.dislikes,
    required this.views,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
