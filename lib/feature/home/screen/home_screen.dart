/*
// lib/feature/home/screen/home_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/app_colors.dart';
import '../../choose interest/controller/choose_interest_api_controller.dart';
import '../../media/audio/screen/audio_play.dart';
import '../controller/home_controller.dart';
import '../widget/audio_image_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ChooseInterestApiController controller = Get.put(ChooseInterestApiController());
 // final HomeController controller=Get.put(HomeController());

  bool isVideo = false;
  int selectedIndex = 0;
  List<String> categories = [];
  String _currentCategory = "Business";

  late Worker _episodesWorker; // Store the ever() listener

  @override
  void initState() {
    super.initState();


    // Listen to episodes update → rebuild categories
    _episodesWorker = ever(controller.episodes, (_) {
      if (!mounted) return; // Critical: Prevent setState after dispose
      _updateCategories();
    });

    // Load default category
    _loadEpisodesForCategory(_currentCategory);
  }

  @override
  void dispose() {
    _episodesWorker.dispose(); // Critical: Cancel ever() listener
    super.dispose();
  }

  void _updateCategories() {
    final Set<String> uniqueTitles = {};
    for (var ep in controller.episodes) {
      final title = ep.podcast?.titleOriginal ?? "Unknown";
      uniqueTitles.add(title.split(" ").take(3).join(" "));
    }
    final newCategories = uniqueTitles.take(8).toList();

    if (!mounted) return;

    setState(() {
      categories = newCategories;
      if (categories.isNotEmpty && !categories.contains(_currentCategory)) {
        _currentCategory = categories.first;
        selectedIndex = 0;
      } else if (categories.isNotEmpty) {
        selectedIndex = categories.indexOf(_currentCategory).clamp(0, categories.length - 1);
      }
    });
  }

  Future<void> _loadEpisodesForCategory(String category) async {
    _currentCategory = category;

    controller.episodes.assignAll([]);
    controller.isLoading.value = true;
    controller.errorMessage.value = "";

    try {
      await controller.chooseInterestApiMethod(interest: category);
    } catch (e) {
      if (mounted) {
        controller.errorMessage.value = "Failed to load";
      }
    } finally {
      if (mounted) {
        controller.isLoading.value = false;
      }
    }
  }

  Future<void> _onRefresh() async {
    await _loadEpisodesForCategory(_currentCategory);
  }

  String _formatDate(int? timestampMs) {
    if (timestampMs == null) return "Unknown";
    return DateFormat('MMM dd, yyyy').format(DateTime.fromMillisecondsSinceEpoch(timestampMs));
  }

  String _formatDuration(int? seconds) {
    if (seconds == null) return "";
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return "${mins}m ${secs}s";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFF3),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Header: Logo + Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 58,
                    height: 58,
                    child: Image.asset("assets/icons/linly-high-resolution-logo 1.png"),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => setState(() => isVideo = !isVideo),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 120,
                      height: 45,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: isVideo ? Alignment.centerLeft : Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                isVideo ? "List" : "Grid",
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          AnimatedAlign(
                            duration: const Duration(milliseconds: 300),
                            alignment: isVideo ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Category Buttons
            Obx(() {
              if (categories.isEmpty && controller.isLoading.value) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                );
              }

              if (categories.isEmpty) {
                return const SizedBox.shrink();
              }

              return SizedBox(
                height: 45,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final isSelected = selectedIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedIndex = index);
                        _loadEpisodesForCategory(categories[index]);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary, width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            categories[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),

            const SizedBox(height: 12),

            // Main Content + PULL TO REFRESH
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: Obx(() {
                  if (controller.isLoading.value && controller.episodes.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }

                  if (controller.errorMessage.isNotEmpty && !controller.isLoading.value) {
                    return Center(
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 100),
                          const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            "No internet connection",
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Pull down to retry",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  if (controller.episodes.isEmpty) {
                    return Center(
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 100),
                          Icon(Icons.podcasts, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text("No podcasts available", style: TextStyle(color: Colors.grey, fontSize: 16)),
                          SizedBox(height: 8),
                          Text("Pull down to refresh", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  return isVideo ? _buildVideoList() : _buildAudioGrid();
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: controller.episodes.length,
      itemBuilder: (context, i) {
        final ep = controller.episodes[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AudioImageWidget(
            title: ep.titleOriginal ?? "Untitled",
            subTitle: "${_formatDuration(ep.audioLengthSec)} • ${ep.podcast?.publisherOriginal ?? ""}",
            date: _formatDate(ep.pubDateMs),
            episodes: "Episodes: 13",
            imageUrl: ep.thumbnail ?? ep.image ?? "https://via.placeholder.com/327x144",
            onTap: () {
              Get.to(() => MusicPlayerScreen(
                episodeIds: [ep.id.toString()],
                currentId: ep.id.toString(),
              ));
            },
          ),
        );
      },
    );
  }

  Widget _buildAudioGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: controller.episodes.length,
      itemBuilder: (context, i) {
        final ep = controller.episodes[i];
        return AudioImageWidget(
          title: ep.titleOriginal ?? "Untitled",
          subTitle: "${_formatDuration(ep.audioLengthSec)} • ${ep.podcast?.publisherOriginal ?? ""}",
          date: _formatDate(ep.pubDateMs),
          episodes: "Episodes: 13",
          imageUrl: ep.thumbnail ?? ep.image ?? "https://via.placeholder.com/327x144",
          onTap: () {
            Get.to(() => MusicPlayerScreen(
              episodeIds: [ep.id.toString()],
              currentId: ep.id.toString(),
            ));
          },
        );
      },
    );
  }
}*//*

// lib/feature/home/screen/home_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/app_colors.dart';
import '../../media/audio/screen/audio_play.dart';
import '../controller/home_controller.dart';        // ← নতুন কন্ট্রোলার
import '../widget/audio_image_widget.dart';           // ← তোমার পুরাতন উইজেট (যেটা আগেও ছিল)

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // শুধু নতুন HomeController ব্যবহার করবো
  final HomeController controller = Get.put(HomeController());

  bool isGrid = true; // true = Grid, false = List

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFF3),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Header: Logo + Grid/List Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                SizedBox(
                width: 58,
                height: 58,
                child: Image.asset("assets/icons/linly-high-resolution-logo 1.png"),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => setState(() => isGrid = !isGrid),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 120,
                    height: 45,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Stack(
                      children: [
                        AnimatedAlign(
                          duration: const Duration(milliseconds: 300),
                          alignment: isGrid ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            width: 50,
                            height: 35,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        Center(
                          child: Row(

                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text("Grid", style: TextStyle(color: isGrid ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
                              Text("List", style: TextStyle(color: isGrid ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Main Content + Pull to Refresh + Infinite Scroll
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.onRefresh,
                child: Obx(() {
                  // First time loading
                  if (controller.isLoading.value && controller.podcasts.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }

                  // Error
                  if (controller.errorMessage.isNotEmpty) {
                    return _buildErrorView();
                  }

                  // Empty
                  if (controller.podcasts.isEmpty) {
                    return _buildEmptyView();
                  }

                  // Success → Show podcasts using your old AudioImageWidget
                  return isGrid ? _buildGridView() : _buildListView();
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== Grid View (using your old widget) ==========
  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: controller.podcasts.length + (controller.hasMoreData.value ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == controller.podcasts.length) {
          controller.loadMore();
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final podcast = controller.podcasts[index];

        return AudioImageWidget(
          title: podcast.name ?? "Unknown Podcast",
          subTitle: "${podcast.description ?? ""} description",
          date: podcast.releaseDate ?? "",
          episodes: "${podcast.episodeCount ?? 0} episodes",
          imageUrl: podcast.imageUrl ?? "https://via.placeholder.com/300",
          onTap: () {
            Get.to(() => MusicPlayerScreen(
              episodeUrls: [podcast.feedUrl.toString()],
              currentTopic: podcast.name.toString(),
            ));
            Get.snackbar("Info", "Podcast details coming soon!");
          },
        );
      },
    );
  }

  // ========== List View (using your old widget) ==========
  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.podcasts.length + (controller.hasMoreData.value ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == controller.podcasts.length) {
          controller.loadMore();
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        final podcast = controller.podcasts[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AudioImageWidget(
            title: podcast.name ?? "Unknown Podcast",
            subTitle: "${podcast.description ?? ""} description • ${podcast.country ?? ""}",
            date: podcast.releaseDate ?? "",
            episodes: "${podcast.episodeCount ?? 0} episodes",
            imageUrl: podcast.imageUrl ?? "https://via.placeholder.com/300",
            onTap: () {
              Get.to(() => MusicPlayerScreen(
                episodeUrls: [podcast.feedUrl.toString()],
                currentTopic: podcast.name.toString(),
              ));
              Get.snackbar("Info", "Podcast details coming soon!");
            },
          ),
        );
      },
    );
  }

  // ========== Error & Empty States ==========
  Widget _buildErrorView() {
    return Center(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 100),
          const Icon(Icons.wifi_off, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(controller.errorMessage.value, textAlign: TextAlign.center),
          const Text("Pull down to retry", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 100),
          Icon(Icons.podcasts_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text("No podcasts found", style: TextStyle(fontSize: 16, color: Colors.grey)),
          Text("Pull down to refresh", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}*/
