
import 'package:get/get.dart';
import '../../../../core/network_caller/network_config.dart';
import '../../../../core/network_path/natwork_path.dart';
import '../model/search_text_model.dart';

/*class SearchTextApiController extends GetxController {
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
}*/


// lib/feature/media/audio/controller/search_text_api_controller.dart



class SearchTextApiController extends GetxController {
  final Rxn<TranscriptionResult> transcriptionResult = Rxn<TranscriptionResult>();
  final RxBool isLoading = false.obs;
  final RxBool isSuccess = false.obs;
  final RxString errorMessage = ''.obs;

  /// jobId দিয়ে ট্রান্সক্রিপশন ফেচ করুন + Auto Polling (max 60 seconds)
  Future<void> fetchTranscription(String jobId) async {
    if (jobId.isEmpty) {
      errorMessage.value = 'Invalid job ID';
      isSuccess.value = false;
      return;
    }

    // Reset state
    isLoading.value = true;
    errorMessage.value = '';
    transcriptionResult.value = null;
    isSuccess.value = false;

    int attempt = 0;
    const maxAttempts = 20;        // 20 × 3s = 60 seconds max wait
    const delaySeconds = 3;

    while (attempt < maxAttempts) {
      attempt++;
      try {
        final response = await NetworkCall.getRequest(
          url: Urls.searchingTexts(jobId),
        );

        print("Polling transcription (Attempt $attempt): ${Urls.searchingTexts(jobId)}");

        if (response.isSuccess && response.responseData != null) {
          final data = response.responseData!;

          // Success: transcription ready
          if (data is Map<String, dynamic> && (data.containsKey('transcription') || data.containsKey('text'))) {
            transcriptionResult.value = TranscriptionResult.fromJson(data);
            isSuccess.value = true;
            isLoading.value = false;
            print("Transcription ready after $attempt attempts!");
            return;
          }
        }

        // Still processing or 404
        final status = response.statusCode;
        final detail = response.responseData?['detail']?.toString() ?? '';

        if (status == 404 || detail.contains('processing') || detail.contains('not found') || detail.contains('pending')) {
          print("Still processing... retrying in $delaySeconds seconds");
          await Future.delayed(Duration(seconds: delaySeconds));
          continue; // Retry
        } else {
          // Real error
          errorMessage.value = detail.isNotEmpty ? detail : 'Failed to load transcription';
          isSuccess.value = false;
          isLoading.value = false;
          return;
        }
      } catch (e) {
        print("Network error during polling: $e");
        errorMessage.value = 'Connection error. Retrying...';
        await Future.delayed(Duration(seconds: delaySeconds));
      }
    }

    // Timeout
    errorMessage.value = 'Transcription took too long. Please try again later.';
    isLoading.value = false;
    isSuccess.value = false;
  }

  void clear() {
    transcriptionResult.value = null;
    isSuccess.value = false;
    errorMessage.value = '';
    isLoading.value = false;
  }

  @override
  void onClose() {
    clear();
    super.onClose();
  }
}