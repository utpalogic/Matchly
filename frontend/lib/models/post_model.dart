class Post {
  final int id;
  final int userId;
  final String? username;
  final String content;
  final String? imageUrl;
  final String postType;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final String createdAt;
  final List<Comment>? comments;

  Post({
    required this.id,
    required this.userId,
    this.username,
    required this.content,
    this.imageUrl,
    this.postType = 'GENERAL',
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    required this.createdAt,
    this.comments,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['user'],
      username: json['username'],
      content: json['content'],
      imageUrl: json['image'],
      postType: json['post_type'] ?? 'GENERAL',
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      createdAt: json['created_at'],
      comments: json['comments'] != null
          ? (json['comments'] as List).map((c) => Comment.fromJson(c)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'content': content,
      'image': imageUrl,
      'post_type': postType,
    };
  }

  Post copyWith({int? likesCount, bool? isLiked, int? commentsCount}) {
    return Post(
      id: id,
      userId: userId,
      username: username,
      content: content,
      imageUrl: imageUrl,
      postType: postType,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt,
      comments: comments,
    );
  }
}

class Comment {
  final int id;
  final int postId;
  final int userId;
  final String? username;
  final String content;
  final String createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    this.username,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      postId: json['post'],
      userId: json['user'],
      username: json['username'],
      content: json['content'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'post': postId, 'content': content};
  }
}
