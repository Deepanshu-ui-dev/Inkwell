import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:blog_app/models/blog_model.dart';
import 'package:blog_app/providers/auth_provider.dart';
import 'package:blog_app/providers/blog_provider.dart';
import 'package:blog_app/providers/theme_provider.dart';
import 'package:blog_app/services/api_service.dart';
import 'package:blog_app/utils/app_theme.dart';
import 'package:blog_app/utils/constants.dart';
import 'package:blog_app/widgets/blog_card.dart';
import 'package:blog_app/widgets/like_button.dart';
import 'package:blog_app/widgets/app_snackbar.dart';
import 'package:blog_app/widgets/global_background.dart';
import 'package:blog_app/widgets/loading_indicator.dart';
import 'package:blog_app/widgets/responsive_wrapper.dart';
import 'package:blog_app/widgets/tag_chip.dart';
import 'package:blog_app/widgets/app_footer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:timeago/timeago.dart' as timeago;

class BlogListScreen extends StatefulWidget {
  const BlogListScreen({super.key});
  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  final _scrollController = ScrollController();
  bool _serverWarming = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _warmUpAndFetch();
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 250) {
        context.read<BlogProvider>().fetchMoreBlogs();
      }
    });
  }

  /// Ping the health endpoint first. If it's slow (Render cold start),
  /// show a "warming up" banner so users know the server is waking.
  Future<void> _warmUpAndFetch() async {
    final bp = context.read<BlogProvider>();
    try {
      final ping = await ApiService.instance.dio
          .get('/health')
          .timeout(const Duration(seconds: 5));
      if (ping.statusCode == 200) {
        // Server is live — fetch immediately
        bp.fetchBlogs();
        return;
      }
    } catch (_) {
      // Server is cold or health failed — show banner, still attempt fetch
      if (mounted) setState(() => _serverWarming = true);
    }
    // Attempt main fetch regardless
    bp.fetchBlogs().then((_) {
      if (mounted) setState(() => _serverWarming = false);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleLike(BuildContext ctx, BlogModel blog) {
    final auth = ctx.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      showLoginToLikeSheet(ctx,
          onLoginTap: () => Navigator.pushNamed(ctx, AppConstants.routeLogin));
      return;
    }
    ctx.read<BlogProvider>().toggleLike(blog.id, auth.currentUser!.id);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final bp = context.watch<BlogProvider>();
    final userId = auth.currentUser?.id ?? '';
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: GlobalBackground(
          child: ResponsiveWrapper(
            maxWidth: 1200,
        addPadding: true,
        child: LiquidPullToRefresh(
          onRefresh: () => context.read<BlogProvider>().fetchBlogs(refresh: true),
          color: c.surfaceCard,
          backgroundColor: c.accent,
          height: 100,
          animSpeedFactor: 2,
          showChildOpacityTransition: false,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _HeroHeader(auth: auth)),

              // Server warm-up banner
              if (_serverWarming)
                SliverToBoxAdapter(
                  child: _WarmUpBanner(c: c),
                ),

              if (bp.isLoading && bp.blogs.isEmpty)
                _skeletons()
              else if (bp.errorMessage != null && bp.blogs.isEmpty)
                _error(context, bp)
              else if (bp.blogs.isEmpty)
                _empty(context)
              else
                _feed(context, bp, userId),

              SliverFillRemaining(
                hasScrollBody: false,
                fillOverscroll: true,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 48.0),
                    child: const AppFooter(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
      ),
      floatingActionButton: auth.isAuthor
          ? _WriteFAB(onTap: () =>
              Navigator.pushNamed(context, AppConstants.routeBlogEditor))
          : null,
    );
  }

  Widget _skeletons() => SliverPadding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
    sliver: SliverList(delegate: SliverChildBuilderDelegate(
      (_, i) => const Padding(
          padding: EdgeInsets.only(bottom: 12), child: BlogCardSkeleton()),
      childCount: 5,
    )),
  );

  Widget _error(BuildContext context, BlogProvider p) {
    final c = context.colors;
    final t = context.typography;
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: c.border),
            ),
            child: Icon(Icons.cloud_off_rounded, color: c.inkMuted, size: 32),
          ),
          const SizedBox(height: 18),
          Text('Couldn\'t load articles', style: t.titleLarge),
          const SizedBox(height: 8),
          Text(p.errorMessage!, style: t.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: () => context.read<BlogProvider>().fetchBlogs(refresh: true),
            child: const Text('Try again'),
          ),
        ]),
      )),
    );
  }

  Widget _empty(BuildContext context) {
    final c = context.colors;
    final t = context.typography;
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 88, height: 88,
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: c.border),
          ),
          child: Icon(Icons.auto_stories_outlined, color: c.inkMuted, size: 40),
        ),
        const SizedBox(height: 16),
        Text('Nothing published yet', style: t.titleMedium),
        const SizedBox(height: 6),
        Text('Be the first to share something.', style: t.bodyMedium),
      ])),
    );
  }

  Widget _feed(BuildContext context, BlogProvider p, String userId) {
    final blogs = p.blogs;
    final featured = blogs.first;
    final rest = blogs.skip(1).toList();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _FeaturedCard(
            blog: featured,
            isLiked: featured.likedBy.contains(userId),
            onTap: () => Navigator.pushNamed(
              context, AppConstants.routeBlogDetail, arguments: featured.id),
            onLikeTap: () => _handleLike(context, featured),
          ).animate().fade(duration: 350.ms).slideY(begin: 0.05),

          if (rest.isNotEmpty) ...[
            const SizedBox(height: 32),
            _SectionHeader(label: 'ALL ARTICLES'),
            const SizedBox(height: 14),

            ResponsiveGrid(
              spacing: 24,
              runSpacing: 24,
              children: rest.asMap().entries.map((e) => BlogCard(
                key: Key('blog_card_${e.value.id}'),
                blog: e.value,
                isLiked: e.value.likedBy.contains(userId),
                onTap: () => Navigator.pushNamed(
                  context, AppConstants.routeBlogDetail, arguments: e.value.id),
                onLikeTap: () => _handleLike(context, e.value),
              ).animate(delay: (e.key * 60).ms).fade(duration: 280.ms).slideY(begin: 0.04)).toList(),
            ),
          ],

          if (p.isLoadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(child: LoadingIndicator()),
            ),
        ]),
      ),
    );
  }
}

// ── Warm-up Banner ────────────────────────────────────────────────────────────
class _WarmUpBanner extends StatelessWidget {
  final AppColorsExtension c;
  const _WarmUpBanner({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: c.accentDeep.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.accent.withValues(alpha: 0.25)),
      ),
      child: Row(children: [
        SizedBox(
          width: 16, height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: c.accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Server is warming up — articles will appear in a moment…',
            style: context.typography.bodySmall.copyWith(
              color: c.inkSecondary,
              fontSize: 12,
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.typography;
    return Row(children: [
      Container(
        width: 3, height: 16,
        decoration: BoxDecoration(
          color: c.accent,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 10),
      Text(label, style: t.caption.copyWith(letterSpacing: 1.5)),
      const SizedBox(width: 14),
      Expanded(child: Container(height: 1, color: c.border)),
    ]);
  }
}

// ── Hero Header ──────────────────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  final AuthProvider auth;
  const _HeroHeader({required this.auth});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.typography;
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      decoration: BoxDecoration(
        color: c.heroBg,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(children: [
        // Fine grid background — isolated so it never repaints
        Positioned.fill(
          child: RepaintBoundary(child: CustomPaint(painter: _GridPainter())),
        ),

        // Glow orbs
        Positioned(top: -60, right: -30, child: _Orb(size: 220, color: c.accent, alpha: 0.07)),
        Positioned(bottom: -40, left: -10, child: _Orb(size: 160, color: c.accentWarm, alpha: 0.08)),

        // Noise overlay — also isolated
        Positioned.fill(
          child: RepaintBoundary(child: CustomPaint(painter: _NoisePainter())),
        ),

        Padding(
          // Reduced vertical padding to compress the header height
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Nav bar ──────────────────────────────────────────
              Row(children: [
                const SizedBox(width: 4),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Inkwell', style: t.titleLarge.copyWith(
                      color: c.inkOnDark, letterSpacing: -0.3)),
                  Text('thoughtful writing', style: t.caption.copyWith(
                      color: c.inkOnDark.withValues(alpha: 0.4), fontSize: 9)),
                ]),
                const Spacer(),

                // Theme toggle
                _ThemeToggle(themeProvider: themeProvider, inkOnDark: c.inkOnDark),
                const SizedBox(width: 10),

                // Profile / Sign in
                if (auth.isLoggedIn)
                  GestureDetector(
                    key: const Key('profile_icon_button'),
                    onTap: () => Navigator.pushNamed(
                        context, AppConstants.routeProfile),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [c.accent.withValues(alpha: 0.9), c.accent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: c.inkOnDark.withValues(alpha: 0.15), width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        auth.currentUser!.name.isNotEmpty
                            ? auth.currentUser!.name[0].toUpperCase() : 'U',
                        style: TextStyle(
                            color: c.accentDeep, fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    key: const Key('signin_nav_button'),
                    onTap: () => Navigator.pushNamed(context, AppConstants.routeLogin),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        border: Border.all(color: c.inkOnDark.withValues(alpha: 0.25), width: 1),
                        borderRadius: BorderRadius.circular(20),
                        color: c.inkOnDark.withValues(alpha: 0.06),
                      ),
                      child: Text('Sign in',
                          style: t.labelLarge.copyWith(color: c.inkOnDark, fontSize: 13)),
                    ),
                  ),
              ]).animate().fade(duration: 300.ms),

              const SizedBox(height: 32),

              // Eyebrow pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: c.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: c.accent.withValues(alpha: 0.3), width: 1),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 6, height: 6,
                    decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 7),
                  Text('INDEPENDENT PUBLISHING',
                      style: t.caption.copyWith(color: c.accent, letterSpacing: 1.2, fontSize: 9)),
                ]),
              ).animate().fade(duration: 350.ms, delay: 50.ms),

              const SizedBox(height: 14),

              // Compressed headline (was 52px, now 38px)
              Text('Ideas worth\nkeeping.', style: t.hero.copyWith(fontSize: 38, height: 1.0))
                  .animate().fade(duration: 400.ms, delay: 80.ms).slideY(begin: 0.05),

              const SizedBox(height: 12),

              Text('Curated writing on design, tech, and the things that matter.',
                  style: t.heroSub.copyWith(fontSize: 14))
                  .animate().fade(duration: 350.ms, delay: 120.ms),

              const SizedBox(height: 22),

              // CTA row
              Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppConstants.routeLogin),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                    decoration: BoxDecoration(
                      color: c.accent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text('Start reading',
                        style: t.labelLarge.copyWith(color: c.accentDeep, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 14),
                Row(children: [
                  Icon(Icons.arrow_downward_rounded, size: 13, color: c.inkOnDark.withValues(alpha: 0.5)),
                  const SizedBox(width: 6),
                  Text('Scroll to explore',
                      style: t.bodySmall.copyWith(color: c.inkOnDark.withValues(alpha: 0.5), fontSize: 12)),
                ]),
              ]).animate().fade(duration: 350.ms, delay: 150.ms),
            ]),
          ),
      ]),
    );
  }
}

// ── Theme Toggle ──────────────────────────────────────────────────────────────
class _ThemeToggle extends StatelessWidget {
  final ThemeProvider themeProvider;
  final Color inkOnDark;
  const _ThemeToggle({required this.themeProvider, required this.inkOnDark});

  @override
  Widget build(BuildContext context) {
    final isDark = themeProvider.isDarkMode;
    return GestureDetector(
      onTap: () => themeProvider.toggleTheme(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        width: 54,
        height: 30,
        decoration: BoxDecoration(
          color: isDark
              ? inkOnDark.withValues(alpha: 0.15)
              : const Color(0xFF2C2C2C).withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: inkOnDark.withValues(alpha: 0.1), width: 1),
        ),
        child: Stack(children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  color: isDark ? inkOnDark : const Color(0xFFF4F0E6),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4, offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                  size: 13,
                  color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFD4A017),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  final double size;
  final Color color;
  final double alpha;
  const _Orb({required this.size, required this.color, required this.alpha});

  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [color.withValues(alpha: alpha), color.withValues(alpha: 0)],
      ),
    ),
  );
}

// ── Grid Painter ──────────────────────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.0, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Noise Painter ─────────────────────────────────────────────────────────────
class _NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    final p = Paint()..color = Colors.white.withValues(alpha: 0.015);
    for (int i = 0; i < 400; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      canvas.drawRect(Rect.fromLTWH(x, y, 1.5, 1.5), p);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Featured Card ────────────────────────────────────────────────────────────
class _FeaturedCard extends StatelessWidget {
  final BlogModel blog;
  final bool isLiked;
  final VoidCallback onTap;
  final VoidCallback onLikeTap;
  const _FeaturedCard({
    required this.blog, required this.isLiked,
    required this.onTap, required this.onLikeTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.typography;
    final hasImage = blog.coverImageUrl != null && blog.coverImageUrl!.isNotEmpty;
    final authorName = blog.author?.name ?? 'Deepanshu kaushik';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: c.surfaceCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: c.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: c.ink.withValues(alpha: 0.05),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Cover image / accent strip with gradient overlay ──
          SizedBox(
            height: 220,
            width: double.infinity,
            child: Stack(fit: StackFit.expand, children: [
              if (hasImage)
                Hero(
                  tag: 'blog-cover-${blog.id}',
                  child: CachedNetworkImage(
                    imageUrl: blog.coverImageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: c.surface),
                    errorWidget: (_, __, ___) => _accentStrip(c),
                  ),
                )
              else
                _accentStrip(c),

              // Gradient overlay for legibility
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.4, 1.0],
                      colors: [
                        Colors.transparent,
                        c.ink.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                ),
              ),

              // Badge row floats over image
              Positioned(
                top: 14, left: 14,
                child: Row(children: [
                  _Badge(label: 'FEATURED', bg: c.accent, text: c.accentDeep),
                  const SizedBox(width: 8),
                  ...blog.tags.take(2).map((tag) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: TagChip(tag: tag),
                  )),
                ]),
              ),
            ]),
          ),

          // ── Content ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(blog.title,
                  style: t.displayMedium.copyWith(fontSize: 22, height: 1.2),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),

              Text(_excerpt(blog.content),
                  style: t.bodyMedium.copyWith(height: 1.65),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 16),

              // Author + actions row
              Row(children: [
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(
                    authorName.isNotEmpty ? authorName[0].toUpperCase() : 'A',
                    style: TextStyle(
                        color: c.accentDeep, fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(authorName, style: t.labelLarge.copyWith(fontSize: 12)),
                  Text('${timeago.format(blog.createdAt)} · ${_readTime(blog.content)} min read',
                      style: t.bodySmall),
                ])),
                LikeButton(isLiked: isLiked, likeCount: blog.likesCount,
                    isCompact: true, onTap: onLikeTap),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                      color: c.ink, borderRadius: BorderRadius.circular(22)),
                  child: Text('Read →',
                      style: t.bodySmall.copyWith(
                          color: c.accent, fontWeight: FontWeight.w700, fontSize: 12)),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _accentStrip(AppColorsExtension c) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [c.accentDeep, c.heroBg],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Stack(children: [
      Positioned(right: -20, bottom: -30, child: Container(
        width: 150, height: 150,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: c.accent.withValues(alpha: 0.1)),
      )),
      Positioned(left: 20, top: 20, child: Icon(
          Icons.edit_note_rounded, size: 52,
          color: c.accent.withValues(alpha: 0.2))),
    ]),
  );

  String _excerpt(String c) {
    final s = c.replaceAll(RegExp(r'#+\s'), '').replaceAll(RegExp(r'\*+'), '')
        .replaceAll(RegExp(r'_+'), '').replaceAll(RegExp(r'\n+'), ' ').trim();
    return s.length > 160 ? '${s.substring(0, 160)}…' : s;
  }

  int _readTime(String c) =>
      (c.split(RegExp(r'\s+')).length / 200).ceil().clamp(1, 99);
}

class _Badge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color text;
  const _Badge({required this.label, required this.bg, required this.text});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: bg, borderRadius: BorderRadius.circular(6),
    ),
    child: Text(label,
        style: context.typography.caption.copyWith(color: text, fontSize: 9)),
  );
}

// ── Write FAB ────────────────────────────────────────────────────────────────
class _WriteFAB extends StatelessWidget {
  final VoidCallback onTap;
  const _WriteFAB({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.typography;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          color: c.ink,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [BoxShadow(
              color: c.ink.withValues(alpha: 0.35),
              blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.edit_outlined, size: 16, color: c.accent),
          const SizedBox(width: 8),
          Text('Write', style: t.labelLarge.copyWith(color: c.accent)),
        ]),
      ),
    );
  }
}