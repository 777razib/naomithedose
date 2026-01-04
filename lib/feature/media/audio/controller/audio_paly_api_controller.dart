// lib/feature/media/audio/controller/audio_paly_api_controller.dart

import 'dart:convert';

import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:naomithedose/core/network_caller/network_config.dart';
import '../../../../core/network_path/natwork_path.dart';
import '../../../choose interest/model/choose_interest_response_model.dart';
import '../../../search/model/searching_model.dart';



class AudioPlayController extends GetxController {
  // Singleton pattern - only one instance in the app
  static final AudioPlayController instance = Get.find<AudioPlayController>();

  // For regular audio (from ChooseInterestItem)
  final chooseInterestItem = Rxn<ChooseInterestItem>();

  // For podcast episodes
  final podcastResponse = Rxn<Episode>();

  final isLoading = false.obs;
  final errorMessage = Rxn<String>();

  // Shared Audio Player (singleton)
  final AudioPlayer player = AudioPlayer();

  final isPlaying = false.obs;
  final duration = Duration.zero.obs;
  final position = Duration.zero.obs;

  bool _streamsInitialized = false;

  String formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  void onInit() {
    super.onInit();
    _setupPlayerStreams();
  }

  void _setupPlayerStreams() {
    if (_streamsInitialized) return;

    player.positionStream.listen((p) => position.value = p);
    player.durationStream.listen((d) => duration.value = d ?? Duration.zero);
    player.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
    });

    _streamsInitialized = true;
  }

  @override
  void onClose() {
    player.dispose();
    super.onClose();
  }

  // Play regular audio by ID (from your interest list)
  Future<void> loadRegularAudio(String id) async {
    if (id.isEmpty) {
      errorMessage.value = 'Invalid audio ID';
      return;
    }

    _resetAndLoad();
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final response = await NetworkCall.getRequest(url: Urls.singleAudio(id));

      if (response.isSuccess && response.responseData != null) {
        final data = response.responseData! as Map<String, dynamic>;
        final item = ChooseInterestItem.fromJson(data);
        chooseInterestItem.value = item;
        podcastResponse.value = null; // Clear podcast if switching

        final audioUrl = item.audio;
        if (audioUrl != null && audioUrl.isNotEmpty) {
          await _setAudioSource(audioUrl);
        } else {
          errorMessage.value = 'No audio URL found.';
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to load audio.';
      }
    } catch (e) {
      errorMessage.value = 'Network error: $e';
      print('Regular Audio Load Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Play podcast episode
  Future<void> loadPodcastEpisode(String podcastUrl, String topic) async {
    if (podcastUrl.isEmpty || topic.isEmpty) {
      errorMessage.value = 'Invalid podcast URL or topic';
      return;
    }

    _resetAndLoad();
    isLoading.value = true;
    errorMessage.value = null;

    final generatedUrl = Urls.playPodcastEpisode(podcastUrl: podcastUrl, topic: topic);
    print('🔗 Calling API URL: $generatedUrl');  // Log the full URL
    print("------------url--------------++++++++++++++++$podcastUrl");
    print("-----------topic---------------++++++++++++++++$topic");

    try {
      final response = await NetworkCall.getRequest(url: generatedUrl);

      print('📶 API Status Code: ${response.statusCode ?? 'unknown'}');
      print('✅ Success: ${response.isSuccess}');

      if (response.responseData != null) {
        // Pretty-print the full raw JSON response
        print('📄 FULL RAW RESPONSE BODY:');
        print(const JsonEncoder.withIndent('  ').convert(response.responseData));
      } else {
        print('⚠️ No response body received');
      }

      if (response.isSuccess && response.responseData != null) {
        final data = response.responseData! as Map<String, dynamic>;
        final episode = Episode.fromJson(data);
        podcastResponse.value = episode;
        chooseInterestItem.value = null;

        print('🎵 Parsed rss_audio_url: ${episode.rssAudioUrl}');
        print('🆔 job_id (if present): ${episode.jobId}');  // Will show null or the value

        final audioUrl = episode.rssAudioUrl;
        if (audioUrl.isNotEmpty) {
          await _setAudioSource(audioUrl);
        } else {
          errorMessage.value = 'No playable audio URL in episode.';
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to load podcast episode.';
        print('❌ Error Message: ${response.errorMessage}');
      }
    } catch (e, stackTrace) {
      errorMessage.value = 'Network error: $e';
      print('🚨 Exception: $e');
      print('📚 Stack Trace: $stackTrace');
    } finally {
      isLoading.value = false;
    }
  }

  // Shared method to stop and set new audio source
  Future<void> _setAudioSource(String url) async {
    try {
      await player.stop();
      await player.setUrl(url);
      print('Audio loaded successfully: $url');
    } catch (e) {
      errorMessage.value = 'Failed to load audio file.';
      print('just_audio error: $e');
    }
  }

  // Reset before loading new audio
  void _resetAndLoad() {
    player.stop();
    duration.value = Duration.zero;
    position.value = Duration.zero;
    isPlaying.value = false;
  }

  // Controls
  void togglePlayPause() {
    if (player.playing) {
      player.pause();
    } else {
      player.play();
    }
  }

  void seekTo(double progress) {
    final dur = duration.value;
    if (dur == Duration.zero) return;
    final target = Duration(seconds: (dur.inSeconds * progress).round());
    player.seek(target);
  }

  // Optional: Reset everything (e.g., when leaving screen)
  void resetPlayer() {
    player.stop();
    chooseInterestItem.value = null;
    podcastResponse.value = null;
    errorMessage.value = null;
  }
}

/*class AudioPlayApiControllers extends GetxController {
  final podcastResponse = Rxn<EpisodeDetail>();
  final isLoading = false.obs;
  final errorMessage = Rxn<String>();

  String format(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  // Player - initialize once
  final AudioPlayer player = AudioPlayer();
  final isPlaying = false.obs;
  final duration = Duration.zero.obs;
  final position = Duration.zero.obs;

  bool _initialized = false;

  @override
  void onInit() {
    super.onInit();
    _setupStreams();
  }

  void _setupStreams() {
    if (_initialized) return;
    player.positionStream.listen((p) => position.value = p);
    player.durationStream.listen((d) => duration.value = d ?? Duration.zero);
    player.playerStateStream.listen((state) => isPlaying.value = state.playing);
    _initialized = true;
  }

  @override
  void onClose() {
    player.dispose();
    super.onClose();
  }

  Future<void> audioPlayApiMethod(String urls, String topic) async {
    if (urls.isEmpty && topic.isEmpty) {
      errorMessage.value = 'Invalid Url or Topic';
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    _setupStreams(); // safe
    await player.stop(); // ✅ stop audio when page opens or new episode loads

    try {
      final response = await NetworkCall.getRequest(
        url: Urls.playPodcastEpisode(topic: topic, podcastUrl: urls),
      );

      if (response.isSuccess && response.responseData != null) {
        final data = response.responseData! as Map<String, dynamic>;
        final item = EpisodeDetail.fromJson(data);
        podcastResponse.value = item;

        final audioUrl = item.rssAudioUrl;
        if (audioUrl != null && audioUrl.isNotEmpty) {
          try {
            await player.setUrl(audioUrl);

            // ✅ FIX: DO NOT AUTO PLAY
            // player.play();

            print('Audio loaded and ready: $audioUrl');
          } catch (e) {
            print('Player Error in AudioPlayApiControllers: $e');
            errorMessage.value = 'Failed to play audio.';
          }
        } else {
          errorMessage.value = 'No audio URL in episode details.';
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to load podcast episode.';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  void togglePlayPause() => player.playing ? player.pause() : player.play();

  void seekTo(double progress) {
    final dur = duration.value;
    if (dur == Duration.zero) return;
    player.seek(Duration(seconds: (dur.inSeconds * progress).round()));
  }
}*/
