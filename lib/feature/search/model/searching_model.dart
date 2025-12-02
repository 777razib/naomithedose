

class SearchResult {
  final List<Episode>? episodes;
  final int? total;

  SearchResult({this.episodes, this.total});

  factory SearchResult.fromJson(Map<String, dynamic> json) => SearchResult(
    episodes: json['episodes'] != null
        ? List<Episode>.from(
        (json['episodes'] as List).map((x) => Episode.fromJson(x)))
        : [],
    total: json['total'] as int?,
  );

  Map<String, dynamic> toJson() => {
    'episodes': episodes?.map((x) => x.toJson()).toList(),
    'total': total,
  };
}
class Episode {
  final String? id;
  final String? title;
  final String? description;
  final String? url;
  final String? imageUrl;
  final String? artist;
  final String? podcastName;
  final String? releaseDate;

  Episode({
    this.id,
    this.title,
    this.description,
    this.url,
    this.imageUrl,
    this.artist,
    this.podcastName,
    this.releaseDate,
  });

  factory Episode.fromJson(Map<String, dynamic> json) => Episode(
    id: json['id'] as String?,
    title: json['title'] as String?,
    description: json['description'] as String?,
    url: json['url'] as String?,
    imageUrl: json['image_url'] as String?,
    artist: json['artist'] as String?,
    podcastName: json['podcast_name'] as String?,
    releaseDate: json['release_date'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'url': url,
    'image_url': imageUrl,
    'artist': artist,
    'podcast_name': podcastName,
    'release_date': releaseDate,
  };
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