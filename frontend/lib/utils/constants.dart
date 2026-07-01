// App-wide constants

class AppConstants {
  // Base URL — use 127.0.0.1 for Linux desktop (10.0.2.2 is only for Android emulator)
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Secure storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'auth_user';

  // Named routes
  static const String routeBlogList = '/';
  static const String routeBlogDetail = '/blog/detail';
  static const String routeBlogEditor = '/blog/editor';
  static const String routeLogin = '/login';
  static const String routeSignup = '/signup';
  static const String routeProfile = '/profile';

  // Pagination
  static const int pageSize = 10;
}

class AppBreakpoints {
  static const double mobile = 600.0;
  static const double tablet = 900.0;
  static const double desktop = 1200.0;
}

class AppSpacing {
  static const double s = 8.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}
