import 'package:flutter/material.dart';
import 'package:blog_app/models/blog_model.dart';
import 'package:blog_app/services/blog_service.dart';

class BlogProvider extends ChangeNotifier {
  final BlogService blogService; // ← public so editor can access uploadImage

  BlogProvider({required this.blogService});

  List<BlogModel> _blogs = [];
  BlogModel? _selectedBlog;
  bool _isLoading = false;
  bool _isLoadingDetail = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;

  List<BlogModel> get blogs         => _blogs;
  BlogModel?      get selectedBlog  => _selectedBlog;
  bool            get isLoading     => _isLoading;
  bool            get isLoadingDetail => _isLoadingDetail;
  bool            get isLoadingMore => _isLoadingMore;
  String?         get errorMessage  => _errorMessage;

  // ── Fetch list ─────────────────────────────────────────────

  Future<void> fetchBlogs({bool refresh = false}) async {
    if (_isLoading) return;
    if (refresh) { _currentPage = 1; _hasMore = true; _blogs = []; }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await blogService.getBlogs(page: _currentPage);
      final fetched = (data['blogs'] as List)
          .map((e) => BlogModel.fromJson(e))
          .toList();
      _blogs = refresh ? fetched : [..._blogs, ...fetched];
      _hasMore = fetched.length >= 10;
      _currentPage++;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMoreBlogs() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    notifyListeners();

    try {
      final data = await blogService.getBlogs(page: _currentPage);
      final fetched = (data['blogs'] as List)
          .map((e) => BlogModel.fromJson(e))
          .toList();
      _blogs = [..._blogs, ...fetched];
      _hasMore = fetched.length >= 10;
      _currentPage++;
    } catch (_) {}

    _isLoadingMore = false;
    notifyListeners();
  }

  // ── Fetch single ───────────────────────────────────────────

  Future<void> fetchBlog(String id) async {
    _isLoadingDetail = true;
    _selectedBlog = null;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedBlog = await blogService.getBlog(id);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  // ── Create ─────────────────────────────────────────────────

  Future<BlogModel?> createBlog(Map<String, dynamic> payload) async {
    try {
      final blog = await blogService.createBlog(payload);
      _blogs = [blog, ..._blogs];
      notifyListeners();
      return blog;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  // ── Update ─────────────────────────────────────────────────

  Future<BlogModel?> updateBlog(String id, Map<String, dynamic> payload) async {
    try {
      final updated = await blogService.updateBlog(id, payload);

      // Refresh list entry
      _blogs = _blogs.map((b) => b.id == id ? updated : b).toList();

      // Refresh detail if open
      if (_selectedBlog?.id == id) _selectedBlog = updated;

      notifyListeners();
      return updated;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  // ── Delete ─────────────────────────────────────────────────

  Future<bool> deleteBlog(String id) async {
    try {
      await blogService.deleteBlog(id);
      _blogs = _blogs.where((b) => b.id != id).toList();
      if (_selectedBlog?.id == id) _selectedBlog = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ── Like ───────────────────────────────────────────────────

  Future<void> toggleLike(String blogId, String userId) async {
    // Optimistic update
    _blogs = _blogs.map((b) {
      if (b.id != blogId) return b;
      final liked = b.likedBy.contains(userId);
      final newLikedBy = liked
          ? b.likedBy.where((id) => id != userId).toList()
          : [...b.likedBy, userId];
      return b.copyWith(
        likedBy: newLikedBy,
        likesCount: newLikedBy.length,
      );
    }).toList();

    if (_selectedBlog?.id == blogId) {
      final b = _selectedBlog!;
      final liked = b.likedBy.contains(userId);
      final newLikedBy = liked
          ? b.likedBy.where((id) => id != userId).toList()
          : [...b.likedBy, userId];
      _selectedBlog = b.copyWith(
        likedBy: newLikedBy,
        likesCount: newLikedBy.length,
      );
    }
    notifyListeners();

    try {
      await blogService.toggleLike(blogId);
    } catch (_) {
      // Revert on failure — re-fetch
      fetchBlog(blogId);
    }
  }
}