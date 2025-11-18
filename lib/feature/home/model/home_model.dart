// podcast_models.dart
import 'dart:convert';

class PodcastResponse {
  final String? query;
  final int? totalResults;
  final List<Podcast>? podcasts;

  PodcastResponse({
    this.query,
    this.totalResults,
    this.podcasts,
  });

  factory PodcastResponse.fromJson(Map<String, dynamic> json) {
    final list = json['podcasts'] as List<dynamic>?;
    final podcastList = list?.map((i) => Podcast.fromJson(i as Map<String, dynamic>)).toList();

    return PodcastResponse(
      query: json['query'] as String?,
      totalResults: json['total_results'] as int?,
      podcasts: podcastList,
    );
  }

  Map<String, dynamic> toJson() => {
    'query': query,
    'total_results': totalResults,
    'podcasts': podcasts?.map((p) => p.toJson()).toList(),
  };

  @override
  String toString() => jsonEncode(toJson());
}

class Podcast {
  final String? podcastId;
  final String? name;
  final String? description;
  final int? episodeCount;
  final int? durationMs;
  final String? feedUrl;
  final String? itunesUrl;
  final String? imageUrl;
  final String? releaseDate;
  final String? country;
  final String? platform;

  Podcast({
    this.podcastId,
    this.name,
    this.description,
    this.episodeCount,
    this.durationMs,
    this.feedUrl,
    this.itunesUrl,
    this.imageUrl,
    this.releaseDate,
    this.country,
    this.platform,
  });

  factory Podcast.fromJson(Map<String, dynamic> json) => Podcast(
    podcastId: json['podcast_id'] as String?,
    name: json['name'] as String?,
    description: json['description'] as String?,
    episodeCount: json['episode_count'] as int?,
    durationMs: json['duration_ms'] as int?,
    feedUrl: json['feed_url'] as String?,
    itunesUrl: json['itunes_url'] as String?,
    imageUrl: json['image_url'] as String?,
    releaseDate: json['release_date'] as String?,
    country: json['country'] as String?,
    platform: json['platform'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'podcast_id': podcastId,
    'name': name,
    'description': description,
    'episode_count': episodeCount,
    'duration_ms': durationMs,
    'feed_url': feedUrl,
    'itunes_url': itunesUrl,
    'image_url': imageUrl,
    'release_date': releaseDate,
    'country': country,
    'platform': platform,
  };

  @override
  String toString() => jsonEncode(toJson());
}