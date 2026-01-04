

class SearchResult {
  final String query;
  final int podcastsMatched;
  final int episodesReturned;
  final List<Episode> episodes;

  SearchResult({
    required this.query,
    required this.podcastsMatched,
    required this.episodesReturned,
    required this.episodes,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      query: json['query'] as String? ?? '',
      podcastsMatched: json['podcasts_matched'] as int? ?? 0,
      episodesReturned: json['episodes_returned'] as int? ?? 0,
      episodes: (json['episodes'] as List<dynamic>?)
          ?.map((e) => Episode.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}
class Episode {
  final String title;
  final String description;
  final String podcastName;
  final String artist;
  final String releaseDate;
  final String duration;
  final int durationSec;
  final String url;
  final String feedUrl;
  final String rssAudioUrl;
  final String platform;
  final String type;
  final String episodeId;
  final int collectionId;
  final String imageUrl;
  final String? jobId;
  final String? topic;

  Episode({
    required this.title,
    required this.description,
    required this.podcastName,
    required this.artist,
    required this.releaseDate,
    required this.duration,
    required this.durationSec,
    required this.url,
    required this.feedUrl,
    required this.rssAudioUrl,
    required this.platform,
    required this.type,
    required this.episodeId,
    required this.collectionId,
    required this.imageUrl,
    this.jobId,
    this.topic,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      podcastName: json['podcast_name'] as String? ?? '',
      artist: json['artist'] as String? ?? '',
      releaseDate: json['release_date'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      durationSec: json['duration_sec'] as int? ?? 0,
      url: json['url'] as String? ?? '',
      feedUrl: json['feed_url'] as String? ?? '',
      rssAudioUrl: json['rss_audio_url'] as String? ?? '',
      platform: json['platform'] as String? ?? '',
      type: json['type'] as String? ?? '',
      episodeId: json['episode_id'] as String? ?? '',
      collectionId: json['collection_id'] as int? ?? 0,
      imageUrl: json['image_url'] as String? ?? '',
      jobId: json['job_id'] as String?, // can be null
      topic: json['topic'] as String?, // can be null
    );
  }
}

class Podcast {
  final String? title;
  final String? description;
  final String? podcastName;
  final String? artist;
  final String? releaseDate;
  final int? durationMs;
  final String? url;
  final String? imageUrl;
  final String? podcastId;

  Podcast({
    this.title,
    this.description,
    this.podcastName,
    this.artist,
    this.releaseDate,
    this.durationMs,
    this.url,
    this.imageUrl,
    this.podcastId,
  });

  factory Podcast.fromJson(Map<String, dynamic> json) {
    return Podcast(
      title: json['title'] as String?,
      description: json['description'] as String?,
      podcastName: json['podcast_name'] as String? ?? json['name'] as String?,
      artist: json['artist'] as String?,
      releaseDate: json['release_date'] as String?,
      durationMs: (json['duration_ms'] as num?)?.toInt(),
      url: json['url'] as String?,
      imageUrl: json['image_url'] as String?,
      podcastId: json['podcast_id'] as String? ?? json['Podcast_id'] as String?,
    );
  }

  // HELPERS
  String get formattedDuration {
    if (durationMs == null || durationMs == 0) return '0m 0s';
    final d = Duration(milliseconds: durationMs!);
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  String get safeImageUrl =>
      imageUrl?.isNotEmpty == true ? imageUrl! : 'https://via.placeholder.com/300';

  String get displayTitle =>
      title?.isNotEmpty == true ? title! : podcastName ?? 'Unknown Episode';

  String get displaySubtitle =>
      artist?.isNotEmpty == true ? artist! : podcastName ?? 'Unknown Show';
}