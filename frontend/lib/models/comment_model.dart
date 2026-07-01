import 'package:blog_app/models/user_model.dart';

class CommentModel {
  final String id;
  final String blogId;
  final UserModel? viewer;
  final String text;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.blogId,
    this.viewer,
    required this.text,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    UserModel? viewer;
    final viewerData = json['viewer'];
    if (viewerData is Map<String, dynamic>) {
      viewer = UserModel.fromJson(viewerData);
    }

    return CommentModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      blogId: json['blog'] as String? ?? '',
      viewer: viewer,
      text: json['text'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'blog': blogId,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };
}
