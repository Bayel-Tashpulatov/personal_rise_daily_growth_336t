// widgets/progress_bar.dart
import 'package:flutter/material.dart';

class AppProgressBar extends StatelessWidget {
  final double value;
  const AppProgressBar({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: 10,
        backgroundColor: Colors.white.withOpacity(.07),
        valueColor: AlwaysStoppedAnimation(const Color(0xFF0062FF)),
      ),
    );
  }
}
