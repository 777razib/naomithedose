// lib/feature/media/audio/controller/search_text_api_controller.dart
import 'package:get/get.dart';
import '../../../../core/network_caller/network_config.dart';
import '../../../../core/network_path/natwork_path.dart';
import '../model/search_text_model.dart'; // Your TopicSummaryModel

class SearchTextApiController extends GetxController {
  // Observables for UI
  var topicSummaryModel = Rxn<TopicSummaryModel>();
  var isSuccess = false.obs;
  var isLoading = false.obs;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Search in transcript
  Future<bool> searchTextApiMethod(String transcriptUrl, String query) async {
    if (query.trim().isEmpty) {
      _errorMessage = 'Search query is empty';
      isSuccess(false);
      update();
      return false;
    }

    isLoading(true);
    isSuccess(false);
    _errorMessage = null;
    topicSummaryModel.value = null;

    bool success = false;

    try {
      final response = await NetworkCall.getRequest(
        url: Urls.searchingText(transcriptUrl, query),
      );

      print("🔗 Search URL: ${Urls.searchingText(transcriptUrl, query)}");
      print("📥 Raw Response: ${response.responseData}");

      if (response.isSuccess && response.responseData != null) {
        final data = response.responseData!;

        dynamic jsonData;
        if (data.containsKey('data')) {
          jsonData = data['data'];
        } else {
          jsonData = data; // fallback
        }

        try {
          topicSummaryModel.value = TopicSummaryModel.fromJson(jsonData);
          _errorMessage = null;
          isSuccess(true);
          success = true;
          print("✅ Search Success: ${topicSummaryModel.value?.topic}");
        } catch (parseError) {
          _errorMessage = 'Parse error: $parseError';
          print("❌ Parse Error: $parseError");
        }
      } else {
        _errorMessage = response.errorMessage ?? 'Search failed';
        print("❌ API Error: ${_errorMessage}");
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
      print("❌ Exception: $e");
    } finally {
      isLoading(false);
    }

    update(); // Notify GetX widgets
    return success;
  }

  /// Optional: Clear results
  void clearSearch() {
    topicSummaryModel.value = null;
    isSuccess(false);
    _errorMessage = null;
    update();
  }
}