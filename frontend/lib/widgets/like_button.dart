import 'package:flutter/material.dart';
import 'package:blog_app/utils/app_theme.dart';

class LikeButton extends StatefulWidget {
  final bool isLiked;
  final int likeCount;
  final VoidCallback? onTap;
  final bool isCompact;
  final bool requiresLogin;

  const LikeButton({
    super.key, required this.isLiked, required this.likeCount,
    this.onTap, this.isCompact = false, this.requiresLogin = false,
  });

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _tap() { _ctrl.forward(from: 0); widget.onTap?.call(); }

  @override
  Widget build(BuildContext context) {
    final color = widget.isLiked ? context.colors.error : context.colors.inkMuted;

    if (widget.isCompact) {
      return GestureDetector(
        onTap: _tap,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          ScaleTransition(scale: _scale, child: Icon(
            widget.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: color, size: 15)),
          SizedBox(width: 4),
          Text(widget.likeCount.toString(),
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      );
    }

    return GestureDetector(
      onTap: _tap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: widget.isLiked ? context.colors.error.withValues(alpha: 0.08) : context.colors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.isLiked ? context.colors.error.withValues(alpha: 0.3) : context.colors.border,
            width: 1,
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          ScaleTransition(scale: _scale, child: Icon(
            widget.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: color, size: 18)),
          SizedBox(width: 6),
          Text(widget.likeCount.toString(),
              style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

void showLoginToLikeSheet(BuildContext context, {required VoidCallback onLoginTap}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: context.colors.surfaceCard,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (_) => Padding(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 44),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 36, height: 4, margin: EdgeInsets.only(bottom: 28),
            decoration: BoxDecoration(color: context.colors.border, borderRadius: BorderRadius.circular(2))),
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
              color: context.colors.error.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(18)),
          child: Icon(Icons.favorite_rounded, color: context.colors.error, size: 26),
        ),
        SizedBox(height: 18),
        Text('Like this story?', style: context.typography.titleLarge),
        SizedBox(height: 8),
        Text('Sign in to react and join the conversation.',
            style: context.typography.bodyMedium, textAlign: TextAlign.center),
        SizedBox(height: 26),
        SizedBox(width: double.infinity,
            child: ElevatedButton(
              onPressed: () { Navigator.pop(context); onLoginTap(); },
              child: Text('Sign in'),
            )),
        SizedBox(height: 8),
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Maybe later')),
      ]),
    ),
  );
}