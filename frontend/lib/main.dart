import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:blog_app/providers/auth_provider.dart';
import 'package:blog_app/providers/blog_provider.dart';
import 'package:blog_app/providers/theme_provider.dart';
import 'package:blog_app/services/api_service.dart';
import 'package:blog_app/services/auth_service.dart';
import 'package:blog_app/services/blog_service.dart';
import 'package:blog_app/services/storage_service.dart';
import 'package:blog_app/services/version_service.dart';
import 'package:blog_app/utils/app_theme.dart';
import 'package:blog_app/utils/constants.dart';
import 'package:blog_app/screens/auth/login_screen.dart';
import 'package:blog_app/screens/auth/signup_screen.dart';
import 'package:blog_app/screens/blogs/blog_list_screen.dart';
import 'package:blog_app/screens/blogs/blog_detail_screen.dart';
import 'package:blog_app/screens/blogs/blog_editor_screen.dart';
import 'package:blog_app/screens/profile/profile_screen.dart';
import 'package:blog_app/models/blog_model.dart';
import 'package:blog_app/widgets/update_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
  ));

  final storageService = StorageService();
  ApiService.instance.init(storageService);

  final authService = AuthService();
  final blogService = BlogService();

  final authProvider = AuthProvider(
    authService: authService,
    storageService: storageService,
  );
  await authProvider.tryAutoLogin();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<BlogProvider>(
          create: (_) => BlogProvider(blogService: blogService),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: const BlogApp(),
    ),
  );
}

class _AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
  };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
}

class BlogApp extends StatefulWidget {
  const BlogApp({super.key});

  @override
  State<BlogApp> createState() => _BlogAppState();
}

class _BlogAppState extends State<BlogApp> {
  final _versionService = VersionService();
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVersion());
  }

  Future<void> _checkVersion() async {
    final info = await _versionService.checkVersion();
    if (info == null) return;
    if (!mounted) return;

    final ctx = _navigatorKey.currentContext;
    if (ctx == null) return;

    if (_versionService.requiresForceUpgrade(info)) {
      await showUpdateDialog(ctx, info: info, forceUpgrade: true);
    } else if (_versionService.hasSoftUpdate(info)) {
      await showUpdateDialog(ctx, info: info, forceUpgrade: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF4F0E6),
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    return MaterialApp(
      title: 'Inkwell',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      navigatorKey: _navigatorKey,
      scrollBehavior: _AppScrollBehavior(),
      initialRoute: AppConstants.routeBlogList,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppConstants.routeBlogList:
            return _fadeRoute(const BlogListScreen(), settings);
          case AppConstants.routeLogin:
            return _slideRoute(const LoginScreen(), settings);
          case AppConstants.routeSignup:
            return _slideRoute(const SignupScreen(), settings);
          case AppConstants.routeProfile:
            return _slideRoute(const ProfileScreen(), settings);
          case AppConstants.routeBlogDetail:
            final blogId = settings.arguments as String;
            return _fadeRoute(BlogDetailScreen(blogId: blogId), settings);
          case AppConstants.routeBlogEditor:
            final blog = settings.arguments as BlogModel?;
            return _slideRoute(BlogEditorScreen(blog: blog), settings);
          default:
            return _fadeRoute(const BlogListScreen(), settings);
        }
      },
    );
  }

  PageRoute _fadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 260),
    );
  }

  PageRoute _slideRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}