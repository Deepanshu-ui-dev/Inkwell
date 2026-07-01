import 'package:flutter/material.dart';
import 'package:blog_app/utils/app_theme.dart';
import 'package:blog_app/models/comment_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentTile extends StatelessWidget {
  final CommentModel comment;
  final VoidCallback? onDelete;
  const CommentTile({super.key, required this.comment, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.typography;
    final name = comment.viewer?.name ?? 'Viewer';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'V';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: c.surface, shape: BoxShape.circle,
            border: Border.all(color: c.border, width: 1),
          ),
          alignment: Alignment.center,
          child: comment.viewer?.avatarUrl != null
              ? ClipOval(child: Image.network(
                  comment.viewer!.avatarUrl!, width: 34, height: 34, fit: BoxFit.cover))
              : Text(initial, style: TextStyle(
                  color: c.ink, fontSize: 13, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(name, style: t.labelLarge),
            const SizedBox(width: 8),
            Text(timeago.format(comment.createdAt), style: t.bodySmall),
            const Spacer(),
            if (onDelete != null)
              GestureDetector(
                onTap: onDelete,
                child: Icon(Icons.close_rounded, size: 15, color: c.inkMuted),
              ),
          ]),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Text(comment.text,
                style: t.bodyMedium.copyWith(color: c.ink, height: 1.55)),
          ),
        ])),
      ]),
    );
  }
}