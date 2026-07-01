import 'package:dio/dio.dart';
import 'package:blog_app/models/blog_model.dart';
import 'package:blog_app/models/comment_model.dart';
import 'package:blog_app/services/api_service.dart';
import 'package:blog_app/utils/constants.dart';

class BlogService {
  final Dio _dio = ApiService.instance.dio;

  // ── File Upload ──────────────────────────────────────────────
  
  /// Upload an image and return its URL
  Future<String> uploadImage(String filePath, String fileName, {List<int>? bytes}) async {
    final MultipartFile filePart;
    if (bytes != null) {
      filePart = MultipartFile.fromBytes(bytes, filename: fileName);
    } else {
      filePart = await MultipartFile.fromFile(filePath, filename: fileName);
    }

    final formData = FormData.fromMap({
      'image': filePart,
    });
    
    final response = await _dio.post('/upload', data: formData);
    final data = response.data as Map<String, dynamic>;
    // The backend returns a relative URL like `/uploads/123.jpg`
    // We append it to the base URL (removing the /api suffix)
    final baseUrl = AppConstants.baseUrl.replaceAll('/api', '');
    return '$baseUrl${data['url']}';
  }

  // ── Blog CRUD ──────────────────────────────────────────────

  /// Fetch paginated list of published blogs.
  Future<List<BlogModel>> getBlogs({int page = 1, int limit = AppConstants.pageSize}) async {
    final response = await _dio.get(
      '/blogs',
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data;
    final List rawList = data is List ? data : (data['blogs'] as List? ?? []);
    return rawList.map((e) => BlogModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Fetch a single blog by ID.
  Future<BlogModel> getBlog(String id) async {
    final response = await _dio.get('/blogs/$id');
    final data = response.data;
    final blogData = data is Map<String, dynamic>
        ? (data['blog'] as Map<String, dynamic>? ?? data)
        : data as Map<String, dynamic>;
    return BlogModel.fromJson(blogData);
  }

  /// Create a new blog (Author only).
  Future<BlogModel> createBlog(Map<String, dynamic> payload) async {
    final response = await _dio.post('/blogs', data: payload);
    final data = response.data;
    final blogData = data is Map<String, dynamic>
        ? (data['blog'] as Map<String, dynamic>? ?? data)
        : data as Map<String, dynamic>;
    return BlogModel.fromJson(blogData);
  }

  /// Update an existing blog (Author only).
  Future<BlogModel> updateBlog(String id, Map<String, dynamic> payload) async {
    final response = await _dio.put('/blogs/$id', data: payload);
    final data = response.data;
    final blogData = data is Map<String, dynamic>
        ? (data['blog'] as Map<String, dynamic>? ?? data)
        : data as Map<String, dynamic>;
    return BlogModel.fromJson(blogData);
  }

  /// Delete a blog (Author only).
  Future<void> deleteBlog(String id) async {
    await _dio.delete('/blogs/$id');
  }

  // ── Likes ──────────────────────────────────────────────────

  /// Toggle like on a blog (Viewer login required).
  /// Returns updated [likesCount] and [liked] status.
  Future<({int likesCount, bool liked})> toggleLike(String blogId) async {
    final response = await _dio.post('/blogs/$blogId/like');
    final data = response.data as Map<String, dynamic>;
    return (
      likesCount: (data['likesCount'] as num?)?.toInt() ?? 0,
      liked: data['liked'] as bool? ?? false,
    );
  }

  /// Check if the current viewer has liked a blog.
  Future<bool> getLikeStatus(String blogId) async {
    final response = await _dio.get('/blogs/$blogId/like-status');
    final data = response.data as Map<String, dynamic>;
    return data['liked'] as bool? ?? false;
  }

  // ── Comments ───────────────────────────────────────────────

  /// Fetch comments for a blog (public).
  Future<List<CommentModel>> getComments(String blogId) async {
    final response = await _dio.get('/blogs/$blogId/comments');
    final data = response.data;
    final List rawList = data is List ? data : (data['comments'] as List? ?? []);
    return rawList.map((e) => CommentModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Post a comment (Viewer login required).
  Future<CommentModel> postComment(String blogId, String text) async {
    final response = await _dio.post(
      '/blogs/$blogId/comments',
      data: {'text': text},
    );
    final data = response.data;
    final commentData = data is Map<String, dynamic>
        ? (data['comment'] as Map<String, dynamic>? ?? data)
        : data as Map<String, dynamic>;
    return CommentModel.fromJson(commentData);
  }

  /// Delete a comment (own comment or Author).
  Future<void> deleteComment(String commentId) async {
    await _dio.delete('/comments/$commentId');
  }
}
