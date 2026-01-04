/*

import 'package:get/get.dart';
import 'package:naomithedose/core/network_caller/network_config.dart';
import '../../../core/network_path/natwork_path.dart';
import '../model/choose_interest_response_model.dart';

*/
/*
class ChooseInterestApiController extends GetxController {
  final RxList<ChooseInterestItem> episodes = <ChooseInterestItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;
  final RxString errorMessage = ''.obs;
  final RxInt currentPage = 1.obs;
  final int pageSize = 10;

  String? _currentQuery;

  Future<void> chooseInterestApiMethod({
    required String? interest,
    bool loadMore = false,
  }) async {
    if (!loadMore) {
      final bool isNewQuery = interest != null && interest != _currentQuery;
      if (isNewQuery || episodes.isNotEmpty) {
        _currentQuery = interest;
        currentPage.value = 1;
        episodes.clear();
        hasMore.value = true;
        errorMessage.value = '';
      }
    }

    if (interest == null || interest.trim().isEmpty) {
      errorMessage.value = 'Please provide a search term';
      isLoading.value = false;
      return;
    }

    if (isLoading.value) return;

    try {
      isLoading.value = true;

      final String url = Urls.chooseInterest(
        interest: _currentQuery!,
        page: currentPage.value,
        pageSize: pageSize,
      );

      final NetworkResponse response = await NetworkCall.getRequest(url: url);

      if (response.isSuccess) {
        await SharedPreferencesHelper.getAccessToken();
        final data = response.responseData!;
        final model = ChooseInterestResponseModel.fromJson(data);
        final List<ChooseInterestItem> newEpisodes = model.results ?? [];

        if (loadMore) {
          episodes.addAll(newEpisodes);
        } else {
          episodes.assignAll(newEpisodes);
        }

        // nextOffset থাকলে পেজিনেশন চালু
        hasMore.value = model.nextOffset != null && model.nextOffset! > currentPage.value * pageSize;
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to load episodes';
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
      chooseInterestApiMethod(interest: _currentQuery, loadMore: true);
    }
  }

  Future<void> refresh({String? interest}) async {
    currentPage.value = 1;
    hasMore.value = true;
    await chooseInterestApiMethod(interest: interest ?? _currentQuery, loadMore: false);
  }

  void retry() {
    errorMessage.value = '';
    chooseInterestApiMethod(interest: _currentQuery, loadMore: false);
  }
}*//*



class ChooseInterestApiController extends GetxController {
  final RxList<ChooseInterestItem> episodes = <ChooseInterestItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;
  final RxString errorMessage = ''.obs;
  final RxInt currentPage = 1.obs;

  final int limit = 10;

  String? _currentQuery;

  Future<void> chooseInterestApiMethod({
    required String? interest,
    bool loadMore = false,
  }) async {
    if (!loadMore) {
      final bool isNewQuery = interest != null && interest.trim() != (_currentQuery?.trim() ?? '');
      if (isNewQuery || episodes.isNotEmpty) {
        _currentQuery = interest?.trim();
        currentPage.value = 1;
        episodes.clear();
        hasMore.value = true;
        errorMessage.value = '';
      }
    }

    if (_currentQuery == null || _currentQuery!.isEmpty) {
      errorMessage.value = 'Please provide a search term';
      isLoading.value = false;
      return;
    }

    if (isLoading.value) return;

    try {
      isLoading.value = true;

      final String url = Urls.chooseInterest(
        interest: _currentQuery!,
        page: currentPage.value,
        limit: limit,
      );

      final NetworkResponse response = await NetworkCall.getRequest(url: url);

      if (response.isSuccess && response.responseData != null) {
        final data = response.responseData!;
        final model = ChooseInterestResponseModel.fromJson(data);
        final List<ChooseInterestItem> newEpisodes = model.results ?? [];
        if (loadMore) {
          episodes.addAll(newEpisodes);
        } else {
          episodes.assignAll(newEpisodes);
        }

        hasMore.value = newEpisodes.length >= limit;
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to load episodes';
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
      chooseInterestApiMethod(interest: _currentQuery, loadMore: true);
    }
  }

  Future<void> refresh({String? interest}) async {
    currentPage.value = 1;
    hasMore.value = true;
    await chooseInterestApiMethod(interest: interest ?? _currentQuery, loadMore: false);
  }

  void retry() {
    errorMessage.value = '';
    chooseInterestApiMethod(interest: _currentQuery, loadMore: false);
  }

  @override
  void onClose() {
    // cleanup if needed
    super.onClose();
  }
}*/
