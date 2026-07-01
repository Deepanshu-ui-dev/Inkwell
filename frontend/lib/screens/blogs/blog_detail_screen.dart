import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:blog_app/models/blog_model.dart';
import 'package:blog_app/models/comment_model.dart';
import 'package:blog_app/providers/auth_provider.dart';
import 'package:blog_app/providers/blog_provider.dart';
import 'package:blog_app/services/blog_service.dart';
import 'package:blog_app/utils/app_theme.dart';
import 'package:blog_app/utils/constants.dart';
import 'package:blog_app/widgets/comment_tile.dart';
import 'package:blog_app/widgets/like_button.dart';
import 'package:blog_app/widgets/loading_indicator.dart';
import 'package:blog_app/widgets/tag_chip.dart';
import 'package:blog_app/widgets/app_snackbar.dart';
import 'package:blog_app/widgets/global_background.dart';
import 'package:blog_app/widgets/responsive_wrapper.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:timeago/timeago.dart' as timeago;

class BlogDetailScreen extends StatefulWidget {
  final String blogId;
  const BlogDetailScreen({super.key, required this.blogId});
  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();
  final _blogService = BlogService();
  List<CommentModel> _comments = [];
  bool _loadingComments = false;
  bool _postingComment = false;

  // ── ValueNotifiers replace setState so only the affected widgets rebuild ──
  final _progressNotifier = ValueNotifier<double>(0);
  final _stickyTitleNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BlogProvider>().fetchBlog(widget.blogId);
      _loadComments();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final max = _scrollController.hasClients
        ? _scrollController.position.maxScrollExtent
        : 0.0;

    // Update sticky title
    final shouldShow = offset > 200;
    if (shouldShow != _stickyTitleNotifier.value) {
      _stickyTitleNotifier.value = shouldShow;
    }

    // Update reading progress
    if (max > 0) {
      _progressNotifier.value = (offset / max).clamp(0.0, 1.0);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _progressNotifier.dispose();
    _stickyTitleNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => _loadingComments = true);
    try {
      final c = await _blogService.getComments(widget.blogId);
      if (mounted) setState(() => _comments = c);
    } catch (_) {}
    if (mounted) setState(() => _loadingComments = false);
  }

  Future<void> _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    setState(() => _postingComment = true);
    try {
      final c = await _blogService.postComment(widget.blogId, text);
      if (!mounted) return;
      setState(() { _comments = [c, ..._comments]; _commentController.clear(); });
      final blog = context.read<BlogProvider>().selectedBlog;
      if (blog != null) context.read<BlogProvider>().updateBlog(
          widget.blogId, {'commentsCount': blog.commentsCount + 1});
    } catch (_) {
      if (mounted) AppSnackbar.show(context, message: 'Failed to post', isError: true);
    }
    if (mounted) setState(() => _postingComment = false);
  }

  Future<void> _deleteComment(String id) async {
    try {
      await _blogService.deleteComment(id);
      if (mounted) setState(() => _comments = _comments.where((c) => c.id != id).toList());
    } catch (_) {
      if (mounted) AppSnackbar.show(context, message: 'Failed to delete', isError: true);
    }
  }

  void _handleLike(BlogModel blog) {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      showLoginToLikeSheet(context,
          onLoginTap: () => Navigator.pushNamed(context, AppConstants.routeLogin));
      return;
    }
    context.read<BlogProvider>().toggleLike(blog.id, auth.currentUser!.id);
  }

  void _share(BlogModel blog) => Share.share(
    '${blog.title}\n${AppConstants.baseUrl.replaceAll('/api', '')}/blogs/${blog.id}',
    subject: blog.title,
  );

  Future<void> _confirmDelete(BlogModel blog) async {
    final c = context.colors;
    final t = context.typography;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete story?', style: t.titleLarge),
        content: Text('This cannot be undone.', style: t.bodyMedium),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete',
                style: TextStyle(color: c.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (!mounted || ok != true) return;
    final deleted = await context.read<BlogProvider>().deleteBlog(blog.id);
    if (!mounted) return;
    if (deleted) { AppSnackbar.show(context, message: 'Deleted'); Navigator.pop(context); }
    else AppSnackbar.show(context, message: 'Failed to delete', isError: true);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final blog = context.watch<BlogProvider>().selectedBlog;
    final c = context.colors;
    final t = context.typography;
    final userId = auth.currentUser?.id ?? '';

    if (context.watch<BlogProvider>().isLoadingDetail || blog == null) {
      return Scaffold(
        backgroundColor: c.background,
        body: const _BlogDetailSkeleton(),
      );
    }

    final isLiked = blog.likedBy.contains(userId);

    return Scaffold(
      backgroundColor: c.background,
      body: GlobalBackground(
        child: Stack(children: [
          ResponsiveWrapper(
          maxWidth: 820,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── App bar (uses ValueListenableBuilder for title opacity) ──
              SliverAppBar(
                expandedHeight: blog.coverImageUrl != null ? 260 : 0,
                pinned: true, floating: false,
                backgroundColor: c.background,
                elevation: 0, scrolledUnderElevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _Btn(icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.pop(context)),
                ),
                title: ValueListenableBuilder<bool>(
                  valueListenable: _stickyTitleNotifier,
                  builder: (_, show, __) => AnimatedOpacity(
                    opacity: show ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Text(blog.title, style: t.titleMedium,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ),
                actions: [
                  _Btn(key: const Key('share_blog_button'),
                      icon: Icons.ios_share_rounded, onTap: () => _share(blog)),
                  if (auth.isAuthor) ...[
                    const SizedBox(width: 6),
                    _Btn(key: const Key('edit_blog_button'),
                        icon: Icons.edit_outlined,
                        onTap: () => Navigator.pushNamed(
                            context, AppConstants.routeBlogEditor, arguments: blog)),
                    const SizedBox(width: 6),
                    _Btn(key: const Key('delete_blog_button'),
                        icon: Icons.delete_outline_rounded,
                        iconColor: c.error,
                        onTap: () => _confirmDelete(blog)),
                  ],
                  const SizedBox(width: 8),
                ],
                flexibleSpace: blog.coverImageUrl != null
                    ? FlexibleSpaceBar(
                        collapseMode: CollapseMode.parallax,
                        background: Hero(
                          tag: 'blog-cover-${blog.id}',
                          child: CachedNetworkImage(
                            imageUrl: blog.coverImageUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                Container(color: c.surface),
                          ),
                        ),
                      )
                    : null,
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (blog.tags.isNotEmpty) ...[
                        Wrap(spacing: 6, runSpacing: 6,
                            children: blog.tags.map((tag) => TagChip(tag: tag)).toList()),
                        const SizedBox(height: 14),
                      ],

                      Text(blog.title, style: t.displayLarge),
                      const SizedBox(height: 18),

                      // Byline stripe
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border(left: BorderSide(color: c.accent, width: 3)),
                        ),
                        child: Row(children: [
                          CircleAvatar(
                            radius: 16, backgroundColor: c.surfaceCard,
                            backgroundImage: blog.author?.avatarUrl != null
                                ? NetworkImage(blog.author!.avatarUrl!) : null,
                            child: blog.author?.avatarUrl == null
                                ? Text(
                                    blog.author?.name.isNotEmpty == true
                                        ? blog.author!.name[0].toUpperCase() : 'A',
                                    style: TextStyle(
                                        color: c.ink, fontSize: 12,
                                        fontWeight: FontWeight.w700))
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(blog.author?.name ?? 'Deepanshu kaushik', style: t.labelLarge),
                            Text(
                              '${timeago.format(blog.createdAt)} · ${_readTime(blog.content)} min read',
                              style: t.bodySmall,
                            ),
                          ]),
                        ]),
                      ),

                      const SizedBox(height: 28),
                      Container(height: 1, color: c.divider),
                      const SizedBox(height: 28),

                      MarkdownBody(
                        data: blog.content,
                        styleSheet: MarkdownStyleSheet(
                          h1: t.displayMedium,
                          h2: t.titleLarge.copyWith(fontSize: 20),
                          h3: t.titleLarge,
                          p: t.bodyLarge,
                          code: GoogleFonts.firaCode(
                              fontSize: 13, color: c.ink,
                              backgroundColor: c.surface),
                          codeblockDecoration: BoxDecoration(
                            color: c.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: c.border),
                          ),
                          blockquoteDecoration: BoxDecoration(
                            color: c.tagBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border(
                                left: BorderSide(color: c.accent, width: 4)),
                          ),
                          blockquotePadding:
                              const EdgeInsets.fromLTRB(16, 12, 16, 12),
                          listBullet: t.bodyLarge,
                          tableHead: t.labelLarge,
                          tableBody: t.bodyMedium.copyWith(color: c.ink),
                          tableBorder: TableBorder.all(color: c.border),
                          tableCellsPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        softLineBreak: true,
                      ),

                      const SizedBox(height: 32),
                      Container(height: 1, color: c.divider),
                      const SizedBox(height: 24),

                      // Comments header
                      Row(children: [
                        Text('Comments', style: t.titleLarge),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                              color: c.surface,
                              borderRadius: BorderRadius.circular(20)),
                          child: Text('${_comments.length}', style: t.bodySmall),
                        ),
                      ]),
                      const SizedBox(height: 16),

                      if (auth.isLoggedIn)
                        _CommentInput(
                            controller: _commentController,
                            isPosting: _postingComment,
                            onPost: _postComment)
                      else
                        _SignInToComment(onTap: () =>
                            Navigator.pushNamed(context, AppConstants.routeLogin)),

                      const SizedBox(height: 20),

                      if (_loadingComments)
                        const Center(child: LoadingIndicator())
                      else if (_comments.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text('No comments yet. Start the conversation.',
                              style: t.bodyMedium),
                        )
                      else
                        ..._comments.map((cm) {
                          final canDelete = auth.isAuthor ||
                              (auth.isLoggedIn &&
                                  auth.currentUser?.id == cm.viewer?.id);
                          return Column(children: [
                            CommentTile(key: Key('comment_${cm.id}'),
                                comment: cm,
                                onDelete: canDelete
                                    ? () => _deleteComment(cm.id) : null),
                            Container(height: 1, color: c.divider),
                          ]);
                        }),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Reading progress bar — only this widget repaints on scroll ──
        Positioned(
          top: 0, left: 0, right: 0,
          child: SafeArea(
            bottom: false,
            child: ValueListenableBuilder<double>(
              valueListenable: _progressNotifier,
              builder: (ctx, progress, __) => LayoutBuilder(
                builder: (ctx, constraints) => Stack(children: [
                  Container(height: 3, color: c.border.withValues(alpha: 0.4)),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 80),
                    height: 3,
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [c.accent, c.accentWarm]),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),

        // Floating action bar
        Positioned(
          left: 24, right: 24, bottom: 24,
          child: SafeArea(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: c.surfaceCard,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: c.border, width: 1),
                  boxShadow: [BoxShadow(
                      color: c.ink.withValues(alpha: 0.12),
                      blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  LikeButton(key: const Key('detail_like_button'),
                      isLiked: isLiked, likeCount: blog.likesCount,
                      onTap: () => _handleLike(blog)),
                  const SizedBox(width: 12),
                  Container(width: 1, height: 22, color: c.border),
                  const SizedBox(width: 12),
                  GestureDetector(
                    key: const Key('detail_share_button'),
                    onTap: () => _share(blog),
                    child: Icon(Icons.ios_share_rounded, size: 20, color: c.ink),
                  ),
                  const SizedBox(width: 12),
                  Container(width: 1, height: 22, color: c.border),
                  const SizedBox(width: 12),
                  Text('${_readTime(blog.content)} min read',
                      style: t.labelLarge.copyWith(fontSize: 12)),
                ]),
              ).animate().slideY(begin: 1.5, duration: 400.ms, curve: Curves.easeOutBack),
            ),
          ),
        ),
      ]),
      ),
    );
  }

  int _readTime(String c) =>
      (c.split(RegExp(r'\s+')).length / 200).ceil().clamp(1, 99);
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  const _Btn({super.key, required this.icon, required this.onTap, this.iconColor});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: c.surfaceCard, shape: BoxShape.circle,
          border: Border.all(color: c.border, width: 1),
        ),
        child: Icon(icon, size: 16, color: iconColor ?? c.ink),
      ),
    );
  }
}

class _CommentInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isPosting;
  final VoidCallback onPost;
  const _CommentInput(
      {required this.controller, required this.isPosting, required this.onPost});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.typography;
    return Container(
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border, width: 1),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(child: TextField(
          key: const Key('comment_input_field'),
          controller: controller,
          style: t.bodyMedium.copyWith(color: c.ink),
          maxLines: 4, minLines: 1,
          decoration: InputDecoration(
            hintText: 'Share your thoughts…',
            hintStyle: t.bodyMedium,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          ),
        )),
        Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            key: const Key('post_comment_button'),
            onTap: isPosting ? null : onPost,
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: c.ink, shape: BoxShape.circle),
              child: isPosting
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: c.accent))
                  : Icon(Icons.arrow_upward_rounded, size: 17, color: c.accent),
            ),
          ),
        ),
      ]),
    );
  }
}

class _SignInToComment extends StatelessWidget {
  final VoidCallback onTap;
  const _SignInToComment({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.typography;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.border, width: 1),
        ),
        child: Row(children: [
          Text('Sign in to leave a comment…', style: t.bodyMedium),
          const Spacer(),
          Icon(Icons.arrow_forward_rounded, size: 16, color: c.inkMuted),
        ]),
      ),
    );
  }
}

class _BlogDetailSkeleton extends StatefulWidget {
  const _BlogDetailSkeleton();
  @override
  State<_BlogDetailSkeleton> createState() => _BlogDetailSkeletonState();
}

class _BlogDetailSkeletonState extends State<_BlogDetailSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SafeArea(
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bar(c, 80, 24, _anim.value),
              const SizedBox(height: 14),
              _bar(c, double.infinity, 38, _anim.value),
              const SizedBox(height: 8),
              _bar(c, 240, 38, _anim.value * 0.9),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: c.shimmerBase.withValues(alpha: _anim.value),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _bar(c, 100, 14, _anim.value * 0.8),
                      const SizedBox(height: 6),
                      _bar(c, 140, 12, _anim.value * 0.7),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _bar(c, double.infinity, 16, _anim.value),
              const SizedBox(height: 10),
              _bar(c, double.infinity, 16, _anim.value * 0.95),
              const SizedBox(height: 10),
              _bar(c, double.infinity, 16, _anim.value * 0.9),
              const SizedBox(height: 10),
              _bar(c, 200, 16, _anim.value * 0.85),
              const SizedBox(height: 24),
              _bar(c, double.infinity, 16, _anim.value * 0.8),
              const SizedBox(height: 10),
              _bar(c, double.infinity, 16, _anim.value * 0.75),
              const SizedBox(height: 10),
              _bar(c, 150, 16, _anim.value * 0.7),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bar(AppColorsExtension c, double w, double h, double alpha) =>
      Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: c.shimmerBase.withValues(alpha: alpha),
          borderRadius: BorderRadius.circular(8),
        ),
      );
}