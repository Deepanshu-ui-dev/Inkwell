import 'package:flutter/material.dart';
import 'package:blog_app/services/version_service.dart';
import 'package:blog_app/utils/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shows a blocking or soft update dialog depending on [forceUpgrade].
Future<void> showUpdateDialog(
  BuildContext context, {
  required VersionInfo info,
  required bool forceUpgrade,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: !forceUpgrade,
    builder: (_) => _UpdateDialog(info: info, forceUpgrade: forceUpgrade),
  );
}

class _UpdateDialog extends StatelessWidget {
  final VersionInfo info;
  final bool forceUpgrade;
  const _UpdateDialog({required this.info, required this.forceUpgrade});

  Future<void> _openStore(BuildContext context) async {
    // Detect platform and open appropriate store link
    final url = info.storeUrl['android'] ?? info.storeUrl['ios'];
    if (url == null) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.ink, width: 2),
          boxShadow: [
            BoxShadow(color: context.colors.ink, offset: Offset(6, 6), blurRadius: 0),
          ],
        ),
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + badge
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: context.colors.accent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: context.colors.ink, width: 2),
                    boxShadow: [BoxShadow(color: context.colors.ink, offset: Offset(2, 2))],
                  ),
                  child: Icon(Icons.auto_stories_rounded, color: context.colors.ink, size: 24),
                ),
                SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      forceUpgrade ? 'Update Required' : 'Update Available',
                      style: context.typography.titleLarge,
                    ),
                    Text(
                      'v${info.currentVersion}',
                      style: context.typography.bodySmall.copyWith(color: context.colors.inkMuted),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 24),

            if (forceUpgrade)
              Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.colors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: context.colors.error.withValues(alpha: 0.3), width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_rounded, color: context.colors.error, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'This version is no longer supported. Please update to continue.',
                        style: context.typography.bodyMedium.copyWith(color: context.colors.error),
                      ),
                    ),
                  ],
                ),
              ),

            if (!forceUpgrade && info.changelog.isNotEmpty) ...[
              Text("What's new:", style: context.typography.labelLarge),
              SizedBox(height: 8),
              Text(info.changelog, style: context.typography.bodyMedium),
            ],

            SizedBox(height: 28),

            // Buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _BrutalistBtn(
                  label: 'Update Now',
                  onPressed: () => _openStore(context),
                  filled: true,
                ),
                if (!forceUpgrade) ...[
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(foregroundColor: context.colors.inkMuted),
                    child: Text('Later'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ).animate().scale(begin: const Offset(0.9, 0.9), duration: 300.ms, curve: Curves.easeOutBack),
    );
  }
}

class _BrutalistBtn extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool filled;
  const _BrutalistBtn({required this.label, required this.onPressed, this.filled = false});

  @override
  State<_BrutalistBtn> createState() => _BrutalistBtnState();
}

class _BrutalistBtnState extends State<_BrutalistBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onPressed(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(_pressed ? 3 : 0, _pressed ? 3 : 0, 0),
        padding: EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.filled ? context.colors.ink : context.colors.surfaceWhite,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.colors.ink, width: 2),
          boxShadow: _pressed ? [] : [BoxShadow(color: context.colors.ink, offset: Offset(3, 3))],
        ),
        child: Text(
          widget.label,
          style: context.typography.labelLarge.copyWith(
            color: widget.filled ? context.colors.accent : context.colors.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
