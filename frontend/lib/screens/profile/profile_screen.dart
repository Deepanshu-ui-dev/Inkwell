import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blog_app/providers/auth_provider.dart';
import 'package:blog_app/utils/app_theme.dart';
import 'package:blog_app/utils/constants.dart';
import 'package:blog_app/widgets/app_snackbar.dart';
import 'package:blog_app/widgets/responsive_wrapper.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_animate/flutter_animate.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: context.colors.background,
        appBar: AppBar(title: Text('Profile')),
        body: Center(child: Text('Not logged in')),
      );
    }

    final initials = user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Dashboard', style: context.typography.titleLarge),
        centerTitle: true,
      ),
      body: ResponsiveWrapper(
        maxWidth: 640,
        child: ListView(
          padding: EdgeInsets.fromLTRB(24, 16, 24, 60),
          children: [
            // ── Profile card ─────────────────────────────────────
            Container(
              padding: EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: context.colors.surfaceWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.colors.ink, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.ink,
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 96, height: 96,
                        decoration: BoxDecoration(
                          color: context.colors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: context.colors.ink, width: 2),
                          image: user.avatarUrl != null
                              ? DecorationImage(image: NetworkImage(user.avatarUrl!), fit: BoxFit.cover)
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: user.avatarUrl == null
                            ? Text(initials,
                                style: context.typography.displayLarge.copyWith(
                                    color: context.colors.ink, fontSize: 40))
                            : null,
                      ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 3000.ms, color: context.colors.surfaceWhite.withValues(alpha: 0.5)),
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: user.isAuthor ? context.colors.accent : context.colors.surfaceWhite,
                            shape: BoxShape.circle,
                            border: Border.all(color: context.colors.ink, width: 2),
                          ),
                          child: Icon(
                            user.isAuthor ? Icons.edit_rounded : Icons.person_rounded,
                            size: 14,
                            color: context.colors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(user.name, style: context.typography.displayMedium),
                  SizedBox(height: 6),
                  Text(user.email, style: context.typography.bodyMedium),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: user.isAuthor ? context.colors.accent : context.colors.surfaceWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: context.colors.ink, width: 1.5),
                    ),
                    child: Text(
                      user.isAuthor ? 'Author' : 'Viewer',
                      style: context.typography.labelLarge.copyWith(
                        color: context.colors.ink,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      _StatTile(label: 'Email', value: user.email, icon: Icons.mail_outline_rounded),
                      SizedBox(width: 12),
                      _StatTile(
                        label: 'Member since',
                        value: timeago.format(user.createdAt),
                        icon: Icons.calendar_today_outlined,
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fade(duration: 300.ms).slideY(begin: 0.05),

            SizedBox(height: 32),

            if (user.isAuthor) ...[
              Text('AUTHOR TOOLS', style: context.typography.caption),
              SizedBox(height: 12),
              _ActionTile(
                key: const Key('write_new_blog_tile'),
                icon: Icons.edit_outlined,
                label: 'Write a new story',
                accent: true,
                onTap: () => Navigator.pushNamed(context, AppConstants.routeBlogEditor),
              ).animate().fade(duration: 300.ms, delay: 50.ms).slideX(begin: -0.02),
              SizedBox(height: 24),
            ],

            if (user.isViewer) ...[
              Text('ACTIVITY', style: context.typography.caption),
              SizedBox(height: 12),
              _ActionTile(
                key: const Key('my_likes_tile'),
                icon: Icons.favorite_border_rounded,
                label: 'My liked stories',
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: context.colors.ink, width: 1),
                  ),
                  child: Text('Soon', style: context.typography.caption.copyWith(color: context.colors.ink)),
                ),
                onTap: () => AppSnackbar.show(context, message: 'Coming soon!'),
              ).animate().fade(duration: 300.ms, delay: 100.ms).slideX(begin: -0.02),
              SizedBox(height: 24),
            ],

            Text('ACCOUNT', style: context.typography.caption),
            SizedBox(height: 12),
            _ActionTile(
              key: const Key('logout_button'),
              icon: Icons.logout_rounded,
              label: 'Sign out',
              iconColor: context.colors.surfaceWhite,
              labelColor: context.colors.surfaceWhite,
              bgColor: context.colors.error,
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: context.colors.surfaceWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: context.colors.ink, width: 2),
                    ),
                    title: Text('Sign out?', style: context.typography.titleLarge),
                    content: Text('You will need to sign in again to like articles.',
                        style: context.typography.bodyMedium),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false), 
                        style: TextButton.styleFrom(foregroundColor: context.colors.ink),
                        child: Text('Cancel')
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: TextButton.styleFrom(
                          backgroundColor: context.colors.error,
                          foregroundColor: context.colors.surfaceWhite,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('Sign out', style: TextStyle(fontWeight: FontWeight.w800)),
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
            ).animate().fade(duration: 300.ms, delay: 150.ms).slideX(begin: -0.02),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.colors.ink, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: context.colors.ink),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: context.typography.caption.copyWith(color: context.colors.inkSecondary)),
                  SizedBox(height: 2),
                  Text(value,
                      style: context.typography.bodySmall.copyWith(color: context.colors.ink, fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool accent;
  final Color? iconColor;
  final Color? labelColor;
  final Color? bgColor;

  const _ActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.accent = false,
    this.iconColor,
    this.labelColor,
    this.bgColor,
  });

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(
          _isPressed ? 2 : 0, 
          _isPressed ? 2 : 0, 
          0
        ),
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: widget.bgColor ?? context.colors.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.ink, width: 2),
          boxShadow: _isPressed ? [] : [
            BoxShadow(
              color: context.colors.ink,
              offset: Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: widget.accent ? context.colors.accent : (widget.bgColor != null ? context.colors.surfaceWhite.withValues(alpha: 0.2) : context.colors.surface),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: widget.bgColor != null ? Colors.transparent : context.colors.ink, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Icon(widget.icon, size: 18, color: widget.iconColor ?? (widget.accent ? context.colors.ink : context.colors.ink)),
            ),
            SizedBox(width: 14),
            Text(widget.label,
                style: context.typography.titleMedium.copyWith(color: widget.labelColor ?? context.colors.ink)),
            const Spacer(),
            widget.trailing ?? Icon(Icons.arrow_forward_rounded, size: 20, color: widget.labelColor ?? context.colors.ink),
          ],
        ),
      ),
    );
  }
}