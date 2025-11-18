// models/podcast_search_response.dart

class PodcastSearchResponse {
  final String query;
  final int totalResults;
  final List<Podcast> podcasts;

  PodcastSearchResponse({
    required this.query,
    required this.totalResults,
    required this.podcasts,
  });

  factory PodcastSearchResponse.fromJson(Map<String, dynamic> json) {
    var list = json['podcasts'] as List? ?? [];
    List<Podcast> podcastList = list.map((i) => Podcast.fromJson(i)).toList();

    return PodcastSearchResponse(
      query: json['query'] as String? ?? '',
      totalResults: json['total_results'] as int? ?? 0,
      podcasts: podcastList,
    );
  }
}

class Podcast {
  final String podcastId;
  final String name;
  final String description;
  final int episodeCount;
  final int durationMs;
  final String feedUrl;
  final String itunesUrl;
  final String imageUrl;
  final String releaseDate;
  final String country;
  final String platform;

  Podcast({
    required this.podcastId,
    required this.name,
    required this.description,
    required this.episodeCount,
    required this.durationMs,
    required this.feedUrl,
    required this.itunesUrl,
    required this.imageUrl,
    required this.releaseDate,
    required this.country,
    required this.platform,
  });

  factory Podcast.fromJson(Map<String, dynamic> json) {
    return Podcast(
      podcastId: json['podcast_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Podcast',
      description: json['description'] as String? ?? '',
      episodeCount: json['episode_count'] as int? ?? 0,
      durationMs: json['duration_ms'] as int? ?? 0,
      feedUrl: json['feed_url'] as String? ?? '',
      itunesUrl: json['itunes_url'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      releaseDate: json['release_date'] as String? ?? '',
      country: json['country'] as String? ?? 'Unknown',
      platform: json['platform'] as String? ?? 'apple',
    );
  }

  // Helper
  String get formattedDuration {
    final mins = durationMs ~/ 60000;
    final secs = (durationMs % 60000) ~/ 1000;
    return '${mins}m ${secs}s';
  }
}