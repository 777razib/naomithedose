

import 'package:get/get.dart';
import '../../../core/network_caller/network_config.dart';
import '../../../core/network_path/natwork_path.dart';
import '../model/searching_model.dart';

class SearchingApiController extends GetxController {
  final RxList<Episode> episodes = <Episode>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;
  final RxString errorMessage = ''.obs;
  final RxInt currentPage = 1.obs;
  final int pageSize = 10;

  String? _currentQuery;

  Future<void> searchingApiMethod({
    required String? interest,
    bool loadMore = false,
  }) async {
    if (!loadMore && interest != null && interest.trim() != _currentQuery?.trim()) {
      _currentQuery = interest.trim();
      currentPage.value = 1;
      episodes.clear();
      hasMore.value = true;
      errorMessage.value = '';
    }

    if (_currentQuery == null || _currentQuery!.isEmpty) {
      errorMessage.value = 'Please provide a search term';
      return;
    }

    if (isLoading.value) return;

    try {
      isLoading.value = true;

      final String url = Urls.quickPopularTopic(
        topic: _currentQuery!,
        page: currentPage.value,
        pageSize: pageSize,
      );

      final NetworkResponse response = await NetworkCall.getRequest(url: url);

      if (response.isSuccess && response.responseData != null) {
        final model = SearchResult.fromJson(response.responseData!);
        final newEpisodes = model.episodes ?? [];

        if (loadMore) {
          episodes.addAll(newEpisodes);
        } else {
          episodes.assignAll(newEpisodes);
        }

        hasMore.value = newEpisodes.length >= pageSize;
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to load results';
        hasMore.value = false;
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      hasMore.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  void loadNextPage() {
    if (hasMore.value && !isLoading.value && _currentQuery != null) {
      currentPage.value++;
      searchingApiMethod(interest: _currentQuery, loadMore: true);
    }
  }

  Future<void> refresh({String? interest}) async {
    currentPage.value = 1;
    hasMore.value = true;
    await searchingApiMethod(interest: interest ?? _currentQuery, loadMore: false);
  }

  void clearResults() {
    episodes.clear();
    hasMore.value = true;
    isLoading.value = false;
    errorMessage.value = '';
    currentPage.value = 1;
    _currentQuery = null;
  }
}
