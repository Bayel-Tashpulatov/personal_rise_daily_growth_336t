// widgets/toast.dart
import 'dart:async';
import 'package:flutter/material.dart';

class AppToast {
  static void show(
    BuildContext context, {
    required Widget child,
    Duration duration = const Duration(seconds: 10),
  }) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Material(
              color: const Color(0xFF2B2530),
              borderRadius: BorderRadius.circular(12),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Timer(duration, () => entry.remove());
  }
}
