// signup_screen.dart
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
      appBar: AppBar(
        backgroundColor: c.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: c.ink),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ResponsiveWrapper(
          maxWidth: 440,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text('Create account', style: t.displayLarge),
                const SizedBox(height: 8),
                Text('Join to like stories and be part of the community.',
                    style: t.bodyMedium),
                const SizedBox(height: 36),

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
                    ),
                    const SizedBox(height: 14),
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
                    ),
                    const SizedBox(height: 14),
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
                    ),
                    const SizedBox(height: 24),
                    BrutalistButton(
                      key: const Key('signup_submit_button'),
                      onPressed: auth.isLoading ? () {} : _submit,
                      isLoading: auth.isLoading,
                      text: 'Create account',
                    ),
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