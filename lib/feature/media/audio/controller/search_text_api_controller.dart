// lib/feature/media/audio/controller/search_text_api_controller.dart

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

    _pollingTimer?.cancel();
    isLoading.value = true;
    errorMessage.value = '';
    transcriptionResult.value = null;
    isSuccess.value = false;

    int attempt = 0;
    const maxAttempts = 30;
    const delaySeconds = 3;

    _pollingTimer = Timer.periodic(Duration(seconds: delaySeconds), (timer) async {
      attempt++;
      print("Polling attempt $attempt → ${Urls.searchingTexts(jobId)}");

      try {
        final response = await NetworkCall.getRequest(url: Urls.searchingTexts(jobId));

        if (response.isSuccess && response.responseData != null) {
          final data = response.responseData as Map<String, dynamic>;

          // এখানেই ম্যাজিক: status == "failed" হলে তৎক্ষণাৎ এরর দেখাবে
          final status = data['status']?.toString();
          if (status == 'failed') {
            final rawError = data['error']?.toString() ?? 'Unknown error';

            String userMsg = 'Request failed !';
            if (rawError.contains('insufficient_quota') || rawError.contains('429')) {
              userMsg = 'OpenAI quota exceeded. Please try again later.';
            } else if (rawError.contains('timeout')) {
              userMsg = 'Summary generation timed out.';
            }

            errorMessage.value = userMsg;
            isLoading.value = false;
            timer.cancel();
            return;
          }

          // সফল হলে শুধু তখনই fromJson করো
          final summary = data['combined_summary'] ?? data['combinedSummary'];
          if (summary != null && summary.toString().trim().isNotEmpty) {
            transcriptionResult.value = TranscriptionResult.fromJson(data);
            isSuccess.value = true;
            isLoading.value = false;
            errorMessage.value = '';
            timer.cancel();
            print("Transcription ready!");
            return;
          }
        }

        // Processing চলছে
        final statusCode = response.statusCode ?? 0;
        final detail = (response.responseData?['detail'] ?? '').toString().toLowerCase();

        if (statusCode == 404 || statusCode == 202 || detail.contains('processing') || detail.contains('pending')) {
          if (attempt >= maxAttempts) {
            errorMessage.value = 'Summary took too long. Please try again.';
            isLoading.value = false;
            timer.cancel();
          }
          return;
        }

        // অন্য সব এরর
        errorMessage.value = response.errorMessage ?? 'Failed to load summary';
        isLoading.value = false;
        timer.cancel();

      } catch (e) {
        print("Polling error: $e");
        if (attempt >= maxAttempts) {
          errorMessage.value = 'Connection issue. Please try again.';
          isLoading.value = false;
          timer.cancel();
        }
      }
    });

    // Safety timeout
    Future.delayed(Duration(seconds: maxAttempts * delaySeconds + 10), () {
      if (isLoading.value) {
        errorMessage.value = 'Request timed out';
        isLoading.value = false;
        _pollingTimer?.cancel();
      }
    });
  }

  void retry(String jobId) => fetchTranscription(jobId);

  void clear() {
    _pollingTimer?.cancel();
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