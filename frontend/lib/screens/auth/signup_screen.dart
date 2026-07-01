import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blog_app/providers/auth_provider.dart';
import 'package:blog_app/utils/app_theme.dart';
import 'package:blog_app/utils/constants.dart';
import 'package:blog_app/utils/validators.dart';
import 'package:blog_app/widgets/app_snackbar.dart';
import 'package:blog_app/widgets/global_background.dart';
import 'package:blog_app/widgets/responsive_wrapper.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.signup(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    if (ok) {
      AppSnackbar.show(context, message: 'Account created. Welcome!');
      Navigator.pushReplacementNamed(context, AppConstants.routeBlogList);
    } else {
      AppSnackbar.show(context,
          message: auth.errorMessage ?? 'Signup failed', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final c = context.colors;
    final t = context.typography;

    return Scaffold(
      backgroundColor: c.background,
      body: GlobalBackground(
        child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            decoration: BoxDecoration(
              color: c.surfaceCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: c.border, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: c.ink.withValues(alpha: 0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Brand Header ─────────────────────────────────────────────
                _BrandHeader(c: c, t: t),

                // ── Form Panel ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Create account',
                          style: t.displayMedium.copyWith(fontSize: 26))
                          .animate().fade(duration: 300.ms, delay: 100.ms).slideY(begin: 0.04),
                      const SizedBox(height: 6),
                      Text('Join to like stories and be part of the community.',
                          style: t.bodyMedium, textAlign: TextAlign.center)
                          .animate().fade(duration: 300.ms, delay: 140.ms),
                      const SizedBox(height: 32),

                      Form(
                        key: _formKey,
                        child: Column(children: [
                          TextFormField(
                            key: const Key('signup_name_field'),
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            style: t.bodyLarge,
                            decoration: const InputDecoration(
                              labelText: 'Full name',
                              prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                            ),
                            validator: Validators.name,
                          ).animate().fade(duration: 280.ms, delay: 180.ms).slideY(begin: 0.03),
                          const SizedBox(height: 16),
                          TextFormField(
                            key: const Key('signup_email_field'),
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            style: t.bodyLarge,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.mail_outline_rounded, size: 20),
                            ),
                            validator: Validators.email,
                          ).animate().fade(duration: 280.ms, delay: 220.ms).slideY(begin: 0.03),
                          const SizedBox(height: 16),
                          TextFormField(
                            key: const Key('signup_password_field'),
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: t.bodyLarge,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              helperText: 'At least 6 characters',
                              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20, color: c.inkMuted,
                                ),
                                onPressed: () =>
                                    setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: Validators.password,
                            onFieldSubmitted: (_) => _submit(),
                          ).animate().fade(duration: 280.ms, delay: 260.ms).slideY(begin: 0.03),
                          const SizedBox(height: 24),

                          // Create account button
                          _CreateButton(
                            key: const Key('signup_submit_button'),
                            isLoading: auth.isLoading,
                            onTap: auth.isLoading ? null : _submit,
                            c: c, t: t,
                          ).animate().fade(duration: 280.ms, delay: 300.ms),
                        ]),
                      ),

                      const SizedBox(height: 24),
                      Center(child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: RichText(text: TextSpan(
                          style: t.bodyMedium,
                          children: [
                            const TextSpan(text: 'Already have an account? '),
                            TextSpan(text: 'Sign in',
                                style: t.labelLarge.copyWith(
                                  decoration: TextDecoration.underline,
                                  decorationColor: c.accent,
                                  decorationThickness: 2.5,
                                )),
                          ],
                        )),
                      )).animate().fade(duration: 280.ms, delay: 340.ms),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

// ── Brand Header ─────────────────────────────────────────────────────────────
class _BrandHeader extends StatelessWidget {
  final AppColorsExtension c;
  final AppTypographyExtension t;
  const _BrandHeader({required this.c, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: c.heroBg,
        border: Border(bottom: BorderSide(color: c.border, width: 1.2)),
      ),
      child: Stack(children: [
        Positioned.fill(
          child: RepaintBoundary(child: CustomPaint(painter: _GridPainter())),
        ),
        // Glow orb
        Positioned(top: -40, right: -20,
          child: Container(
            width: 140, height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                c.accentWarm.withValues(alpha: 0.15),
                c.accentWarm.withValues(alpha: 0),
              ]),
            ),
          ),
        ),

        // Brand content
        Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: c.accent,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.auto_stories_rounded, size: 24, color: c.accentDeep),
            ),
            const SizedBox(height: 12),
            Text('Join Inkwell', style: t.titleLarge.copyWith(
                color: c.inkOnDark, fontSize: 22, letterSpacing: -0.4)),
          ]).animate().fade(duration: 400.ms, delay: 50.ms).slideY(begin: 0.04),
        ),
      ]),
    );
  }
}

// ── Create account button ─────────────────────────────────────────────────────
class _CreateButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onTap;
  final AppColorsExtension c;
  final AppTypographyExtension t;
  const _CreateButton({
    super.key,
    required this.isLoading,
    required this.onTap,
    required this.c,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: isLoading ? c.ink.withValues(alpha: 0.7) : c.ink,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isLoading ? [] : [
            BoxShadow(
              color: c.ink.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: isLoading
            ? SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: c.accent),
              )
            : Text('Create account →',
                style: t.labelLarge.copyWith(color: c.accent, fontSize: 14)),
      ),
    );
  }
}

// ── Grid painter ──────────────────────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    const step = 26.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    final rng = math.Random(13);
    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.08);
    for (int i = 0; i < 100; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        1.0, dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}