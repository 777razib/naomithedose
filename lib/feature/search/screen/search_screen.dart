/*
// lib/feature/search/ui/search_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/app_colors.dart';
import '../../home/widget/audio_image_widget.dart';
import '../../media/audio/screen/audio_play.dart';
import '../controller/searching_api_controller.dart'; // ← কন্ট্রোলার

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SearchingApiController apiCtrl = Get.put(SearchingApiController());

  bool isListView = true;
  String _currentQuery = "Business";

  @override
  void initState() {
    super.initState();
    _searchInApi("Business");

    _searchController.addListener(() {
      final query = _searchController.text.trim();
      if (query.isEmpty) {
        _searchInApi("Business");
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
    _currentQuery = query;
    await apiCtrl.searchingApiMethod(interest: query, loadMore: false);
  }

  Future<void> _onRefresh() async {
    await _searchInApi(_currentQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFF3),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // SEARCH BAR + TOGGLE
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
                        onSubmitted: (value) {
                          final query = value.trim();
                          if (query.isNotEmpty) {
                            _searchInApi(query);
                          }
                        },
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

            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: Obx(() {
                  if (apiCtrl.isLoading.value && apiCtrl.episodes.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (apiCtrl.errorMessage.isNotEmpty && !apiCtrl.isLoading.value) {
                    return Center(
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 100),
                          const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text("No internet connection", style: TextStyle(color: Colors.grey, fontSize: 16), textAlign: TextAlign.center),
                          const SizedBox(height: 8),
                          Text("Pull down to retry", style: TextStyle(color: Colors.grey.shade600, fontSize: 14), textAlign: TextAlign.center),
                        ],
                      ),
                    );
                  }

                  if (apiCtrl.episodes.isEmpty) {
                    return Center(
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 100),
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text("No results found", style: TextStyle(color: Colors.grey, fontSize: 16)),
                          SizedBox(height: 8),
                          Text("Try searching something else", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  return isListView ? _buildListView() : _buildGridView();
                }),
              ),
            ),
          ],
        ),
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
          return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()));
        }

        final podcast = apiCtrl.episodes[i];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AudioImageWidget(
            title: podcast.name,
            subTitle: "${podcast.formattedDuration} • ${podcast.episodeCount} episodes",
            date: _formatDate(podcast.releaseDate),
            episodes: "${podcast.episodeCount} episodes",
            imageUrl: podcast.imageUrl.isNotEmpty ? podcast.imageUrl : "https://via.placeholder.com/300",
            onTap: () {
              // আপনার প্লেয়ারে যাওয়ার জন্য podcastId বা feedUrl দিন
              Get.to(() => MusicPlayerScreen(
                episodeUrls: [podcast.feedUrl], // অথবা podcast.itunesUrl
                currentTopic: podcast.name,
              ));
            },
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
          imageUrl: podcast.imageUrl.isNotEmpty ? podcast.imageUrl : "https://via.placeholder.com/300",
          onTap: () {
            print("-----${podcast.feedUrl}");
            print("-----${podcast.name}");
            Get.to(() => MusicPlayerScreen(
              episodeUrls: [podcast.feedUrl],
              currentTopic: podcast.name,
            ));
          },
        );
      },
    );
  }
  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return "Unknown date";
    }
  }
}*/


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

    // কোনো ডিফল্ট সার্চ করবো না
    // শুধু টেক্সট চেঞ্জ হলে সার্চ করবো
    _searchController.addListener(() {
      final query = _searchController.text.trim();
      if (query.isEmpty) {
        apiCtrl.clearResults(); // রেজাল্ট ক্লিয়ার করো
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

            // SEARCH BAR + TOGGLE BUTTON
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
                        onSubmitted: (value) {
                          final query = value.trim();
                          if (query.isNotEmpty) {
                            _searchInApi(query);
                          }
                        },
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
                  final hasSearched = _searchController.text.trim().isNotEmpty;

                  // ১. কেউ এখনো সার্চ করেনি → প্রম্পট দেখাও
                  if (!hasSearched) {
                    return Center(
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.18),
                          Icon(Icons.search, size: 90, color: Colors.grey.shade400),
                          const SizedBox(height: 28),
                          const Text(
                            "Search for podcasts",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Type a topic, name, or keyword above",
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  // ২. লোডিং (প্রথমবার)
                  if (apiCtrl.isLoading.value && apiCtrl.episodes.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // ৩. এরর হয়েছে
                  if (apiCtrl.errorMessage.isNotEmpty && !apiCtrl.isLoading.value) {
                    return Center(
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 100),
                          const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text("No internet connection", style: TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
                          const SizedBox(height: 8),
                          Text("Pull down to retry", style: TextStyle(color: Colors.grey.shade600, fontSize: 14), textAlign: TextAlign.center),
                        ],
                      ),
                    );
                  }

                  // ৪. কোনো রেজাল্ট পাওয়া যায়নি
                  if (apiCtrl.episodes.isEmpty) {
                    return Center(
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 100),
                          const Icon(Icons.search_off, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text('"${_searchController.text}"', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          const Text("No results found", style: TextStyle(fontSize: 16, color: Colors.grey)),
                          const SizedBox(height: 8),
                          const Text("Try different keywords", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  // ৫. সব ঠিক আছে → লিস্ট বা গ্রিড দেখাও
                  return isListView ? _buildListView() : _buildGridView();
                }),
              ),
            ),
          ],
        ),
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
            imageUrl: podcast.imageUrl.isNotEmpty ? podcast.imageUrl : "https://via.placeholder.com/300",
            onTap: () {
              Get.to(() => MusicPlayerScreen(
                episodeUrls: [podcast.feedUrl],
                currentTopic: podcast.name,
              ));
            },
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
          imageUrl: podcast.imageUrl.isNotEmpty ? podcast.imageUrl : "https://via.placeholder.com/300",
          onTap: () {
            Get.to(() => MusicPlayerScreen(
              episodeUrls: [podcast.feedUrl],
              currentTopic: podcast.name,
            ));
          },
        );
      },
    );
  }
}