// widget/feature_item_widget.dart (or wherever you keep it)

import 'package:flutter/material.dart';

class FeaturesSpotlight extends StatelessWidget {
  final List<String> features;
  final double progress; // 0.0 to 1.0 (from audio progress)

  const FeaturesSpotlight({
    Key? key,
    required this.features,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Divide audio into 4 equal parts → show one feature per 25%
    int index = (progress * features.length).floor().clamp(0, features.length - 1);

    // Optional: Add a subtle fade or scale animation when index changes
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        );
      },
      child: Padding(
        key: ValueKey<int>(index), // Important for AnimatedSwitcher
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 24,
              color: Colors.orangeAccent.shade700,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                features[index],
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Icon(
              Icons.auto_awesome,
              size: 24,
              color: Colors.orangeAccent.shade700,
            ),
          ],
        ),
      ),
    );
  }
}