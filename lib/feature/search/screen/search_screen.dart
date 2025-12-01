// lib/feature/search/ui/search_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/app_colors.dart';
import '../../home/widget/audio_image_widget.dart';
import '../../media/audio/screen/audio_play.dart';
import '../controller/searching_api_controller.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SearchingApiController apiCtrl = Get.put(SearchingApiController());

  bool isListView = true;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      final query = _searchController.text.trim();
      if (query.isEmpty) {

        apiCtrl.clearResults();

        apiCtrl.clearResults(); // সার্চ ক্লিয়ার হলে রেজাল্ট মুছে ফেলো
      } else {
        _searchInApi(query);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchInApi(String query) async {
    if (query.isEmpty) return;
    await apiCtrl.searchingApiMethod(interest: query, loadMore: false);
  }

  Future<void> _onRefresh() async {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      await _searchInApi(query);
    }
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return "Unknown date";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFF3),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // SEARCH BAR + LIST/GRID TOGGLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9E9DC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (value) => _searchInApi(value.trim()),
                        decoration: InputDecoration(
                          hintText: "Search audios…",
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          prefixIcon: Icon(Icons.search, color: AppColors.primary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => setState(() => isListView = !isListView),
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
                            alignment: isListView ? Alignment.centerLeft : Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                isListView ? "List" : "Grid",
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          AnimatedAlign(
                            duration: const Duration(milliseconds: 300),
                            alignment: isListView ? Alignment.centerRight : Alignment.centerLeft,
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

            // MAIN CONTENT AREA
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: Obx(() {
                  final query = _searchController.text.trim();

                  // 1. প্রথমবার লোডিং (এবং এখনো কোনো রেজাল্ট নাই)
                  if (apiCtrl.isLoading.value && apiCtrl.episodes.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // 2. এরর থাকলে
                  if (apiCtrl.errorMessage.isNotEmpty) {
                    return _buildErrorWidget();
                  }

                  // 3. সার্চ বক্স খালি → কিছুই দেখাবো না (এটাই তুমি চেয়েছ!)
                  if (query.isEmpty) {
                    return const SizedBox.shrink(); // পুরোপুরি ফাঁকা
                  }

                  // 4. সার্চ করা হয়েছে কিন্তু কোনো রেজাল্ট নাই
                  if (apiCtrl.episodes.isEmpty) {
                    return _buildNoResultsWidget(query);
                  }

                  // 5. রেজাল্ট আছে → লিস্ট বা গ্রিড দেখাও
                  return isListView ? _buildListView() : _buildGridView();
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - UI Widgets

  Widget _buildErrorWidget() {
    return Center(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 100),
          Icon(Icons.wifi_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text("No internet connection", style: TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
          SizedBox(height: 8),
          Text("Pull down to retry", style: TextStyle(color: Colors.grey, fontSize: 14), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildNoResultsWidget(String query) {
    return Center(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 100),
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text('"${query}"', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          const Text("No results found", style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text("Try different keywords", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: apiCtrl.episodes.length + (apiCtrl.hasMore.value ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == apiCtrl.episodes.length) {
          apiCtrl.loadNextPage();
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final podcast = apiCtrl.episodes[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AudioImageWidget(
            title: podcast.name,
            subTitle: "${podcast.formattedDuration} • ${podcast.episodeCount} episodes",
            date: _formatDate(podcast.releaseDate),
            episodes: "${podcast.episodeCount} episodes",
            imageUrl: podcast.imageUrl.isNotEmpty
                ? podcast.imageUrl
                : "https://via.placeholder.com/300",
            onTap: () => Get.to(() => MusicPlayerScreen(
              episodeUrls: [podcast.feedUrl],
              currentTopic: podcast.name,
            )),
          ),
        );
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: apiCtrl.episodes.length + (apiCtrl.hasMore.value ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == apiCtrl.episodes.length) {
          apiCtrl.loadNextPage();
          return const Center(child: CircularProgressIndicator());
        }
        final podcast = apiCtrl.episodes[i];
        return AudioImageWidget(
          title: podcast.name,
          subTitle: "${podcast.formattedDuration} • ${podcast.episodeCount} eps",
          date: _formatDate(podcast.releaseDate),
          episodes: "${podcast.episodeCount} eps",
          imageUrl: podcast.imageUrl.isNotEmpty
              ? podcast.imageUrl
              : "https://via.placeholder.com/300",
          onTap: () => Get.to(() => MusicPlayerScreen(
            episodeUrls: [podcast.feedUrl],
            currentTopic: podcast.name,
          )),
        );
      },
    );
  }
}