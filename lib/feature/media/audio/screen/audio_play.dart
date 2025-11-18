import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'dart:math' as math;

import 'package:naomithedose/core/widgets/custom_appbar.dart';
import 'package:naomithedose/feature/media/audio/screen/description_screen.dart';
import '../controller/audio_paly_api_controller.dart';
import '../controller/audio_summary_api_controller.dart';

const kTeal = Color(0xFF39CCCC);

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({
    super.key,
    this.episodeUrls,        // List of iTunes URLs (e.g. podcast.itunesUrl)
    this.currentTopic = 'general', // Default topic for transcription
    this.Id,
  });

  final List<String>? episodeUrls;
  final String currentTopic;
  final String? Id;

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  late final AudioPlayApiControllers controller;
  final AudioSummaryApiController audioSummaryApiController = Get.put(AudioSummaryApiController());

  int currentIndex = 0;
  String currentUrl = '';

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<AudioPlayApiControllers>()
        ? Get.find<AudioPlayApiControllers>()
        : Get.put(AudioPlayApiControllers());

    // Determine first URL to play
    final urls = widget.episodeUrls ?? [];
    if (urls.isNotEmpty) {
      currentIndex = 0;
      currentUrl = urls.first;
      _loadEpisode(currentUrl, widget.currentTopic);
    } else if (widget.Id != null && widget.Id!.isNotEmpty) {
      currentUrl = widget.Id!;
      _loadEpisode(currentUrl, widget.currentTopic);
    } else {
      Get.back();
    }
  }

  // Fixed: ২টা প্যারামিটার নেবে
  Future<void> _loadEpisode(String url, String topic) async {
    if (url.isEmpty) return;

    currentUrl = url;
    print('Loading Podcast URL: $url | Topic: $topic');

    await controller.audioPlayApiMethod(url, topic);
  }

  Future<void> _playNext() async {
    final urls = widget.episodeUrls ?? [];
    if (urls.isEmpty || currentIndex >= urls.length - 1) return;

    currentIndex++;
    await _loadEpisode(urls[currentIndex], widget.currentTopic);
  }

  Future<void> _playPrevious() async {
    final urls = widget.episodeUrls ?? [];
    if (urls.isEmpty || currentIndex <= 0) return;

    currentIndex--;
    await _loadEpisode(urls[currentIndex], widget.currentTopic);
  }

  String _format(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFFFF3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const CustomAppBar(title: Text('')),
              const SizedBox(height: 5),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Loading
                      Obx(() => controller.isLoading.value
                          ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(color: kTeal),
                      )
                          : const SizedBox()),

                      // Error
                      Obx(() => controller.errorMessage.value != null
                          ? Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          controller.errorMessage.value!,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      )
                          : const SizedBox()),

                      // Album Art
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Obx(() {
                          final episode = controller.podcastResponse.value;
                          final imageUrl = episode?.imageUrl ?? '';
                          return Image.network(
                            imageUrl,
                            width: 300,
                            height: 320,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) => progress == null
                                ? child
                                : Container(
                              color: kTeal.withOpacity(0.12),
                              child: const Center(child: CircularProgressIndicator(color: kTeal)),
                            ),
                            errorBuilder: (_, __, ___) => Container(
                              width: 300,
                              height: 320,
                              color: kTeal.withOpacity(0.12),
                              child: const Icon(Icons.image_not_supported, size: 80, color: kTeal),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 30),

                      // Title & Description
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Obx(() {
                                final episode = controller.podcastResponse.value;
                                final title = episode?.title ?? 'Unknown Episode';
                                final description = episode?.description ?? 'No description';

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      description,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                                    ),
                                  ],
                                );
                              }),
                            ),

                            // Summary Button
                            IconButton(
                              onPressed: audioSummaryApiController.isLoading.value ? null : _summaryApiMethod,
                              icon: Image.asset('assets/icons/menu.png', width: 26, height: 26, color: kTeal),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Progress Bar
                      Obx(() {
                        final durSec = controller.duration.value.inSeconds;
                        final posSec = controller.position.value.inSeconds;
                        final progress = durSec > 0 ? posSec / durSec : 0.0;

                        return Column(
                          children: [
                          WaveformProgressBar(
                          progress: progress,
                          onChanged: controller.seekTo,
                          activeColor: kTeal,
                          inactiveColor: kTeal.withOpacity(0.25),
                        ),
                        const SizedBox(height: 8),
                        Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        Text(_format(posSec), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        Text(_format(durSec), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                        ),
                        ],
                        );
                      }),

                      const SizedBox(height: 50),

                      // Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(onPressed: () {}, icon: Image.asset('assets/icons/shuffle.png', width: 26, height: 26, color: kTeal)),
                          IconButton(onPressed: _playPrevious, icon: const Icon(Icons.skip_previous, size: 30, color: kTeal)),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: kTeal, width: 2),
                            ),
                            child: IconButton(
                              onPressed: controller.togglePlayPause,
                              icon: Obx(() => Icon(
                                controller.isPlaying.value ? Icons.pause : Icons.play_arrow,
                                size: 30,
                                color: kTeal,
                              )),
                            ),
                          ),
                          IconButton(onPressed: _playNext, icon: const Icon(Icons.skip_next, size: 30, color: kTeal)),
                          IconButton(onPressed: () {}, icon: Image.asset('assets/icons/repeat.png', width: 26, height: 26, color: kTeal)),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _summaryApiMethod() async {
    final episode = controller.podcastResponse.value;
    final audioUrl = episode?.audioUrl;

    if (audioUrl == null || audioUrl.isEmpty) {
      Get.snackbar("Error", "No audio available for summary", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final success = await audioSummaryApiController.audioSummaryApiController(audioUrl);
    if (success) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => PodcastDescriptionScreen(urls: audioUrl)));
    }
  }
}

// WaveformProgressBar unchanged — রেখে দে

// WaveformProgressBar (Unchanged)
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
        final activeCount = (progress * barCount).clamp(0, barCount.toDouble()).floor();

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
