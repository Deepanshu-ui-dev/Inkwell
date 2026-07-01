import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:blog_app/models/blog_model.dart';
import 'package:blog_app/utils/app_theme.dart';
import 'package:blog_app/widgets/tag_chip.dart';
import 'package:blog_app/widgets/like_button.dart';
import 'package:timeago/timeago.dart' as timeago;

class BlogCard extends StatefulWidget {
  final BlogModel blog;
  final bool isLiked;
  final VoidCallback onTap;
  final VoidCallback onLikeTap;

  const BlogCard({
    super.key,
    required this.blog,
    required this.isLiked,
    required this.onTap,
    required this.onLikeTap,
  });

  @override
  State<BlogCard> createState() => _BlogCardState();
}

class _BlogCardState extends State<BlogCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.typography;
    final authorName = widget.blog.author?.name ?? 'Deepanshu kaushik';
    final hasImage = widget.blog.coverImageUrl != null &&
        widget.blog.coverImageUrl!.isNotEmpty;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.983 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: c.surfaceCard,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: c.border, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: c.ink.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Left: content ──────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.blog.tags.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TagChip(tag: widget.blog.tags.first),
                        ),
                      Text(
                        widget.blog.title,
                        style: t.titleLarge.copyWith(fontSize: 15, height: 1.35),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _excerpt(widget.blog.content),
                        style: t.bodyMedium.copyWith(fontSize: 13, height: 1.5),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),

                      // Meta row
                      Row(children: [
                        // Author avatar
                        Container(
                          width: 22, height: 22,
                          decoration: BoxDecoration(
                            color: c.accent,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            authorName.isNotEmpty
                                ? authorName[0].toUpperCase() : 'A',
                            style: TextStyle(
                                color: c.accentDeep,
                                fontSize: 9,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            '${authorName.split(' ').first} · ${timeago.format(widget.blog.createdAt)}',
                            style: t.bodySmall.copyWith(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        LikeButton(
                          isLiked: widget.isLiked,
                          likeCount: widget.blog.likesCount,
                          isCompact: true,
                          onTap: widget.onLikeTap,
                        ),
                      ]),
                    ],
                  ),
                ),

                // ── Right: thumbnail (96×96, up from 82×82) ──────────
                const SizedBox(width: 14),
                if (hasImage)
                  Hero(
                    tag: 'blog-cover-${widget.blog.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: CachedNetworkImage(
                        imageUrl: widget.blog.coverImageUrl!,
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          width: 96, height: 96,
                          decoration: BoxDecoration(
                            color: c.surface,
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        errorWidget: (_, __, ___) => _NoImageBox(c: c, size: 96),
                      ),
                    ),
                  )
                else
                  _NoImageBox(c: c, size: 96),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _excerpt(String content) {
    final s = content
        .replaceAll(RegExp(r'#+\s'), '')
        .replaceAll(RegExp(r'\*+'), '')
        .replaceAll(RegExp(r'_+'), '')
        .replaceAll(RegExp(r'\n+'), ' ')
        .trim();
    return s.length > 110 ? '${s.substring(0, 110)}…' : s;
  }
}

// ── No-image placeholder ──────────────────────────────────────────────────────
class _NoImageBox extends StatelessWidget {
  final AppColorsExtension c;
  final double size;
  const _NoImageBox({required this.c, required this.size});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          c.accentDeep.withValues(alpha: 0.85),
          c.heroBg,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(14),
    ),
    alignment: Alignment.center,
    child: Icon(Icons.edit_note_rounded,
        size: 30, color: c.accent.withValues(alpha: 0.45)),
  );
}

// ── Blog Card Skeleton ────────────────────────────────────────────────────────
class BlogCardSkeleton extends StatefulWidget {
  const BlogCardSkeleton({super.key});

  @override
  State<BlogCardSkeleton> createState() => _BlogCardSkeletonState();
}

class _BlogCardSkeletonState extends State<BlogCardSkeleton>
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
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surfaceCard,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: c.border, width: 1.2),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _bar(c, 60, 18, _anim.value),
              const SizedBox(height: 10),
              _bar(c, double.infinity, 14, _anim.value),
              const SizedBox(height: 6),
              _bar(c, double.infinity, 14, _anim.value * 0.9),
              const SizedBox(height: 6),
              _bar(c, 150, 14, _anim.value * 0.8),
              const SizedBox(height: 14),
              _bar(c, 120, 12, _anim.value * 0.7),
            ]),
          ),
          const SizedBox(width: 14),
          _square(c, 96, _anim.value),
        ]),
      ),
    );
  }

  Widget _bar(AppColorsExtension c, double w, double h, double alpha) =>
      Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: c.shimmerBase.withValues(alpha: alpha),
          borderRadius: BorderRadius.circular(6),
        ),
      );

  Widget _square(AppColorsExtension c, double size, double alpha) =>
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: c.shimmerBase.withValues(alpha: alpha),
          borderRadius: BorderRadius.circular(14),
        ),
      );
}