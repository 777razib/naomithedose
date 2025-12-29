import 'package:flutter/material.dart';

class FeaturesSpotlight extends StatefulWidget {
  final List<String> features;

  const FeaturesSpotlight({
    Key? key,
    required this.features,
  }) : super(key: key);

  @override
  State<FeaturesSpotlight> createState() => _FeaturesSpotlightState();
}

class _FeaturesSpotlightState extends State<FeaturesSpotlight>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1500), _nextFeature);
  }

  void _nextFeature() {
    if (!mounted) return;

    // fade out
    _controller.reverse().then((_) {
      if (!mounted) return;

      setState(() {
        currentIndex = (currentIndex + 1) % widget.features.length;
      });

      // fade in পরেরটা
      _controller.forward();

      // আবার 1.5 সেকেন্ড পর কল করো (লুপ)
      Future.delayed(const Duration(milliseconds: 1500), _nextFeature);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 20, color: Colors.green),
            const SizedBox(width: 12),
            Text(
              widget.features[currentIndex],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}