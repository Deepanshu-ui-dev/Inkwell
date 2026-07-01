import 'package:flutter/material.dart';
import 'package:blog_app/utils/app_theme.dart';

class AppSnackbar {
  static void show(BuildContext context, {
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    final c = context.colors;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: duration,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      backgroundColor: isError ? c.error : c.ink,
      content: Row(children: [
        Icon(
          isError
              ? Icons.error_outline_rounded
              : Icons.check_circle_outline_rounded,
          color: isError ? Colors.white : c.accent, size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(message,
            style: const TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500))),
      ]),
    ));
  }
}