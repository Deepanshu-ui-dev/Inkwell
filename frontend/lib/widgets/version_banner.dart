import 'package:flutter/material.dart';
import 'package:blog_app/services/version_service.dart';
import 'package:blog_app/utils/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Soft update banner — shown below the hero header when a new version is available.
/// Dismissible with a gentle slide-up animation.
class VersionBanner extends StatefulWidget {
  final VersionInfo info;
  final VoidCallback onUpdateTap;

  const VersionBanner({super.key, required this.info, required this.onUpdateTap});

  @override
  State<VersionBanner> createState() => _VersionBannerState();
}

class _VersionBannerState extends State<VersionBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.accent, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: context.colors.accent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.system_update_rounded, size: 18, color: context.colors.ink),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'v${widget.info.currentVersion} is available',
                  style: context.typography.labelLarge.copyWith(color: context.colors.accentDeep),
                ),
                if (widget.info.changelog.isNotEmpty)
                  Text(
                    widget.info.changelog,
                    style: context.typography.bodySmall.copyWith(color: context.colors.accentDeep),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: widget.onUpdateTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: context.colors.accentDeep,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Update',
                style: context.typography.labelLarge.copyWith(
                  color: context.colors.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: () => setState(() => _dismissed = true),
            child: Icon(Icons.close_rounded, size: 18, color: context.colors.accentDeep),
          ),
        ],
      ),
    ).animate().slideY(begin: -0.3, duration: 400.ms, curve: Curves.easeOutCubic).fade();
  }
}
