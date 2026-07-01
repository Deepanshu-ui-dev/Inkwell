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
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [c.accent, c.accentWarm],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.edit_note_rounded, size: 22, color: c.accentDeep),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Inkwell',
                          style: t.titleLarge.copyWith(letterSpacing: -0.3)),
                      const SizedBox(height: 3),
                      Text('Thoughtful writing for curious minds.',
                          style: t.bodySmall.copyWith(height: 1.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    c.border.withValues(alpha: 0),
                    c.border,
                    c.border.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Links row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FooterChip(label: 'Home', icon: Icons.home_outlined),
                _FooterChip(label: 'About', icon: Icons.info_outline_rounded),
                _FooterChip(label: 'Sign In', icon: Icons.login_rounded),
                _FooterChip(label: 'Privacy', icon: Icons.shield_outlined),
              ],
            ),
          ),

          const SizedBox(height: 20),

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

class _FooterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _FooterChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.typography;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: c.inkMuted),
        const SizedBox(width: 6),
        Text(label,
            style: t.bodySmall.copyWith(
                color: c.inkSecondary, fontWeight: FontWeight.w600, fontSize: 11)),
      ]),
    );
  }
}
