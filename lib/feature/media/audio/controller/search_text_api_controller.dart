
import 'package:get/get.dart';
import '../../../../core/network_caller/network_config.dart';
import '../../../../core/network_path/natwork_path.dart';
import '../model/search_text_model.dart';

class SearchTextApiController extends GetxController {
  var topicSummaryModel = Rxn<TopicSummaryModel>();
  var isSuccess = false.obs;
  var isLoading = false.obs;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Only GET request - backend auto-transcribes if needed
  Future<bool> searchTextApiMethod(String audioUrl, String query) async {
    if (query.trim().isEmpty) {
      _errorMessage = 'Please enter a search term';
      isSuccess(false);
      return false;
    }

    isLoading(true);
    isSuccess(false);
    _errorMessage = null;
    topicSummaryModel.value = null;

    bool success = false;
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount <= maxRetries) {
      try {
        final response = await NetworkCall.getRequest(
          url: Urls.searchingText(audioUrl, query),
        );

        print("Search URL: ${Urls.searchingText(audioUrl, query)}");
        print("Raw Response: ${response.responseData}");

        // Success: 200 + data
        if (response.isSuccess && response.responseData != null) {
          final data = response.responseData!;
          dynamic jsonData = data.containsKey('data') ? data['data'] : data;

          try {
            topicSummaryModel.value = TopicSummaryModel.fromJson(jsonData);
            _errorMessage = null;
            isSuccess(true);
            success = true;
            print("Search Success: ${topicSummaryModel.value?.topic}");
            break; // Exit retry loop
          } catch (parseError) {
            _errorMessage = 'Failed to parse response';
            print("Parse Error: $parseError");
            break;
          }
        }
        // Handle 404: "Please transcribe first"
        else {
          final errorBody = response.responseData?['detail'] ?? response.errorMessage;
          print("API Error: $errorBody");

          if (errorBody is String && errorBody.contains('404') && retryCount < maxRetries) {
            retryCount++;
            print("Retrying... ($retryCount/$maxRetries)");
            await Future.delayed(Duration(seconds: 3 * retryCount)); // Wait for backend
            continue;
          } else {
            _errorMessage = errorBody ?? 'Search failed';
            break;
          }
        }
      } catch (e) {
        _errorMessage = 'Network error: $e';
        print("Exception: $e");
        break;
      }
    }

    isLoading(false);
    update();
    return success;
  }

  void clearSearch() {
    topicSummaryModel.value = null;
    isSuccess(false);
    _errorMessage = null;
    update();
  }
}


class SearchTextApiControllers extends GetxController {
  var topicSummaryModel = Rxn<TranscriptionResult>();
  var isSuccess = false.obs;
  var isLoading = false.obs;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Only GET request - backend auto-transcribes if needed
  Future<bool> searchTextApiMethods({
    required String jobId,
  }) async {
    if (jobId.isEmpty) {
      _errorMessage = 'Job ID missing';
      isSuccess(false);
      return false;
    }

    isLoading(true);
    isSuccess(false);
    _errorMessage = null;
    topicSummaryModel.value = null;

    try {
      // Correct endpoint: /podcast/transcription + job_id


      final response = await NetworkCall.getRequest(url: Urls.searchingTexts(jobId));

      print("Transcription Check URL: ${Urls.searchingTexts(jobId)}");
      print("Response: ${response.responseData}");

      if (response.isSuccess && response.responseData != null) {
        final jsonData = response.responseData!;
        topicSummaryModel.value = TranscriptionResult.fromJson(jsonData);
        isSuccess(true);
        return true;
      } else {
        final error = response.responseData?['detail'] ?? 'Not ready';
        if (error.toString().contains('processing') || response.statusCode == 404) {
          _errorMessage = 'Transcription is still processing...';
        } else {
          _errorMessage = error.toString();
        }
        isSuccess(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      print(e);
      return false;
    } finally {
      isLoading(false);
      update();
    }
  }

  void clearSearch() {
    topicSummaryModel.value = null;
    isSuccess(false);
    _errorMessage = null;
    update();
  }
}