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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(
        _emailController.text.trim(), _passwordController.text);
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, AppConstants.routeBlogList);
    } else {
      AppSnackbar.show(context,
          message: auth.errorMessage ?? 'Login failed', isError: true);
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
                      Text('Welcome back', style: t.displayMedium.copyWith(fontSize: 26), textAlign: TextAlign.center)
                          .animate().fade(duration: 300.ms, delay: 100.ms).slideY(begin: 0.04),
                      const SizedBox(height: 6),
                      Text('Sign in to react and join the conversation.',
                          style: t.bodyMedium, textAlign: TextAlign.center)
                          .animate().fade(duration: 300.ms, delay: 140.ms),
                      const SizedBox(height: 32),

                      Form(
                        key: _formKey,
                        child: Column(children: [
                          TextFormField(
                            key: const Key('login_email_field'),
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            style: t.bodyLarge,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.mail_outline_rounded, size: 20),
                            ),
                            validator: Validators.email,
                          ).animate().fade(duration: 280.ms, delay: 180.ms).slideY(begin: 0.03),
                          const SizedBox(height: 16),
                          TextFormField(
                            key: const Key('login_password_field'),
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: t.bodyLarge,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                    size: 20, color: c.inkMuted),
                                onPressed: () =>
                                    setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: Validators.password,
                            onFieldSubmitted: (_) => _submit(),
                          ).animate().fade(duration: 280.ms, delay: 220.ms).slideY(begin: 0.03),
                          const SizedBox(height: 24),

                          // Sign in button
                          _SignInButton(
                            key: const Key('login_submit_button'),
                            isLoading: auth.isLoading,
                            onTap: auth.isLoading ? null : _submit,
                            c: c, t: t,
                          ).animate().fade(duration: 280.ms, delay: 260.ms),
                        ]),
                      ),

                      const SizedBox(height: 24),
                      Center(child: TextButton(
                        key: const Key('go_to_signup_button'),
                        onPressed: () => Navigator.pushReplacementNamed(context, AppConstants.routeSignup),
                        child: RichText(text: TextSpan(
                          style: t.bodyMedium,
                          children: [
                            const TextSpan(text: "Don't have an account? "),
                            TextSpan(text: 'Sign up',
                                style: t.labelLarge.copyWith(
                                  decoration: TextDecoration.underline,
                                  decorationColor: c.accent,
                                  decorationThickness: 2.5,
                                )),
                          ],
                        )),
                      )).animate().fade(duration: 280.ms, delay: 300.ms),

                      Center(child: TextButton(
                        key: const Key('continue_as_guest_button'),
                        onPressed: () => Navigator.pushReplacementNamed(
                            context, AppConstants.routeBlogList),
                        child: Text('Continue as guest', style: t.bodySmall),
                      )).animate().fade(duration: 280.ms, delay: 320.ms),
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
        // Grid background
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
                c.accent.withValues(alpha: 0.15),
                c.accent.withValues(alpha: 0),
              ]),
            ),
          ),
        ),

        // Brand content centred
        Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: c.accent,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.auto_stories_rounded, size: 24, color: c.accentDeep),
            ),
            const SizedBox(height: 12),
            Text('Inkwell', style: t.titleLarge.copyWith(
                color: c.inkOnDark, fontSize: 22, letterSpacing: -0.5)),
          ]).animate().fade(duration: 400.ms, delay: 50.ms).slideY(begin: 0.04),
        ),
      ]),
    );
  }
}

// ── Sign-in button ────────────────────────────────────────────────────────────
class _SignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onTap;
  final AppColorsExtension c;
  final AppTypographyExtension t;
  const _SignInButton({
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
            : Text('Sign in →',
                style: t.labelLarge.copyWith(color: c.accent, fontSize: 15)),
      ),
    );
  }
}

// ── Mini grid painter (reused in brand panel) ─────────────────────────────────
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
    final rng = math.Random(7);
    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.08);
    for (int i = 0; i < 120; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        1.0, dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}