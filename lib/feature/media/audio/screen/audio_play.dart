import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:naomithedose/core/widgets/custom_appbar.dart';
import 'package:naomithedose/feature/media/audio/screen/description_screen.dart';

const kTeal = Color(0xFF39CCCC);

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  double _progress = 0.4; // 0..1
  final int _totalSeconds = 4 * 60 + 20; // 4:20

  String _format(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final currentSeconds = (_totalSeconds * _progress).round();

    return Scaffold(
      backgroundColor: const Color(0xffFFFFF3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              CustomAppBar(title:   
                const Text(
                  '',
                  
                ),
              ),

              // Remove extra space here
              const SizedBox(height: 5),

              // Main content (no center alignment)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Album Art
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/podcast1.png',
                        width: 300,
                        height: 320,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 250,
                          height: 250,
                          alignment: Alignment.center,
                          color: kTeal.withOpacity(0.12),
                          child: const Icon(Icons.image_not_supported, color: kTeal),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Song title, artist, and menu icon
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Title & subtitle (left-aligned)
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'The Next Big Move',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'By Tanishk Bagchi',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Menu icon from assets
                         IconButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PodcastDescriptionScreen()),
    );
  },
  icon: Image.asset(
    'assets/icons/menu.png',
    width: 26,
    height: 26,
    color: kTeal, // tint
  ),
),

                        ],
                      ),
                    ),

                    const SizedBox(height: 80),

                    // Waveform ("bits") progress bar
                    Column(
                      children: [
                        WaveformProgressBar(
                          progress: _progress,
                          onChanged: (p) => setState(() => _progress = p),
                          barCount: 80,
                          preferredBarWidth: 3,
                          gap: 2,
                          maxBarHeight: 48,
                          activeColor: kTeal,
                          inactiveColor: kTeal.withOpacity(0.25),
                          thumbRadius: 7,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_format(currentSeconds),
                                style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            Text(_format(_totalSeconds),
                                style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 50),

                    // Control buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Image.asset(
                            'assets/icons/shuffle.png',
                            width: 26,
                            height: 26,
                            color: kTeal,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.skip_previous, size: 30, color: kTeal),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: kTeal, width: 2),
                          ),
                          child: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.pause, size: 30, color: kTeal),
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.skip_next, size: 30, color: kTeal),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Image.asset(
                            'assets/icons/repeat.png',
                            width: 26,
                            height: 26,
                            color: kTeal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A seekable waveform-style progress bar made of vertical bars.
/// - `progress` is 0..1
/// - Tap or drag to seek
class WaveformProgressBar extends StatelessWidget {
  const WaveformProgressBar({
    super.key,
    required this.progress,
    required this.onChanged,
    this.barCount = 60,
    this.preferredBarWidth = 3.0,
    this.gap = 2.0,
    this.maxBarHeight = 40.0,
    this.activeColor = Colors.black,
    this.inactiveColor = Colors.grey,
    this.thumbRadius = 6.0,
  });

  final double progress;
  final ValueChanged<double> onChanged;

  final int barCount;
  final double preferredBarWidth;
  final double gap;
  final double maxBarHeight;
  final Color activeColor;
  final Color inactiveColor;
  final double thumbRadius;

  // Deterministic pseudo-wave heights
  List<double> _sampleHeights() {
    final List<double> h = [];
    for (int i = 0; i < barCount; i++) {
      final t = i / barCount;
      final v = (0.55 +
          0.35 * math.sin(2 * math.pi * (3 * t)) +
          0.25 * math.sin(2 * math.pi * (7 * t + 0.4)) +
          0.15 * math.sin(2 * math.pi * (13 * t + 1.7)));
      h.add(v.clamp(0.1, 1.0));
    }
    return h;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final totalWidth = c.maxWidth;
        final double barWidth = (totalWidth - gap * (barCount - 1)) / barCount;
        final bars = _sampleHeights();
        final activeCount = (progress * barCount)
            .clamp(0, barCount.toDouble())
            .floor();

        void _seekFromDx(double dx) {
          final p = (dx / totalWidth).clamp(0.0, 1.0);
          onChanged(p);
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => _seekFromDx(d.localPosition.dx),
          onHorizontalDragUpdate: (d) => _seekFromDx(d.localPosition.dx),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Bars
              Row(
                children: List.generate(barCount, (i) {
                  final h = bars[i] * maxBarHeight;
                  final isActive = i < activeCount;
                  return Padding(
                    padding: EdgeInsets.only(right: i == barCount - 1 ? 0 : gap),
                    child: Container(
                      width: barWidth,
                      height: h,
                      decoration: BoxDecoration(
                        color: isActive ? activeColor : inactiveColor,
                        borderRadius: BorderRadius.circular(barWidth),
                      ),
                    ),
                  );
                }),
              ),
              // Thumb indicator (small circle)
              Positioned(
                left: (totalWidth * progress) - thumbRadius,
                child: Container(
                  width: thumbRadius * 2,
                  height: thumbRadius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: activeColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
