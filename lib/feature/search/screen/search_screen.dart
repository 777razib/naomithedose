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

  // ✅ Only this value controls what is shown/searched
  String _submittedQuery = "";

  @override
  void initState() {
    super.initState();

    // ✅ No API call here. Only clear results when user edits away from submitted query.
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

    FocusScope.of(context).unfocus(); // optional: hide keyboard

    setState(() {
      _submittedQuery = q; // ✅ commit query only here
    });

    await apiCtrl.searchingApiMethod(interest: q);
  }

  Future<void> _onRefresh() async {
    if (_submittedQuery.isNotEmpty) {
      await apiCtrl.searchingApiMethod(interest: _submittedQuery);
    }
  }

  String _formatDate(String isoDate) {
    try {
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(isoDate));
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

                        // ✅ Only Enter triggers search
                        onSubmitted: (v) => _submitSearch(v),

                        decoration: InputDecoration(
                          hintText: "Search podcasts…",
                          hintStyle: TextStyle(color: Colors.grey.shade600),

                          // ✅ Only button click triggers search
                          prefixIcon: IconButton(
                            icon: Icon(Icons.search, color: AppColors.primary),
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
                  // ✅ UI depends on submitted query only (not typed text)
                  final query = _submittedQuery;

                  if (apiCtrl.isLoading.value && apiCtrl.episodes.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (apiCtrl.errorMessage.isNotEmpty) {
                    return _buildErrorWidget();
                  }
                  if (query.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  if (apiCtrl.episodes.isEmpty) {
                    return _buildNoResultsWidget(query);
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

  // बाकी সব একই থাকবে ↓↓↓

  Widget _buildErrorWidget() => Center(
    child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 100),
        Icon(Icons.wifi_off, size: 64, color: Colors.grey),
        SizedBox(height: 16),
        Text("No internet connection", textAlign: TextAlign.center),
        Text("Pull down to retry", style: TextStyle(color: Colors.grey)),
      ],
    ),
  );

  Widget _buildNoResultsWidget(String query) => Center(
    child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 100),
        const Icon(Icons.search_off, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        Text('"$query"', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        const Text("No results found", style: TextStyle(color: Colors.grey)),
        const Text("Try different keywords", style: TextStyle(color: Colors.grey)),
      ],
    ),
  );

  Widget _buildListView() => ListView.builder(
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
      final e = apiCtrl.episodes[i];
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: AudioImageWidget(
          title: e.title ?? e.podcastName ?? "Unknown Episode",
          subTitle: e.artist ?? e.podcastName ?? "Unknown Show",
          date: e.releaseDate != null ? _formatDate(e.releaseDate!) : "Unknown",
          episodes: e.podcastName ?? "",
          imageUrl: e.imageUrl?.isNotEmpty == true ? e.imageUrl! : "https://via.placeholder.com/300",
          onTap: () {
            debugPrint("++**list********+++Urls---:${e.url}");
            debugPrint("+++***list******++topic---:${e.topic}");
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
      if (i == apiCtrl.episodes.length) {
        apiCtrl.loadNextPage();
        return const Center(child: CircularProgressIndicator());
      }
      final e = apiCtrl.episodes[i];
      final ee=apiCtrl.searchResult;
      debugPrint("++++++++topic+++++++${e?.topic}");

      return AudioImageWidget(
        title: e.title ?? e.podcastName ?? "Unknown Episode",
        subTitle: e.artist ?? e.podcastName ?? "Unknown Show",
        date: e.releaseDate != null ? _formatDate(e.releaseDate!) : "Unknown",
        episodes: e.podcastName ?? "",
        imageUrl: e.imageUrl?.isNotEmpty == true ? e.imageUrl! : "https://via.placeholder.com/300",
        onTap: () {
          debugPrint("++*****Grid*****+++Urls---:${e.url}");
          debugPrint("+++*****Grid****++topic---:${e.topic}");
          if (e.url != null && e.url!.isNotEmpty) {
            debugPrint("+++++Urls---:${e.url}");
            debugPrint("+++++topic---:${e.topic}");
            Get.to(() => MusicPlayerScreen(
              episodeUrls: [e.url],
              //currentTopic: ee?.query??"",
              currentTopic: e.topic ?? "",
            ));
          }
        },
      );
    },
  );
}

