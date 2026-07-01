import 'package:flutter/material.dart';
import 'package:blog_app/utils/app_theme.dart';

class BrutalistButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const BrutalistButton({
    super.key, required this.text,
    required this.onPressed, this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      width: double.infinity, height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: 20, width: 20,
                child: CircularProgressIndicator(
                    color: c.accent, strokeWidth: 2.5))
            : Text(text),
      ),
    );
  }
}