import 'package:blog_app/models/user_model.dart';
import 'package:blog_app/utils/constants.dart';

// Resolves a potentially relative image URL to an absolute one.
// - Already absolute (http/https) → returned as-is
// - Starts with /uploads/           → prepended with base host
// - Null / empty                    → null
String? _resolveUrl(String? raw, String base) {
  if (raw == null || raw.isEmpty) return null;
  if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
  if (raw.startsWith('/')) return '$base$raw';
  return raw; // relative without leading slash — return unchanged
}

class BlogModel {
  final String id;
  final String title;
  final String content;
  final String? coverImageUrl;
  final UserModel? author;
  final List<String> tags;
  final int likesCount;
  final List<String> likedBy; // list of user IDs
  final int commentsCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool published;

  const BlogModel({
    required this.id,
    required this.title,
    required this.content,
    this.coverImageUrl,
    this.author,
    required this.tags,
    required this.likesCount,
    required this.likedBy,
    required this.commentsCount,
    required this.createdAt,
    required this.updatedAt,
    required this.published,
  });

  factory BlogModel.fromJson(Map<String, dynamic> json) {
    // Author can be a nested object or just a string ID
    UserModel? author;
    final authorData = json['author'];
    if (authorData is Map<String, dynamic>) {
      author = UserModel.fromJson(authorData);
    }

    // Tags
    final rawTags = json['tags'];
    List<String> tags = [];
    if (rawTags is List) {
      tags = rawTags.map((t) => t.toString()).toList();
    }

    // LikedBy — list of user ID strings
    final rawLikedBy = json['likedBy'];
    List<String> likedBy = [];
    if (rawLikedBy is List) {
      likedBy = rawLikedBy.map((t) => t.toString()).toList();
    }

    // Derive the server base URL (strip /api suffix) e.g. https://inkwell-ip7n.onrender.com
    final base = AppConstants.baseUrl.replaceAll(RegExp(r'/api/?$'), '');

    // Fix relative image URLs embedded in markdown content
    String content = json['content'] as String? ?? '';
    content = content.replaceAllMapped(
      RegExp(r'!\[([^\]]*)\]\((/[^)]+)\)'),
      (m) {
        final path = m[2]!;
        if (path.startsWith('http')) return m[0]!; // already absolute
        return '![${m[1]}]($base$path)';
      },
    );

    final coverImageUrl = _resolveUrl(json['coverImageUrl'] as String?, base);

    return BlogModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: content,
      coverImageUrl: coverImageUrl,
      author: author,
      tags: tags,
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      likedBy: likedBy,
      commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      published: json['published'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'title': title,
        'content': content,
        'coverImageUrl': coverImageUrl,
        'tags': tags,
        'likesCount': likesCount,
        'likedBy': likedBy,
        'commentsCount': commentsCount,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'published': published,
      };

  bool isLikedByUser(String userId) => likedBy.contains(userId);

  BlogModel copyWith({
    String? id,
    String? title,
    String? content,
    String? coverImageUrl,
    UserModel? author,
    List<String>? tags,
    int? likesCount,
    List<String>? likedBy,
    int? commentsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? published,
  }) {
    return BlogModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      author: author ?? this.author,
      tags: tags ?? this.tags,
      likesCount: likesCount ?? this.likesCount,
      likedBy: likedBy ?? this.likedBy,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      published: published ?? this.published,
    );
  }
}
