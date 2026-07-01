import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:blog_app/models/blog_model.dart';
import 'package:blog_app/services/blog_service.dart';
import 'package:blog_app/utils/constants.dart';

class BlogProvider extends ChangeNotifier {
  final BlogService _blogService;

  BlogProvider({required BlogService blogService}) : _blogService = blogService;

  // ── State ──────────────────────────────────────────────────
  List<BlogModel> _blogs = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _errorMessage;

  // Single blog detail cache
  BlogModel? _selectedBlog;
  bool _isLoadingDetail = false;

  // ── Getters ────────────────────────────────────────────────
  BlogService get blogService => _blogService;
  List<BlogModel> get blogs => _blogs;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;
  BlogModel? get selectedBlog => _selectedBlog;
  bool get isLoadingDetail => _isLoadingDetail;

  // ── Fetch blogs (initial / refresh) ───────────────────────
  Future<void> fetchBlogs({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _blogs = [];
    }
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await _blogService.getBlogs(page: 1);
      _blogs = fetched;
      _currentPage = 1;
      _hasMore = fetched.length >= AppConstants.pageSize;
    } on DioException catch (e) {
      _errorMessage = _extractError(e);
    } catch (e) {
      _errorMessage = 'Failed to load blogs.';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load next page (pagination).
  Future<void> fetchMoreBlogs() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final fetched = await _blogService.getBlogs(page: nextPage);
      if (fetched.isEmpty) {
        _hasMore = false;
      } else {
        _blogs = [..._blogs, ...fetched];
        _currentPage = nextPage;
        if (fetched.length < AppConstants.pageSize) _hasMore = false;
      }
    } catch (_) {
      // Silently fail on pagination errors
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  // ── Single blog detail ─────────────────────────────────────
  Future<void> fetchBlog(String id) async {
    _isLoadingDetail = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedBlog = await _blogService.getBlog(id);
    } on DioException catch (e) {
      _errorMessage = _extractError(e);
    } catch (e) {
      _errorMessage = 'Failed to load blog.';
    }

    _isLoadingDetail = false;
    notifyListeners();
  }

  // ── Like toggle ────────────────────────────────────────────
  Future<void> toggleLike(String blogId, String userId) async {
    try {
      final result = await _blogService.toggleLike(blogId);

      // Update in list
      _blogs = _blogs.map((b) {
        if (b.id != blogId) return b;
        final newLikedBy = result.liked
            ? [...b.likedBy, userId]
            : b.likedBy.where((id) => id != userId).toList();
        return b.copyWith(likesCount: result.likesCount, likedBy: newLikedBy);
      }).toList();

      // Update selected blog if open
      if (_selectedBlog?.id == blogId) {
        final newLikedBy = result.liked
            ? [..._selectedBlog!.likedBy, userId]
            : _selectedBlog!.likedBy.where((id) => id != userId).toList();
        _selectedBlog = _selectedBlog!.copyWith(
          likesCount: result.likesCount,
          likedBy: newLikedBy,
        );
      }

      notifyListeners();
    } catch (_) {
      // Like errors are silent — UI reverts automatically since we didn't optimistically update
    }
  }

  // ── Blog mutations (Author) ────────────────────────────────
  Future<BlogModel?> createBlog(Map<String, dynamic> payload) async {
    try {
      final created = await _blogService.createBlog(payload);
      _blogs = [created, ..._blogs];
      notifyListeners();
      return created;
    } on DioException catch (e) {
      _errorMessage = _extractError(e);
      notifyListeners();
      return null;
    }
  }

  Future<BlogModel?> updateBlog(String id, Map<String, dynamic> payload) async {
    try {
      final updated = await _blogService.updateBlog(id, payload);
      _blogs = _blogs.map((b) => b.id == id ? updated : b).toList();
      if (_selectedBlog?.id == id) _selectedBlog = updated;
      notifyListeners();
      return updated;
    } on DioException catch (e) {
      _errorMessage = _extractError(e);
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteBlog(String id) async {
    try {
      await _blogService.deleteBlog(id);
      _blogs = _blogs.where((b) => b.id != id).toList();
      if (_selectedBlog?.id == id) _selectedBlog = null;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = _extractError(e);
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSelectedBlog() {
    _selectedBlog = null;
  }

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      return (data['message'] ?? data['error'] ?? 'Request failed').toString();
    }
    return e.message ?? 'Network error.';
  }
}
