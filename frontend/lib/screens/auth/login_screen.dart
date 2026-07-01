// login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blog_app/providers/auth_provider.dart';
import 'package:blog_app/utils/app_theme.dart';
import 'package:blog_app/utils/constants.dart';
import 'package:blog_app/utils/validators.dart';
import 'package:blog_app/widgets/app_snackbar.dart';
import 'package:blog_app/widgets/brutalist_button.dart';
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
      body: SafeArea(
        child: ResponsiveWrapper(
          maxWidth: 440,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 56),

                // Brand
                Row(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: c.ink, borderRadius: BorderRadius.circular(13)),
                    alignment: Alignment.center,
                    child: Icon(Icons.auto_stories_rounded, size: 20, color: c.accent),
                  ),
                  const SizedBox(width: 10),
                  Text('Folio', style: t.titleLarge),
                ]),

                const SizedBox(height: 40),
                Text('Welcome back', style: t.displayLarge),
                const SizedBox(height: 8),
                Text('Sign in to react and join the conversation.', style: t.bodyMedium),
                const SizedBox(height: 36),

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
                        prefixIcon: Icon(Icons.mail_outline_rounded,
                            size: 20),
                      ),
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 14),
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
                    ),
                    const SizedBox(height: 24),
                    BrutalistButton(
                      key: const Key('login_submit_button'),
                      onPressed: auth.isLoading ? () {} : _submit,
                      isLoading: auth.isLoading,
                      text: 'Sign in',
                    ),
                  ]),
                ),

                const SizedBox(height: 24),
                Center(child: TextButton(
                  key: const Key('go_to_signup_button'),
                  onPressed: () => Navigator.pushNamed(context, AppConstants.routeSignup),
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
                )),
                Center(child: TextButton(
                  key: const Key('continue_as_guest_button'),
                  onPressed: () => Navigator.pushReplacementNamed(
                      context, AppConstants.routeBlogList),
                  child: Text('Continue as guest', style: t.bodySmall),
                )),
                const SizedBox(height: 40),
              ].animate(interval: 35.ms).fade(duration: 320.ms).slideY(begin: 0.04),
            ),
          ),
        ),
      ),
    );
  }
}