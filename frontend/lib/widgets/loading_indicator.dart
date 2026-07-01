import 'package:flutter/material.dart';
import 'package:blog_app/utils/app_theme.dart';


class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Center(child: SizedBox(
      width: 22, height: 22,
      child: CircularProgressIndicator(
          strokeWidth: 2, color: context.colors.ink),
    )),
  );
}