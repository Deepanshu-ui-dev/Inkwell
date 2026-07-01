import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:blog_app/services/api_service.dart';
import 'package:blog_app/models/blog_model.dart';
import 'package:blog_app/models/comment_model.dart';

class BlogService {
  final Dio _dio = ApiService.instance.dio;

  // ── Blogs ──────────────────────────────────────────────────

  Future<Map<String, dynamic>> getBlogs({int page = 1, int limit = 10}) async {
    final res = await _dio.get('/blogs', queryParameters: {'page': page, 'limit': limit});
    return res.data as Map<String, dynamic>;
  }

  Future<BlogModel> getBlog(String id) async {
    final res = await _dio.get('/blogs/$id');
    return BlogModel.fromJson(res.data['blog']);
  }

  Future<BlogModel> createBlog(Map<String, dynamic> payload) async {
    final res = await _dio.post('/blogs', data: payload);
    return BlogModel.fromJson(res.data['blog']);
  }

  Future<BlogModel> updateBlog(String id, Map<String, dynamic> payload) async {
    final res = await _dio.put('/blogs/$id', data: payload);
    return BlogModel.fromJson(res.data['blog']);
  }

  Future<void> deleteBlog(String id) async {
    await _dio.delete('/blogs/$id');
  }

  // ── Likes ──────────────────────────────────────────────────

  Future<Map<String, dynamic>> toggleLike(String blogId) async {
    final res = await _dio.post('/blogs/$blogId/like');
    return res.data as Map<String, dynamic>;
  }

  Future<bool> getLikeStatus(String blogId) async {
    final res = await _dio.get('/blogs/$blogId/like-status');
    return res.data['liked'] as bool;
  }

  // ── Comments ───────────────────────────────────────────────

  Future<List<CommentModel>> getComments(String blogId) async {
    final res = await _dio.get('/blogs/$blogId/comments');
    final list = res.data['comments'] as List;
    return list.map((e) => CommentModel.fromJson(e)).toList();
  }

  Future<CommentModel> postComment(String blogId, String text) async {
    final res = await _dio.post('/blogs/$blogId/comments', data: {'text': text});
    return CommentModel.fromJson(res.data['comment']);
  }

  Future<void> deleteComment(String commentId) async {
    await _dio.delete('/comments/$commentId');
  }

  // ── Image Upload ────────────────────────────────────────────
  //
  // Works on both mobile (File path) and web (bytes).
  // The backend returns a full URL like:
  //   http://your-server:8000/uploads/1234567890-abc.jpg
  //
  // Usage (mobile):
  //   final url = await blogService.uploadImage(filePath, 'photo.jpg');
  //
  // Usage (web):
  //   final url = await blogService.uploadImage(filePath, 'photo.jpg', bytes: fileBytes);

  Future<String> uploadImage(
    String filePath,
    String fileName, {
    Uint8List? bytes,
  }) async {
    late FormData formData;

    if (bytes != null) {
      // Web — use bytes directly
      formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
          contentType: DioMediaType('image', _ext(fileName)),
        ),
      });
    } else {
      // Mobile — use file path
      formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
          contentType: DioMediaType('image', _ext(fileName)),
        ),
      });
    }

    final res = await _dio.post('/upload', data: formData);

    final url = res.data['url'] as String?;
    if (url == null || url.isEmpty) {
      throw Exception('Upload succeeded but server returned no URL');
    }
    return url;
  }

  String _ext(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    const map = {
      'jpg': 'jpeg', 'jpeg': 'jpeg',
      'png': 'png',  'gif': 'gif',
      'webp': 'webp',
    };
    return map[ext] ?? 'jpeg';
  }
}