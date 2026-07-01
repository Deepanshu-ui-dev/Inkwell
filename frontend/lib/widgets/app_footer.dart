import 'package:flutter/material.dart';
import 'package:blog_app/services/version_service.dart';
import 'package:blog_app/utils/app_theme.dart';

/// Premium app footer — shown at the bottom of the blog feed.
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.typography;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section — brand + tagline
          
        


          // Links row
  

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              height: 1,
              color: c.border.withValues(alpha: 0.5),
            ),
          ),

          // Bottom row — copyright + version
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
            child: Row(
              children: [
                Text(
                  '© ${DateTime.now().year} Inkwell',
                  style: t.caption.copyWith(
                      color: c.inkMuted, letterSpacing: 0.3),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: c.tagBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: c.border),
                  ),
                  child: Text(
                    'v$kAppVersion',
                    style: t.caption.copyWith(color: c.tagText, fontSize: 9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
