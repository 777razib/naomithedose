

import 'dart:async';
import 'package:get/get.dart';
import '../../../../core/network_caller/network_config.dart';
import '../../../../core/network_path/natwork_path.dart';
import '../model/search_text_model.dart';

class SearchTextApiController extends GetxController {
  final Rxn<TranscriptionResult> transcriptionResult = Rxn<TranscriptionResult>();
  final RxBool isLoading = false.obs;
  final RxBool isSuccess = false.obs;
  final RxString errorMessage = ''.obs;

  Timer? _pollingTimer;

  Future<void> fetchTranscription(String jobId) async {
    if (jobId.isEmpty) {
      errorMessage.value = 'Invalid job ID';
      isLoading.value = false;
      return;
    }

    // Reset state
    _pollingTimer?.cancel();
    _pollingTimer = null;
    isLoading.value = true;
    errorMessage.value = '';
    transcriptionResult.value = null;
    isSuccess.value = false;

    int attempt = 0;
    const int maxAttempts = 60; // Increased: summary can take up to 3–5 minutes
    const int delaySeconds = 5; // Better: poll every 5 seconds to avoid overload

    print("Started polling for job: $jobId");

    _pollingTimer = Timer.periodic(Duration(seconds: delaySeconds), (timer) async {
      attempt++;
      print("Polling attempt #$attempt for job: $jobId");

      try {
        final response = await NetworkCall.getRequest(url: Urls.searchingTexts(jobId));

        if (!response.isSuccess || response.responseData == null) {
          // Network or server error
          if (attempt >= maxAttempts) {
            errorMessage.value = 'Failed to connect to server. Please try again.';
            isLoading.value = false;
            timer.cancel();
          }
          return;
        }

        final data = response.responseData as Map<String, dynamic>;
        final String status = (data['status']?.toString() ?? 'unknown').toLowerCase();

        print("API Status: $status");

        // Handle FAILED
        if (status == 'failed') {
          final rawError = data['error']?.toString() ?? 'Unknown error';
          String userMsg = 'Summary generation failed.';
          if (rawError.contains('insufficient_quota') || rawError.contains('429')) {
            userMsg = 'OpenAI quota exceeded. Please try again later.';
          } else if (rawError.contains('timeout')) {
            userMsg = 'Summary generation timed out.';
          } else {
            userMsg = 'Error: $rawError';
          }

          errorMessage.value = userMsg;
          isLoading.value = false;
          timer.cancel();
          return;
        }

        // Handle COMPLETED / SUCCESS
        if (status == 'completed' || status == 'success') {
          // Look for summary in multiple possible keys
          final summaryRaw = data['summary'] ??
              data['combined_summary'] ??
              data['combinedSummary'] ??
              data['result'];

          if (summaryRaw != null && summaryRaw.toString().trim().isNotEmpty) {
            transcriptionResult.value = TranscriptionResult.fromJson(data);
            isSuccess.value = true;
            isLoading.value = false;
            errorMessage.value = '';
            timer.cancel();
            print("Summary received successfully!");
            return;
          } else {
            // Completed but empty summary — rare but possible
            errorMessage.value = 'Summary completed but empty.';
            isLoading.value = false;
            timer.cancel();
            return;
          }
        }

        // Handle PROCESSING / PENDING
        if (status == 'processing' || status == 'pending' || status == 'in_progress') {
          if (attempt >= maxAttempts) {
            errorMessage.value = 'Summary is taking too long. Please try again later.';
            isLoading.value = false;
            timer.cancel();
          }
          // Continue polling
          return;
        }

        // Unknown status
        if (attempt >= maxAttempts) {
          errorMessage.value = 'Unknown status after multiple attempts: $status';
          isLoading.value = false;
          timer.cancel();
        }

      } catch (e) {
        print("Polling exception: $e");
        if (attempt >= maxAttempts) {
          errorMessage.value = 'Network error. Please check your connection.';
          isLoading.value = false;
          timer.cancel();
        }
      }
    });

    // Final safety timeout (e.g., 5 minutes total)
    Future.delayed(const Duration(minutes: 5), () {
      if (isLoading.value && _pollingTimer?.isActive == true) {
        errorMessage.value = 'Request timed out after 5 minutes.';
        isLoading.value = false;
        _pollingTimer?.cancel();
      }
    });
  }

  void retry(String jobId) {
    fetchTranscription(jobId);
  }

  void clear() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    transcriptionResult.value = null;
    isLoading.value = false;
    errorMessage.value = '';
    isSuccess.value = false;
  }

  @override
  void onClose() {
    clear();
    super.onClose();
  }
}