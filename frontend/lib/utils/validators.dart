class Validators {
  /// Validates an email address.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validates a password (min 6 characters).
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Validates a display name.
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  /// Validates a blog title.
  static String? blogTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required';
    }
    if (value.trim().length < 5) {
      return 'Title must be at least 5 characters';
    }
    return null;
  }

  /// Validates blog content.
  static String? blogContent(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Content is required';
    }
    if (value.trim().length < 20) {
      return 'Content is too short';
    }
    return null;
  }

  /// Validates a URL (optional field — null is allowed).
  static String? optionalUrl(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final urlRegex = RegExp(r'^https?://');
    if (!urlRegex.hasMatch(value.trim())) {
      return 'Enter a valid URL starting with http:// or https://';
    }
    return null;
  }
}
