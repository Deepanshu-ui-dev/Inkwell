import 'package:flutter/material.dart';
import 'package:blog_app/utils/app_theme.dart';

class TagChip extends StatelessWidget {
  final String tag;
  final VoidCallback? onTap;
  const TagChip({super.key, required this.tag, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.typography;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: c.tagBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.tagText.withValues(alpha: 0.15), width: 1),
        ),
        child: Text(
          '#${tag.toLowerCase()}',
          style: t.bodySmall.copyWith(
            color: c.tagText,
            fontWeight: FontWeight.w700,
            fontSize: 10,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}