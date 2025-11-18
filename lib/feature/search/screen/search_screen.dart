// lib/feature/search/ui/search_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/app_colors.dart';
import '../../choose interest/controller/choose_interest_api_controller.dart';
import '../../home/widget/audio_image_widget.dart';
import '../../media/audio/screen/audio_play.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ChooseInterestApiController apiCtrl = Get.put(ChooseInterestApiController());

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
    await apiCtrl.chooseInterestApiMethod(interest: query, loadMore: false);
  }

  // Pull to refresh
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

            // RESULTS + PULL TO REFRESH (NO RETRY BUTTON)
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: Obx(() {
                  // First time loading
                  if (apiCtrl.isLoading.value && apiCtrl.episodes.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Show error only when NOT loading
                  if (apiCtrl.errorMessage.isNotEmpty && !apiCtrl.isLoading.value) {
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

                  // No results
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

                  // Show List or Grid
                  return isListView ? _buildListView() : _buildGridView();
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // LIST VIEW
  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: apiCtrl.episodes.length + (apiCtrl.hasMore.value ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == apiCtrl.episodes.length) {
          apiCtrl.loadNextPage();
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final item = apiCtrl.episodes[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AudioImageWidget(
            title: item.titleOriginal ?? "Untitled",
            subTitle: "${_formatDuration(item.audioLengthSec)} • ${item.podcast?.publisherOriginal ?? ""}",
            date: _formatDate(item.pubDateMs),
            episodes: "Episodes: 13",
            imageUrl: item.thumbnail ?? item.image ?? "https://via.placeholder.com/327x144",
            onTap: () {
              Get.to(() => MusicPlayerScreen(
                episodeUrls: [item.id.toString()],
                currentTopic: item.id.toString(),
              ));
            },
          ),
        );
      },
    );
  }

  // GRID VIEW
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

        final item = apiCtrl.episodes[i];
        return AudioImageWidget(
          title: item.titleOriginal ?? "Untitled",
          subTitle: "${_formatDuration(item.audioLengthSec)} • ${item.podcast?.publisherOriginal ?? ""}",
          date: _formatDate(item.pubDateMs),
          episodes: "Episodes: 13",
          imageUrl: item.thumbnail ?? item.image ?? "https://via.placeholder.com/327x144",
          onTap: () {
            Get.to(() => MusicPlayerScreen(
              episodeUrls: [item.id.toString()],
              currentTopic: item.id.toString(),
            ));
          },
        );
      },
    );
  }

  // Helper: format duration
  String _formatDuration(int? sec) {
    if (sec == null || sec <= 0) return "";
    final m = sec ~/ 60;
    final s = sec % 60;
    return "${m}m ${s}s";
  }

  // Helper: format date
  String _formatDate(int? ms) {
    if (ms == null) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return DateFormat('MMM dd, yyyy').format(dt);
  }
}