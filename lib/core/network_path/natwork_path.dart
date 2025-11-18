// lib/core/network_path/network_path.dart

class Urls {
  // ==================== BASE URL ====================
  static const String _baseUrl = 'http://206.162.244.140:8033';

  // ==================== AUTH ====================

  // Keep your auth URLs
  static const String login = '$_baseUrl/auth/login';
  static const String authSignUp = '$_baseUrl/auth/signup';
  static const String authForgetSendOtp = '$_baseUrl/auth/forget/send-otp';
  static const String authFVerifyOtp = '$_baseUrl/auth/forget/verify-otp';
  static const String authForgetResetPassword = '$_baseUrl/auth/forget/reset-password';

  // ==================== USER PROFILE ====================
  static const String getUserDataUrl = '$_baseUrl/user/me';
  static const String editUserDataUrl = '$_baseUrl/user/me/edit';
  static const String deleteUserDataUrl = '$_baseUrl/user/delete-my-profile';

  // ==================== PODCASTS & EPISODES ====================


  /// Popular podcasts or search by keyword
  static   String singleAudio(String id) => '$_baseUrl/episode/$id?show_transcript=1';
  static String searchingText(String url,String text){
    final encoded=Uri.encodeComponent(url);
    return '$_baseUrl/search-any-topic?audio_url=$encoded&topic=$text';
  }
  static String searchingTexts(String id){
    final encoded=Uri.encodeComponent(id);
    return '$_baseUrl/podcast/transcription/$encoded';
  }
// network_path.dart
  static String audioSummary(String audioUrl) {
    final encoded = Uri.encodeComponent(audioUrl);
    return "$_baseUrl/episode/transcribe?audio_url=$encoded";
  }

// lib/core/network_path/network_path.dart

  static String playPodcastEpisode({
    required String podcastUrl,  // Apple Podcasts URL বা যেকোনো podcast link
    required String topic,        // যে টপিকে ট্রান্সক্রিপশন চাও (যেমন: "motivation")
  }) {
    final encodedUrl = Uri.encodeComponent(podcastUrl);
    final encodedTopic = Uri.encodeComponent(topic);
    return '$_baseUrl/podcast/details?url=$encodedUrl&topic=$encodedTopic';
  }  // FIXED: Direct to ListenNotes
  static String chooseInterest({
    required String interest,
    int page = 1,
    int pageSize = 10,
  }) {
    final int offset = (page - 1) * pageSize;
    final String query = Uri.encodeComponent(interest.trim());

    return '$_baseUrl/podcasts'
        '?q=$query'
        '&type=episode'
        '&language=English'
        '&len_min=5'      // ← Real episodes
        '&len_max=120'
        '&offset=$offset'
        '&limit=$pageSize';
  }

  static String quickPopularTopic({
    required String topic,      // ← topic, not interest
    int page = 1,
    int pageSize = 10,
  }) {
    final offset = (page - 1) * pageSize;
    final q = Uri.encodeComponent(topic.trim());

    return '$_baseUrl/podcasts/popular?'
        'topic=$q'
        '&type=episode'
        '&language=English'
        '&len_min=5'
        '&len_max=120'
        '&offset=$offset'
        '&page_size=$pageSize';
  }
  /// Builds the API URL for the home/feed screen
  /// - If [interest] is null, empty, or whitespace → returns popular podcasts
  /// - Otherwise → searches podcasts by the given interest/keyword
  static String homeFeed({
    String? keyword,
    int page = 1,
    int pageSize = 10,
  }) {
    final trimmed = keyword?.trim() ?? '';
    final encoded = Uri.encodeComponent(trimmed);

    if (trimmed.isEmpty) {
      return '$_baseUrl/podcasts/popular?page_size=$pageSize&page=$page';
    } else {
      return '$_baseUrl/podcasts/search?q=$encoded&page_size=$pageSize&page=$page';
    }
  }


  static String getCalendar(String date, String locationUuid) =>
      '$_baseUrl/calendar?date=$date&pickup_location_uuid=$locationUuid';

  static const String googleApiKey = "AIzaSyC7AoMhe2ZP3iHflCVr6a3VeL0ju0bzYVE";
}