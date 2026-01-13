/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
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

  // Only this value controls what is shown/searched
  String _submittedQuery = "";

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      final typed = _searchController.text.trim();

      // If user clears input, clear results
      if (typed.isEmpty) {
        _submittedQuery = "";
        apiCtrl.clearResults();
        return;
      }

      // If user is typing something different than last submitted query,
      // clear previous results so pagination can't trigger API.
      if (_submittedQuery.isNotEmpty && typed != _submittedQuery) {
        apiCtrl.clearResults();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _submitSearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;

    FocusScope.of(context).unfocus(); // Hide keyboard
    setState(() {
      _submittedQuery = q; // Commit query only here
    });

    await apiCtrl.searchingApiMethod(interest: q);
  }

  Future<void> _onRefresh() async {
    if (_submittedQuery.isNotEmpty) {
      await apiCtrl.searchingApiMethod(interest: _submittedQuery);
    }
  }


  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.trim().isEmpty) {
      return "Unknown date";
    }

    final trimmed = rawDate.trim();

    // সবচেয়ে কমন RSS ফরম্যাট → প্রথমে এটা চেষ্টা
    try {
      final date = DateFormat('EEE, dd MMM yyyy HH:mm:ss Z', 'en_US').parse(trimmed);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {}

    // যদি ভবিষ্যতে ISO ফরম্যাট আসে
    try {
      final date = DateTime.parse(trimmed);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {}

    // সব ফেল করলে
    return "Unknown date";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFF3),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
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
                        onSubmitted: (v) => _submitSearch(v),
                        decoration: InputDecoration(
                          hintText: "Search podcasts…",
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          prefixIcon: IconButton(
                            icon: const Icon(Icons.search, color: AppColors.primary),
                            onPressed: () => _submitSearch(_searchController.text),
                          ),
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
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
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
                                boxShadow: [
                                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                                ],
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
                  final query = _submittedQuery;

                  // Loading state (only when no data yet)
                  if (apiCtrl.isLoading.value && apiCtrl.episodes.isEmpty) {
                    return  Center(child: Lottie.asset(
                      "assets/lottie_json/loading_lottie.json",
                      width: 100,
                      height: 100,
                      repeat: true,
                      animate: true,
                    ),);
                  }

                  // Error state - shows actual error message
                  if (apiCtrl.errorMessage.isNotEmpty) {
                    return _buildErrorWidget();
                  }

                  // No query submitted yet
                  if (query.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  // No results found
                  if (apiCtrl.episodes.isEmpty) {
                    return _buildNoResultsWidget(query);
                  }

                  // Show results
                  return isListView ? _buildListView() : _buildGridView();
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Shows the actual error from the controller
  Widget _buildErrorWidget() => Center(
    child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 100),
        Icon(
          apiCtrl.errorMessage.value.toLowerCase().contains('internet') ||
              apiCtrl.errorMessage.value.toLowerCase().contains('network') ||
              apiCtrl.errorMessage.value.toLowerCase().contains('socket') ||
              apiCtrl.errorMessage.value.toLowerCase().contains('timeout')
              ? Icons.wifi_off
              : Icons.error_outline,
          size: 64,
          color: Colors.grey,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            apiCtrl.errorMessage.value.isNotEmpty
                ? apiCtrl.errorMessage.value
                : "Something went wrong",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Pull down to retry",
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  Widget _buildNoResultsWidget(String query) => Center(
    child: Align(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
       // physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 100),
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            '"$query"',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const Text("No results found", style: TextStyle(color: Colors.grey)),
          const Text("Try different keywords and hit enter", style: TextStyle(color: Colors.grey)),
        ],
      ),
    ),
  );

  // FIXED: Safe pagination for ListView
  Widget _buildListView() => ListView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    itemCount: apiCtrl.episodes.length + (apiCtrl.hasMore.value ? 1 : 0),
    itemBuilder: (context, i) {
      // Trigger load more only when reaching the last item
      if (i == apiCtrl.episodes.length && apiCtrl.hasMore.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          apiCtrl.loadNextPage();
        });
        return const Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final e = apiCtrl.episodes[i];

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: AudioImageWidget(
          title: e.title ?? e.podcastName ?? "Unknown Episode",
          subTitle: e.artist ?? e.podcastName ?? "Unknown Show",
          date: e.releaseDate != null ? _formatDate(e.releaseDate!) : "Unknown",
          episodes: e.podcastName ?? "",
          imageUrl: e.imageUrl?.isNotEmpty == true
              ? e.imageUrl!
              : "https://via.placeholder.com/300",
          onTap: () {
            if (e.url != null && e.url!.isNotEmpty) {
              Get.to(() => MusicPlayerScreen(
                episodeUrls: [e.url!],
                currentTopic: e.topic ?? "",
              ));
            }
          },
        ),
      );
    },
  );

  // FIXED: Safe pagination for GridView (this was causing the SliverGrid crash)
  Widget _buildGridView() => GridView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.78,
    ),
    itemCount: apiCtrl.episodes.length + (apiCtrl.hasMore.value ? 1 : 0),
    itemBuilder: (context, i) {
      // Trigger load more only when reaching the last item
      if (i == apiCtrl.episodes.length && apiCtrl.hasMore.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          apiCtrl.loadNextPage();
        });
        return const Center(child: CircularProgressIndicator());
      }

      final e = apiCtrl.episodes[i];

      return AudioImageWidget(
        title: e.title ?? e.podcastName ?? "Unknown Episode",
        subTitle: e.artist ?? e.podcastName ?? "Unknown Show",
        date: e.releaseDate != null ? _formatDate(e.releaseDate!) : "Unknown",
        episodes: e.podcastName ?? "",
        imageUrl: e.imageUrl?.isNotEmpty == true
            ? e.imageUrl!
            : "https://via.placeholder.com/300",
        onTap: () {
          if (e.url != null && e.url!.isNotEmpty) {
            Get.to(() => MusicPlayerScreen(
              episodeUrls: [e.url!],
              currentTopic: e.topic ?? "",
            ));
          }
        },
      );
    },
  );
}
*/
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
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
  final ScrollController _scrollController = ScrollController();
  bool isListView = true;

  // Only this value controls what is shown/searched
  String _submittedQuery = "";
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    aaa;

    _searchController.addListener(() {
      final typed = _searchController.text.trim();

      // If user clears input, clear results
      if (typed.isEmpty) {
        _submittedQuery = "";
        apiCtrl.clearResults();
        return;
      }

      // If user is typing something different than last submitted query,
      // clear previous results so pagination can't trigger API.
      if (_submittedQuery.isNotEmpty && typed != _submittedQuery) {
        apiCtrl.clearResults();
      }
    });
  }
void aaa(){
  final e = apiCtrl.episodes[0];
  print("------id${e.episodeId}----");
}
  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent - 200 &&
        !_scrollController.position.outOfRange &&
        apiCtrl.hasMore.value &&
        !apiCtrl.isLoading.value) {
      apiCtrl.loadNextPage();
    }
  }

  Future<void> _submitSearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;

    FocusScope.of(context).unfocus(); // Hide keyboard
    setState(() {
      _submittedQuery = q; // Commit query only here
    });

    await apiCtrl.searchingApiMethod(interest: q);
  }

  Future<void> _onRefresh() async {
    if (_submittedQuery.isNotEmpty) {
      await apiCtrl.searchingApiMethod(interest: _submittedQuery);
    }
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.trim().isEmpty) {
      return "Unknown date";
    }

    final trimmed = rawDate.trim();

    // সবচেয়ে কমন RSS ফরম্যাট → প্রথমে এটা চেষ্টা
    try {
      final date = DateFormat('EEE, dd MMM yyyy HH:mm:ss Z', 'en_US').parse(trimmed);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {}

    // যদি ভবিষ্যতে ISO ফরম্যাট আসে
    try {
      final date = DateTime.parse(trimmed);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {}

    // সব ফেল করলে
    return "Unknown date";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFF3),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
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
                        onSubmitted: (v) => _submitSearch(v),
                        decoration: InputDecoration(
                          hintText: "Search podcasts…",
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          prefixIcon: IconButton(
                            icon: const Icon(Icons.search, color: AppColors.primary),
                            onPressed: () => _submitSearch(_searchController.text),
                          ),
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
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
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
                                boxShadow: [
                                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                                ],
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
                  final query = _submittedQuery;

                  // Loading state (only when no data yet)
                  if (apiCtrl.isLoading.value && apiCtrl.episodes.isEmpty) {
                    return Center(
                      child: Lottie.asset(
                        "assets/lottie_json/loading_lottie.json",
                        width: 100,
                        height: 100,
                        repeat: true,
                        animate: true,
                      ),
                    );
                  }

                  // Error state - shows actual error message
                  if (apiCtrl.errorMessage.isNotEmpty) {
                    return _buildErrorWidget();
                  }

                  // No query submitted yet
                  if (query.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  // No results found
                  if (apiCtrl.episodes.isEmpty) {
                    return _buildNoResultsWidget(query);
                  }

                  // Show results
                  return isListView ? _buildListView() : _buildGridView();
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Shows the actual error from the controller
  Widget _buildErrorWidget() => Center(
    child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 100),
        Icon(
          apiCtrl.errorMessage.value.toLowerCase().contains('internet') ||
              apiCtrl.errorMessage.value.toLowerCase().contains('network') ||
              apiCtrl.errorMessage.value.toLowerCase().contains('socket') ||
              apiCtrl.errorMessage.value.toLowerCase().contains('timeout')
              ? Icons.wifi_off
              : Icons.error_outline,
          size: 64,
          color: Colors.grey,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            apiCtrl.errorMessage.value.isNotEmpty
                ? apiCtrl.errorMessage.value
                : "Something went wrong",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Pull down to retry",
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  Widget _buildNoResultsWidget(String query) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.search_off, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        Text(
          '"$query"',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const Text("No results found", style: TextStyle(color: Colors.grey)),
        const Text("Try different keywords and hit enter", style: TextStyle(color: Colors.grey)),
      ],
    ),
  );

  // Updated: Scroll-based ListView (no auto-trigger in itemBuilder)
  Widget _buildListView() => ListView.builder(
    controller: _scrollController,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    itemCount: apiCtrl.episodes.length + (apiCtrl.isLoading.value ? 1 : 0),
    itemBuilder: (context, i) {
      if (i == apiCtrl.episodes.length) {
        print("---------length----------${apiCtrl.episodes.length}");
        return const Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final e = apiCtrl.episodes[i];

       print("---------title----------${e.title}");
       print("---------rssAudioUrl----------${e.rssAudioUrl}");
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: AudioImageWidget(
          title: e.title ?? e.podcastName ?? "Unknown Episode",
          subTitle: e.artist ?? e.podcastName ?? "Unknown Show",
          date: e.releaseDate != null ? _formatDate(e.releaseDate!) : "Unknown",
          episodes: e.podcastName ?? "",
          imageUrl: e.imageUrl?.isNotEmpty == true
              ? e.imageUrl!
              : "https://via.placeholder.com/300",
          onTap: () {
            if (e.rssAudioUrl != null && e.rssAudioUrl!.isNotEmpty) {
              print("--rssAudioUrl------${e.rssAudioUrl}");

              Get.to(() => MusicPlayerScreen(
                episodeUrls: [e.rssAudioUrl!],
                currentTopic: e.topic ?? "",
              ));
            }
          },
        ),
      );
    },
  );

  // Updated: Scroll-based GridView (no auto-trigger in itemBuilder)
  Widget _buildGridView() => GridView.builder(
    controller: _scrollController,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.78,
    ),
    itemCount: apiCtrl.episodes.length + (apiCtrl.isLoading.value ? 1 : 0),
    itemBuilder: (context, i) {
      if (i == apiCtrl.episodes.length) {
        return const Center(child: CircularProgressIndicator());
      }

      final e = apiCtrl.episodes[i];

      return AudioImageWidget(
        title: e.title ?? e.podcastName ?? "Unknown Episode",
        subTitle: e.artist ?? e.podcastName ?? "Unknown Show",
        date: e.releaseDate != null ? _formatDate(e.releaseDate!) : "Unknown",
        episodes: e.podcastName ?? "",
        imageUrl: e.imageUrl?.isNotEmpty == true
            ? e.imageUrl!
            : "https://via.placeholder.com/300",
        onTap: () {
          if (e.rssAudioUrl != null && e.rssAudioUrl!.isNotEmpty) {
            print("--rssAudioUrl------${e.rssAudioUrl}");
            Get.to(() => MusicPlayerScreen(
              episodeUrls: [e.rssAudioUrl!],
              currentTopic: e.topic ?? "",
            ));
          }
        },
      );
    },
  );
}