/*
import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'dart:math' as math;

import 'package:naomithedose/core/widgets/custom_appbar.dart';
import 'package:naomithedose/feature/media/audio/screen/description_screen.dart';
import '../controller/audio_paly_api_controller.dart';
import '../controller/audio_summary_api_controller.dart';
import '../controller/search_text_api_controller.dart';

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
  late final AudioPlayApiControllers audioController;
  late final SearchTextApiController searchTextController;

  final AudioSummaryApiController audioSummaryApiController = Get.put(AudioSummaryApiController());

  int currentIndex = 0;
  String currentUrl = '';

  @override
  void initState() {
    super.initState();

    // 1. Audio Controller
    audioController = Get.isRegistered<AudioPlayApiControllers>()
        ? Get.find<AudioPlayApiControllers>()
        : Get.put(AudioPlayApiControllers());

    // 2. Search Text Controller
    searchTextController = Get.isRegistered<SearchTextApiController>()
        ? Get.find<SearchTextApiController>()
        : Get.put(SearchTextApiController());

    // Load first episode
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

  // Main Load Episode → First Audio → Then Search Text
  Future<void> _loadEpisode(String url, String topic) async {
    if (url.isEmpty) return;

    currentUrl = url;
    print('Loading Podcast URL: $url | Topic: $topic');

    // Step 1: Load & Play Audio
    await audioController.audioPlayApiMethod(url, topic);

    // Step 2: After audio loads → Get job_id and call Search Text API
    final episodeResponse = audioController.podcastResponse.value;
    final jobId = episodeResponse?.jobId;

    if (jobId != null && jobId.isNotEmpty) {
      print("Job ID found: $jobId → Calling Search Text API");
      await searchTextController.fetchTranscription( jobId);
    } else {
      print("No job_id found. Transcription might not be ready yet.");
    }
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
              // Dynamic Title from Audio Controller
              Obx(() {
                final episode = audioController.podcastResponse.value;
                final title = episode?.title ?? 'Loading...';
                return CustomAppBar(title: Text(title));
              }),

              const SizedBox(height: 5),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Audio Loading
                      Obx(() => audioController.isLoading.value
                          ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(color: kTeal),
                      )
                          : const SizedBox()),

                      // Audio Error
                      Obx(() => audioController.errorMessage.value != null
                          ? Text(audioController.errorMessage.value!, style: const TextStyle(color: Colors.red))
                          : const SizedBox()),

                      // Album Art
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Obx(() {
                          final imageUrl = audioController.podcastResponse.value?.imageUrl ?? '';
                          return Image.network(
                            imageUrl,
                            width: 300,
                            height: 320,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) => progress == null
                                ? child
                                : Container(color: kTeal.withOpacity(0.1), child: const Center(child: CircularProgressIndicator(color: kTeal))),
                            errorBuilder: (_, __, ___) => Container(
                              width: 300,
                              height: 320,
                              color: kTeal.withOpacity(0.1),
                              child: const Icon(Icons.podcasts, size: 80, color: kTeal),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 30),

                      // Title + Description
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Obx(() {
                                final episode = audioController.podcastResponse.value;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      episode?.title ?? 'Unknown Episode',
                                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      episode?.description ?? 'No description',
                                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                );
                              }),
                            ),
                            IconButton(
                              onPressed: _summaryApiMethod,
                              icon: Image.asset('assets/icons/menu.png', width: 26, height: 26, color: kTeal),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Progress Bar
                      Obx(() {
                        final durSec = audioController.duration.value.inSeconds;
                        final posSec = audioController.position.value.inSeconds;
                        final progress = durSec > 0 ? posSec / durSec : 0.0;

                        return Column(
                          children: [
                            WaveformProgressBar(
                              progress: progress,
                              onChanged: audioController.seekTo,
                              activeColor: kTeal,
                              inactiveColor: kTeal.withOpacity(0.25),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_format(posSec), style: const TextStyle(color: Colors.grey)),
                                Text(_format(durSec), style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ],
                        );
                      }),

                      const SizedBox(height: 30),

                      // Player Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(onPressed: () {}, icon: Image.asset('assets/icons/shuffle.png', width: 26, height: 26, color: kTeal)),
                          IconButton(onPressed: _playPrevious, icon: const Icon(Icons.skip_previous, size: 30, color: kTeal)),
                          Container(
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: kTeal, width: 2)),
                            child: IconButton(
                              onPressed: audioController.togglePlayPause,
                              icon: Obx(() => Icon(audioController.isPlaying.value ? Icons.pause : Icons.play_arrow, size: 30, color: kTeal)),
                            ),
                          ),
                          IconButton(onPressed: _playNext, icon: const Icon(Icons.skip_next, size: 30, color: kTeal)),
                          IconButton(onPressed: () {}, icon: Image.asset('assets/icons/repeat.png', width: 26, height: 26, color: kTeal)),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Search Result Box (from SearchTextApiControllers)
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text("Key Information Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 10),

                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300, width: 1.5),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Obx(() {
                            // Loading state
                            if (searchTextController.isLoading.value) {
                              return const Center(child: CircularProgressIndicator(color: kTeal));
                            }

                            final result = searchTextController.transcriptionResult.value;

                            // No result yet, or summary is empty
                            if (result == null || result.combinedSummary == null || result.combinedSummary!.trim().isEmpty) {
                              return const Text(
                                "Summary is being generated... Please wait",
                                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                                textAlign: TextAlign.center,
                              );
                            }

                            final String summary = result.combinedSummary!.trim();

                            // ──────────────────────────────────────────────────────────────
                            // Detect incomplete/truncated summary
                            // ──────────────────────────────────────────────────────────────
                            bool isTruncated = false;
                            if (summary.length < 200) { // Heuristic: very short for a full summary
                              isTruncated = true;
                            } else if (!RegExp(r'[.!?…]$').hasMatch(summary.trim())) {
                              // Doesn't end with proper punctuation
                              isTruncated = true;
                            }

                            // Show the summary (full or partial)
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  summary,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.6,
                                    color: Colors.black87,
                                  ),
                                ),

                               */
/* // Show warning if summary is incomplete
                                if (isTruncated) ...[
                                  const SizedBox(height: 20),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      border: Border.all(
                                        color: Colors.orange.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.warning_amber_rounded,
                                          color: Colors.orange.shade700,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "Summary appears incomplete. We are regenerating it...",
                                            style: TextStyle(
                                              color: Colors.orange.shade800,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],*//*

                              ],
                            );
                          }),
                        ),
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

  // Summary Button (old one)
  Future<void> _summaryApiMethod() async {
    final audioUrl = audioController.podcastResponse.value?.audioUrl;
    if (audioUrl == null || audioUrl.isEmpty) {
      Get.snackbar("Error", "Audio not ready", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    final success = await audioSummaryApiController.audioSummaryApiController(audioUrl);
    if (success) {
      //Get.to(() => PodcastDescriptionScreen(urls: audioUrl));
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
}*/
import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'dart:math' as math;
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:naomithedose/core/widgets/custom_appbar.dart';
import 'package:naomithedose/feature/media/audio/screen/description_screen.dart';
import '../controller/audio_paly_api_controller.dart';
import '../controller/audio_summary_api_controller.dart';
import '../controller/search_text_api_controller.dart';

const kTeal = Color(0xFF39CCCC);

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({
    super.key,
    this.episodeUrls,
    this.currentTopic = 'general',
    this.Id,
  });

  final List<String>? episodeUrls;
  final String currentTopic;
  final String? Id;

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  late final AudioPlayApiControllers audioController;
  late final SearchTextApiController searchTextController;
  final AudioSummaryApiController audioSummaryApiController = Get.put(AudioSummaryApiController());

  int currentIndex = 0;
  String currentUrl = '';

  @override
  void initState() {
    super.initState();
    audioController = Get.isRegistered<AudioPlayApiControllers>()
        ? Get.find<AudioPlayApiControllers>()
        : Get.put(AudioPlayApiControllers());
    searchTextController = Get.isRegistered<SearchTextApiController>()
        ? Get.find<SearchTextApiController>()
        : Get.put(SearchTextApiController());

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

  Future<void> _loadEpisode(String url, String topic) async {
    if (url.isEmpty) return;
    currentUrl = url;
    await audioController.audioPlayApiMethod(url, topic);
    final jobId = audioController.podcastResponse.value?.jobId;
    if (jobId != null && jobId.isNotEmpty) {
      await searchTextController.fetchTranscription(jobId);
    }
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
              // Dynamic Title in AppBar
              Obx(() {
                final episode = audioController.podcastResponse.value;
                return CustomAppBar(title: Text(episode?.title ?? 'Loading...'));
              }),
              const SizedBox(height: 10),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Loading Indicator
                      Obx(() => audioController.isLoading.value
                          ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(color: kTeal),
                      )
                          : const SizedBox()),

                      // Error Message
                      Obx(() => audioController.errorMessage.value != null && audioController.errorMessage.value!.isNotEmpty
                          ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          audioController.errorMessage.value!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                          : const SizedBox()),

                      // Album Art
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Obx(() {
                          final imageUrl = audioController.podcastResponse.value?.imageUrl ?? '';
                          return Image.network(
                            imageUrl,
                            width: 300,
                            height: 320,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) => progress == null
                                ? child
                                : Container(
                              color: kTeal.withOpacity(0.1),
                              child: const Center(child: CircularProgressIndicator(color: kTeal)),
                            ),
                            errorBuilder: (_, __, ___) => Container(
                              width: 300,
                              height: 320,
                              color: kTeal.withOpacity(0.1),
                              child: const Icon(Icons.podcasts, size: 80, color: kTeal),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 30),

                      // Title + Expandable Description (Max 3 lines)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Obx(() {
                                final episode = audioController.podcastResponse.value;
                                final String title = episode?.title ?? 'Unknown Episode';
                                final String descriptionHtml = episode?.description ?? '';

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 12),

                                    // Description: 3 lines max + See more
                                    if (descriptionHtml.trim().isEmpty || descriptionHtml == '<p><br></p>')
                                      const Text('No description available', style: TextStyle(color: Colors.grey))
                                    else
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          final bool isLongDescription = descriptionHtml.length > 300;

                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 72, // Approx 3 lines
                                                child: Html(
                                                  data: descriptionHtml,
                                                  style: {
                                                    "body": Style(
                                                      fontSize: FontSize(14),
                                                      color: Colors.grey[700],
                                                      margin: Margins.zero,
                                                      padding: HtmlPaddings.zero,
                                                    ),
                                                    "p": Style(margin: Margins(top: Margin(6), bottom: Margin(6))),
                                                    "a": Style(color: kTeal, textDecoration: TextDecoration.underline),
                                                  },
                                                  onLinkTap: (url, _, __) => url != null ? launchUrlString(url) : null,
                                                ),
                                              ),

                                              // See more button (only if content is long)
                                              if (isLongDescription)
                                                GestureDetector(
                                                  onTap: () {
                                                    Get.dialog(
                                                      Dialog(
                                                        backgroundColor: const Color(0xffFFFFF3),
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(20.0),
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                                              const SizedBox(height: 16),
                                                              SingleChildScrollView(
                                                                child: Html(
                                                                  data: descriptionHtml,
                                                                  style: {
                                                                    "body": Style(fontSize: FontSize(15), color: Colors.black87),
                                                                    "a": Style(color: kTeal, textDecoration: TextDecoration.underline),
                                                                  },
                                                                  onLinkTap: (url, _, __) => url != null ? launchUrlString(url) : null,
                                                                ),
                                                              ),
                                                              const SizedBox(height: 20),
                                                              ElevatedButton(
                                                                onPressed: () => Get.back(),
                                                                style: ElevatedButton.styleFrom(backgroundColor: kTeal),
                                                                child: const Text("Close", style: TextStyle(color: Colors.white)),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(top: 8),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: const [
                                                        Text("See more", style: TextStyle(color: kTeal, fontWeight: FontWeight.w600, fontSize: 14)),
                                                        SizedBox(width: 4),
                                                        Icon(Icons.keyboard_arrow_down_rounded, color: kTeal, size: 22),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          );
                                        },
                                      ),
                                  ],
                                );
                              }),
                            ),

                            // Menu Icon Button
                            IconButton(
                              onPressed: _summaryApiMethod,
                              icon: Image.asset('assets/icons/menu.png', width: 26, height: 26, color: kTeal),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Progress Bar
                      Obx(() {
                        final durSec = audioController.duration.value.inSeconds;
                        final posSec = audioController.position.value.inSeconds;
                        final progress = durSec > 0 ? posSec / durSec : 0.0;
                        return Column(
                          children: [
                            WaveformProgressBar(
                              progress: progress,
                              onChanged: audioController.seekTo,
                              activeColor: kTeal,
                              inactiveColor: kTeal.withOpacity(0.25),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_format(posSec), style: const TextStyle(color: Colors.grey)),
                                Text(_format(durSec), style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 30),

                      // Player Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(onPressed: () {}, icon: Image.asset('assets/icons/shuffle.png', width: 26, height: 26, color: kTeal)),
                          IconButton(onPressed: _playPrevious, icon: const Icon(Icons.skip_previous, size: 30, color: kTeal)),
                          Container(
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: kTeal, width: 2)),
                            child: IconButton(
                              onPressed: audioController.togglePlayPause,
                              icon: Obx(() => Icon(audioController.isPlaying.value ? Icons.pause : Icons.play_arrow, size: 30, color: kTeal)),
                            ),
                          ),
                          IconButton(onPressed: _playNext, icon: const Icon(Icons.skip_next, size: 30, color: kTeal)),
                          IconButton(onPressed: () {}, icon: Image.asset('assets/icons/repeat.png', width: 26, height: 26, color: kTeal)),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // Key Information Summary with **bold** highlighting
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text("Key Information Summary", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300, width: 1.5),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                          ),
                          child: Obx(() {
                            if (searchTextController.isLoading.value) {
                              return const Center(child: CircularProgressIndicator(color: kTeal));
                            }
                            final result = searchTextController.transcriptionResult.value;
                            if (result == null || result.combinedSummary == null || result.combinedSummary!.trim().isEmpty) {
                              return const Text(
                                "Summary is being generated... Please wait",
                                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 15),
                                textAlign: TextAlign.center,
                              );
                            }

                            final String rawSummary = result.combinedSummary!.trim();

                            List<TextSpan> buildHighlightedSpans(String text) {
                              List<TextSpan> spans = [];
                              RegExp boldRegex = RegExp(r'\*\*([^*]+)\*\*');
                              int lastEnd = 0;

                              for (var match in boldRegex.allMatches(text)) {
                                if (match.start > lastEnd) {
                                  spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
                                }
                                spans.add(TextSpan(
                                  text: match.group(1),
                                  style: const TextStyle(color: kTeal, fontWeight: FontWeight.bold, fontSize: 15.5),
                                ));
                                lastEnd = match.end;
                              }
                              if (lastEnd < text.length) {
                                spans.add(TextSpan(text: text.substring(lastEnd)));
                              }
                              return spans;
                            }

                            return RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 15.5, height: 1.7, color: Colors.black87),
                                children: buildHighlightedSpans(rawSummary),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 40),
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
    final audioUrl = audioController.podcastResponse.value?.audioUrl;
    if (audioUrl == null || audioUrl.isEmpty) {
      Get.snackbar("Error", "Audio not ready", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    final success = await audioSummaryApiController.audioSummaryApiController(audioUrl);
    if (success) {
      // Get.to(() => PodcastDescriptionScreen(urls: audioUrl));
    }
  }
}

// Waveform Progress Bar (unchanged)
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
                  decoration: BoxDecoration(shape: BoxShape.circle, color: activeColor),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}