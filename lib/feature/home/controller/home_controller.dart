// lib/app/modules/home/controller/home_controller.dart

import 'package:get/get.dart';
import '../../../core/network_caller/network_config.dart';
import '../../../core/network_path/natwork_path.dart';
import '../model/home_model.dart'; // Your PodcastResponse model

class HomeController extends GetxController {
  // ========== Observable States ==========
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;       // For load-more spinner
  final RxBool hasMoreData = true.obs;          // Stop requesting when no more
  final RxString errorMessage = ''.obs;

  // ========== Podcast Data ==========
  final RxList<Podcast> podcasts = <Podcast>[].obs;
  final Rx<PodcastResponse?> podcastResponse = Rx<PodcastResponse?>(null);

  // ========== Pagination ==========
  int _currentPage = 1;
  static const int _pageSize = 10;
  String? _currentKeyword; // Remember last search keyword (null = popular)

  @override
  void onInit() {
    super.onInit();
    fetchHomePodcasts(refresh: true); // First load
  }

  // ========== Main Function (Refresh + Pagination) ==========
  Future<void> fetchHomePodcasts({
    bool refresh = false,
    String? keyword,
  }) async {
    // Reset everything on refresh or new search
    if (refresh) {
      _currentPage = 1;
      podcasts.clear();
      hasMoreData.value = true;
      _currentKeyword = keyword;
    }

    // Prevent duplicate requests
    if (isLoading.value || isLoadingMore.value || !hasMoreData.value) return;

    // Set loading state
    if (_currentPage == 1) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    try {
      final String url = Urls.homeFeed(
        keyword: _currentKeyword,
        page: _currentPage,
        pageSize: _pageSize,
      );

      final NetworkResponse networkResponse = await NetworkCall.getRequest(url: url);

      if (networkResponse.isSuccess) {
        final Map<String, dynamic> jsonData = networkResponse.responseData!;

        final PodcastResponse response = PodcastResponse.fromJson(jsonData);

        // Append or replace podcasts
        if (refresh || _currentPage == 1) {
          podcasts.assignAll(response.podcasts ?? []);
        } else {
          podcasts.addAll(response.podcasts ?? []);
        }

        // Update full response if needed
        podcastResponse.value = response;

        // Check if we have more data
        final bool hasMore = (response.podcasts?.length ?? 0) >= _pageSize;
        hasMoreData.value = hasMore;

        // Increase page only if we got full page
        if (hasMore) _currentPage++;
      } else {
        errorMessage.value = networkResponse.errorMessage ?? 'Failed to load podcasts';
        Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      errorMessage.value = 'Something went wrong!';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // ========== Pull-to-Refresh ==========
  Future<void> onRefresh() async {
    await fetchHomePodcasts(refresh: true, keyword: _currentKeyword);
  }

  // ========== Load More (called from ScrollController) ==========
  void loadMore() {
    if (!isLoadingMore.value && hasMoreData.value) {
      fetchHomePodcasts(keyword: _currentKeyword);
    }
  }

  // ========== Search with Keyword ==========
  Future<void> searchPodcasts(String keyword) async {
    _currentKeyword = keyword.trim().isEmpty ? null : keyword.trim();
    await fetchHomePodcasts(refresh: true, keyword: _currentKeyword);
  }

  // ========== Reset Controller (optional) ==========
  void reset() {
    podcasts.clear();
    _currentPage = 1;
    hasMoreData.value = true;
    isLoading.value = false;
    isLoadingMore.value = false;
  }
}