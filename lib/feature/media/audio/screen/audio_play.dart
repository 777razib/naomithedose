import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'dart:math' as math;
import 'package:flutter_html/flutter_html.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:naomithedose/core/widgets/custom_appbar.dart';
import '../controller/audio_paly_api_controller.dart';
import '../controller/audio_summary_api_controller.dart';
import '../controller/search_text_api_controller.dart';
import '../widget/feature_item_widget.dart';

const kTeal = Color(0xFF39CCCC);

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({
    super.key,
    this.episodeUrls,
    this.currentTopic,
    this.Id,
  });

  final List<String>? episodeUrls;
  final String? currentTopic;
  final String? Id;

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  final features = [
    "Analyze the podcast",
    "Transcribe the podcast",
    "Find the relevant topics",
    "Create a summary",
  ];
  late final AudioPlayController audioController;
  late final SearchTextApiController searchTextController;
  final AudioSummaryApiController audioSummaryApiController = Get.put(
    AudioSummaryApiController(),
  );

  int currentIndex = 0;
  String currentUrl = '';

  @override
  void initState() {
    super.initState();
    audioController = Get.isRegistered<AudioPlayController>()
        ? Get.find<AudioPlayController>()
        : Get.put(AudioPlayController());
    searchTextController = Get.isRegistered<SearchTextApiController>()
        ? Get.find<SearchTextApiController>()
        : Get.put(SearchTextApiController());

    final urls = widget.episodeUrls ?? [];
    final topic = widget.currentTopic ?? '';
    if (urls.isNotEmpty) {
      currentIndex = 0;
      currentUrl = urls.first;
      _loadEpisode(currentUrl, topic);
    } else if (widget.Id != null && widget.Id!.isNotEmpty) {
      currentUrl = widget.Id!;
      print("------topic-----${widget.currentTopic}");
      _loadEpisode(currentUrl, topic);
    } else {
      Get.back();
    }
  }

  Future<void> _loadEpisode(String url, String topic) async {
    if (url.isEmpty) return;
    currentUrl = url;
    await audioController.loadPodcastEpisode(url, topic);
    final jobId = audioController.podcastResponse.value?.jobId;

    debugPrint("----------topic----------$topic");
    if (jobId != null && jobId.isNotEmpty) {
      debugPrint("J+++++++++++++ob ID: $jobId");
      await searchTextController.fetchTranscription(jobId);
    }
  }

  Future<void> _playNext() async {
    final urls = widget.episodeUrls ?? [];
    final topic = widget.currentTopic ?? '';

    if (urls.isEmpty || currentIndex >= urls.length - 1) return;
    currentIndex++;
    await _loadEpisode(urls[currentIndex], topic);
  }

  Future<void> _playPrevious() async {
    final urls = widget.episodeUrls ?? [];
    final topic = widget.currentTopic ?? '';

    if (urls.isEmpty || currentIndex <= 0) return;
    currentIndex--;
    await _loadEpisode(urls[currentIndex], topic);
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
                return CustomAppBar(
                  title: Text(episode?.title ?? 'Loading...'),
                );
              }),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Loading Indicator
                      Obx(
                        () => audioController.isLoading.value
                            ? const Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(color: kTeal),
                              )
                            : const SizedBox(),
                      ),
                      // Error Message
                      Obx(
                        () =>
                            audioController.errorMessage.value != null &&
                                audioController.errorMessage.value!.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Text(
                                  audioController.errorMessage.value!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              )
                            : const SizedBox(),
                      ),

                      // Album Art
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Obx(() {
                          final imageUrl =
                              audioController.podcastResponse.value?.imageUrl ??
                              '';
                          return Image.network(
                            imageUrl,
                            width: 300,
                            height: 320,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) =>
                                progress == null
                                ? child
                                : Container(
                                    color: kTeal.withOpacity(0.1),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: kTeal,
                                      ),
                                    ),
                                  ),
                            errorBuilder: (_, __, ___) => Container(
                              width: 300,
                              height: 320,
                              color: kTeal.withOpacity(0.1),
                              child: const Icon(
                                Icons.podcasts,
                                size: 80,
                                color: kTeal,
                              ),
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
                                final episode =
                                    audioController.podcastResponse.value;
                                final String title =
                                    episode?.title ?? 'Unknown Episode';
                                final String descriptionHtml =
                                    episode?.description ?? '';

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 12),

                                    // Description: 3 lines max + See more
                                    if (descriptionHtml.trim().isEmpty ||
                                        descriptionHtml == '<p><br></p>')
                                      const Text(
                                        'No description available',
                                        style: TextStyle(color: Colors.grey),
                                      )
                                    else
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          final bool isLongDescription =
                                              descriptionHtml.length > 300;

                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                                      padding:
                                                          HtmlPaddings.zero,
                                                    ),
                                                    "p": Style(
                                                      margin: Margins(
                                                        top: Margin(6),
                                                        bottom: Margin(6),
                                                      ),
                                                    ),
                                                    "a": Style(
                                                      color: kTeal,
                                                      textDecoration:
                                                          TextDecoration
                                                              .underline,
                                                    ),
                                                  },
                                                  onLinkTap: (url, _, __) =>
                                                      url != null
                                                      ? launchUrlString(url)
                                                      : null,
                                                ),
                                              ),

                                              if (isLongDescription)
                                                GestureDetector(
                                                  onTap: () {
                                                    Get.dialog(
                                                      Dialog(
                                                        backgroundColor:
                                                            const Color(
                                                              0xffFFFFF3,
                                                            ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                20,
                                                              ),
                                                        ),
                                                        insetPadding:
                                                            const EdgeInsets.all(
                                                              20,
                                                            ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                20.0,
                                                              ),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              // Title
                                                              Text(
                                                                title,
                                                                style: const TextStyle(
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 16,
                                                              ),

                                                              // এখানে Flexible + Expanded দিয়ে scrollable area বানানো হলো
                                                              Flexible(
                                                                child: SingleChildScrollView(
                                                                  physics:
                                                                      const BouncingScrollPhysics(),
                                                                  // সুন্দর স্ক্রল
                                                                  child: Html(
                                                                    data:
                                                                        descriptionHtml,
                                                                    style: {
                                                                      "body": Style(
                                                                        fontSize:
                                                                            FontSize(
                                                                              15,
                                                                            ),
                                                                        color: Colors
                                                                            .black87,
                                                                      ),
                                                                      "a": Style(
                                                                        color:
                                                                            kTeal,
                                                                        textDecoration:
                                                                            TextDecoration.underline,
                                                                      ),
                                                                    },
                                                                    onLinkTap: (url, _, __) {
                                                                      if (url !=
                                                                          null)
                                                                        launchUrlString(
                                                                          url,
                                                                        );
                                                                    },
                                                                  ),
                                                                ),
                                                              ),

                                                              const SizedBox(
                                                                height: 20,
                                                              ),

                                                              // Close Button
                                                              SizedBox(
                                                                width: double
                                                                    .infinity,
                                                                child: ElevatedButton(
                                                                  onPressed: () =>
                                                                      Get.back(),
                                                                  style: ElevatedButton.styleFrom(
                                                                    backgroundColor:
                                                                        kTeal,
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            12,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  child: const Text(
                                                                    "Close",
                                                                    style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      barrierDismissible:
                                                          true, // বাইরে ট্যাপ করেও বন্ধ করা যাবে
                                                    );
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          top: 8,
                                                        ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: const [
                                                        Text(
                                                          "See more",
                                                          style: TextStyle(
                                                            color: kTeal,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        SizedBox(width: 4),
                                                        Icon(
                                                          Icons
                                                              .keyboard_arrow_down_rounded,
                                                          color: kTeal,
                                                          size: 22,
                                                        ),
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
                              icon: Image.asset(
                                'assets/icons/menu.png',
                                width: 26,
                                height: 26,
                                color: kTeal,
                              ),
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
                                Text(
                                  _format(posSec),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  _format(durSec),
                                  style: const TextStyle(color: Colors.grey),
                                ),
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
                          //IconButton(onPressed: () {}, icon: Image.asset('assets/icons/shuffle.png', width: 26, height: 26, color: kTeal)),
                          // IconButton(onPressed: _playPrevious, icon: const Icon(Icons.skip_previous, size: 30, color: kTeal)),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: kTeal, width: 2),
                            ),
                            child: IconButton(
                              onPressed: audioController.togglePlayPause,
                              icon: Obx(
                                () => Icon(
                                  audioController.isPlaying.value
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  size: 30,
                                  color: kTeal,
                                ),
                              ),
                            ),
                          ),
                          // IconButton(onPressed: _playNext, icon: const Icon(Icons.skip_next, size: 30, color: kTeal)),
                          // IconButton(onPressed: () {}, icon: Image.asset('assets/icons/repeat.png', width: 26, height: 26, color: kTeal)),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // Key Information Summary with **bold** highlighting
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Key Information Summary",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1.5,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Obx(() {
                            /*if (searchTextController.isLoading.value) {
                              return const Center(child: CircularProgressIndicator(color: kTeal));
                            }*/ // Inside the Obx() where you show FeaturesSpotlight while loading summary

                            if (searchTextController.isLoading.value) {
                              return Center(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    elevation: 10,
                                    color: Colors.orangeAccent,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Obx(() {
                                            final duration = audioController.duration.value;
                                            final position = audioController.position.value;

                                            final progress = duration.inSeconds > 0
                                                ? (position.inSeconds / duration.inSeconds).clamp(0.0, 1.0)
                                                : 0.0;
                                            print('Progress: $progress | Index: ${(progress * features.length).floor()}');

                                            return FeaturesSpotlight(
                                              features: features,
                                              progress: progress,
                                            );
                                          }),
                                        ),
                                        const SizedBox(width: 10),
                                        Lottie.asset(
                                          "assets/lottie_json/loading_lottie.json",
                                          width: 100,
                                          height: 100,
                                          repeat: true,
                                          animate: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                            final result =
                                searchTextController.transcriptionResult.value;
                            if (result == null ||
                                result.summary == null ||
                                result.summary!.trim().isEmpty) {
                              return const Text(
                                "Summary is being generated... Please wait",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 15,
                                ),
                                textAlign: TextAlign.center,
                              );
                            }

                            final String rawSummary = result.summary!.trim();

                            List<TextSpan> buildHighlightedSpans(String text) {
                              List<TextSpan> spans = [];
                              RegExp boldRegex = RegExp(r'\*\*([^*]+)\*\*');
                              int lastEnd = 0;

                              for (var match in boldRegex.allMatches(text)) {
                                if (match.start > lastEnd) {
                                  spans.add(
                                    TextSpan(
                                      text: text.substring(
                                        lastEnd,
                                        match.start,
                                      ),
                                    ),
                                  );
                                }
                                spans.add(
                                  TextSpan(
                                    text: match.group(1),
                                    style: const TextStyle(
                                      color: kTeal,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.5,
                                    ),
                                  ),
                                );
                                lastEnd = match.end;
                              }
                              if (lastEnd < text.length) {
                                spans.add(
                                  TextSpan(text: text.substring(lastEnd)),
                                );
                              }
                              return spans;
                            }

                            return RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 15.5,
                                  height: 1.7,
                                  color: Colors.black87,
                                ),
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
    final audioUrl = audioController.podcastResponse.value?.rssAudioUrl;
    if (audioUrl == null || audioUrl.isEmpty) {
      Get.snackbar(
        "Error",
        "Audio not ready",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    final success = await audioSummaryApiController.audioSummaryApiController(
      audioUrl,
    );
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
      final v =
          (0.55 +
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
              Row(
                children: List.generate(barCount, (i) {
                  final h = bars[i] * maxBarHeight;
                  final isActive = i < activeCount;
                  return Padding(
                    padding: EdgeInsets.only(
                      right: i == barCount - 1 ? 0 : gap,
                    ),
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
