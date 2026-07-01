import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blog_app/providers/auth_provider.dart';
import 'package:blog_app/providers/theme_provider.dart';
import 'package:blog_app/utils/app_theme.dart';
import 'package:blog_app/utils/constants.dart';
import 'package:blog_app/widgets/app_snackbar.dart';
import 'package:blog_app/widgets/global_background.dart';
import 'package:blog_app/widgets/responsive_wrapper.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_animate/flutter_animate.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final c = context.colors;
    final t = context.typography;

    if (user == null) {
      return Scaffold(
        backgroundColor: c.background,
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('Not logged in')),
      );
    }

    final initials = user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: GlobalBackground(
          child: ResponsiveWrapper(
            maxWidth: 640,
            child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── App bar ─────────────────────────────────────────────
            SliverAppBar(
              pinned: true,
              backgroundColor: c.background,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: c.surfaceCard,
                      shape: BoxShape.circle,
                      border: Border.all(color: c.border),
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        size: 15, color: c.ink),
                  ),
                ),
              ),
              title: Text('My Profile', style: t.titleMedium),
              centerTitle: true,
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 60),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // ── Profile card ──────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: c.surfaceCard,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: c.border, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: c.ink.withValues(alpha: 0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(children: [
                      Stack(children: [
                        // Avatar
                        Container(
                          width: 88, height: 88,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                c.accent.withValues(alpha: 0.8),
                                c.accentDeep,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(color: c.border, width: 2),
                            image: user.avatarUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(user.avatarUrl!),
                                    fit: BoxFit.cover)
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: user.avatarUrl == null
                              ? Text(initials,
                                  style: t.displayLarge.copyWith(
                                      color: c.accentDeep, fontSize: 36))
                              : null,
                        ),
                        // Role badge
                        Positioned(
                          bottom: 2, right: 2,
                          child: Container(
                            width: 26, height: 26,
                            decoration: BoxDecoration(
                              color: user.isAuthor ? c.accent : c.surfaceCard,
                              shape: BoxShape.circle,
                              border: Border.all(color: c.border, width: 2),
                            ),
                            child: Icon(
                              user.isAuthor
                                  ? Icons.edit_rounded
                                  : Icons.person_rounded,
                              size: 13, color: user.isAuthor ? c.accentDeep : c.inkMuted,
                            ),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 16),
                      Text(user.name, style: t.titleLarge.copyWith(fontSize: 20)),
                      const SizedBox(height: 4),
                      Text(user.email, style: t.bodyMedium),
                      const SizedBox(height: 14),
                      // Role pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: user.isAuthor
                              ? c.accent.withValues(alpha: 0.15)
                              : c.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: user.isAuthor
                                ? c.accent.withValues(alpha: 0.4)
                                : c.border,
                          ),
                        ),
                        child: Text(
                          user.isAuthor ? '✍️  Author' : '👁  Viewer',
                          style: t.labelLarge.copyWith(
                            color: user.isAuthor ? c.accentDeep : c.inkSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Stat row
                      Row(children: [
                        _StatTile(
                          icon: Icons.mail_outline_rounded,
                          label: 'Email',
                          value: user.email,
                          c: c, t: t,
                        ),
                        const SizedBox(width: 12),
                        _StatTile(
                          icon: Icons.calendar_today_outlined,
                          label: 'Member since',
                          value: timeago.format(user.createdAt),
                          c: c, t: t,
                        ),
                      ]),
                    ]),
                  ).animate().fade(duration: 300.ms).slideY(begin: 0.04),

                  const SizedBox(height: 28),

                  // ── Author tools ──────────────────────────────────
                  if (user.isAuthor) ...[
                    _SectionLabel(label: 'AUTHOR TOOLS', c: c, t: t),
                    const SizedBox(height: 12),
                    _ActionTile(
                      key: const Key('write_new_blog_tile'),
                      icon: Icons.edit_outlined,
                      label: 'Write a new story',
                      accent: true,
                      onTap: () => Navigator.pushNamed(
                          context, AppConstants.routeBlogEditor),
                      c: c, t: t,
                    ).animate().fade(duration: 300.ms, delay: 60.ms).slideX(begin: -0.02),
                    const SizedBox(height: 24),
                  ],

                  // ── Activity ──────────────────────────────────────
                  if (user.isViewer) ...[
                    _SectionLabel(label: 'ACTIVITY', c: c, t: t),
                    const SizedBox(height: 12),
                    _ActionTile(
                      key: const Key('my_likes_tile'),
                      icon: Icons.favorite_border_rounded,
                      label: 'My liked stories',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: c.border),
                        ),
                        child: Text('Soon',
                            style: t.caption.copyWith(color: c.inkMuted)),
                      ),
                      onTap: () => AppSnackbar.show(context, message: 'Coming soon!'),
                      c: c, t: t,
                    ).animate().fade(duration: 300.ms, delay: 80.ms).slideX(begin: -0.02),
                    const SizedBox(height: 24),
                  ],

                  // ── Account ───────────────────────────────────────
                  _SectionLabel(label: 'ACCOUNT', c: c, t: t),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => context.read<ThemeProvider>().toggleTheme(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: c.surfaceCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: c.border),
                      ),
                      child: Row(children: [
                        Icon(
                          context.watch<ThemeProvider>().isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                          size: 18, color: c.ink,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          context.watch<ThemeProvider>().isDarkMode ? 'Light mode' : 'Dark mode',
                          style: t.titleMedium,
                        ),
                        const Spacer(),
                        Container(
                          width: 44, height: 24,
                          decoration: BoxDecoration(
                            color: context.watch<ThemeProvider>().isDarkMode ? c.accent : c.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: c.border),
                          ),
                          alignment: context.watch<ThemeProvider>().isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
                          padding: const EdgeInsets.all(3),
                          child: Container(
                            width: 18, height: 18,
                            decoration: BoxDecoration(
                              color: context.watch<ThemeProvider>().isDarkMode ? c.accentDeep : c.inkMuted,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ActionTile(
                    key: const Key('logout_button'),
                    icon: Icons.logout_rounded,
                    label: 'Sign out',
                    isDestructive: true,
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: c.surfaceCard,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          title: Text('Sign out?', style: t.titleLarge),
                          content: Text(
                              'You will need to sign in again to like articles.',
                              style: t.bodyMedium),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: TextButton.styleFrom(
                                foregroundColor: c.error,
                              ),
                              child: const Text('Sign out',
                                  style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && context.mounted) {
                        await context.read<AuthProvider>().logout();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                              context, AppConstants.routeBlogList, (r) => false);
                        }
                      }
                    },
                    c: c, t: t,
                  ).animate().fade(duration: 300.ms, delay: 120.ms).slideX(begin: -0.02),
                ]),
              ),
            ),
          ],
        ),
      ),
      ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final AppColorsExtension c;
  final AppTypographyExtension t;
  const _SectionLabel({required this.label, required this.c, required this.t});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 3, height: 14,
        decoration: BoxDecoration(color: c.accent, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 8),
    Text(label, style: t.caption.copyWith(letterSpacing: 1.4)),
  ]);
}

// ── Stat tile ─────────────────────────────────────────────────────────────────
class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final AppColorsExtension c;
  final AppTypographyExtension t;
  const _StatTile({
    required this.icon, required this.label,
    required this.value, required this.c, required this.t,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border, width: 1),
      ),
      child: Row(children: [
        Icon(icon, size: 16, color: c.inkMuted),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: t.caption.copyWith(color: c.inkMuted)),
          const SizedBox(height: 2),
          Text(value,
              style: t.bodySmall.copyWith(
                  color: c.ink, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis),
        ])),
      ]),
    ),
  );
}

// ── Action tile ───────────────────────────────────────────────────────────────
class _ActionTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool accent;
  final bool isDestructive;
  final AppColorsExtension c;
  final AppTypographyExtension t;

  const _ActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.c,
    required this.t,
    this.trailing,
    this.accent = false,
    this.isDestructive = false,
  });

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final t = widget.t;
    final destructive = widget.isDestructive;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: destructive
                ? c.error.withValues(alpha: 0.06)
                : c.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: destructive
                  ? c.error.withValues(alpha: 0.2)
                  : c.border,
              width: 1.2,
            ),
            boxShadow: _pressed ? [] : [
              BoxShadow(
                color: c.ink.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: destructive
                    ? c.error.withValues(alpha: 0.10)
                    : widget.accent
                        ? c.accent.withValues(alpha: 0.15)
                        : c.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: destructive
                      ? c.error.withValues(alpha: 0.2)
                      : c.border,
                ),
              ),
              alignment: Alignment.center,
              child: Icon(widget.icon, size: 17,
                  color: destructive
                      ? c.error
                      : widget.accent ? c.accentDeep : c.ink),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(widget.label,
                  style: t.titleMedium.copyWith(
                      color: destructive ? c.error : c.ink,
                      fontWeight: FontWeight.w600)),
            ),
            widget.trailing ??
                Icon(Icons.chevron_right_rounded, size: 20,
                    color: destructive ? c.error.withValues(alpha: 0.5) : c.inkMuted),
          ]),
        ),
      ),
    );
  }
}