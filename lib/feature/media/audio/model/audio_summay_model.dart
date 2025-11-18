// lib/feature/media/audio/model/audio_summay_model.dart
import 'dart:convert';

class PodcastTranscriptModel {
  final String? message;
  final String? summary;
  final int? wordCount;

  PodcastTranscriptModel({
    this.message,
    this.summary,
    this.wordCount,
  });

  factory PodcastTranscriptModel.fromJson(dynamic json) {
    if (json is String) {
      return PodcastTranscriptModel(summary: json);
    }

    if (json is Map<String, dynamic>) {
      return PodcastTranscriptModel(
        message: json['message'] as String?,
        summary: json['summary'] as String?,
        wordCount: json['word_count'] as int?,
      );
    }

    return PodcastTranscriptModel(summary: json.toString());
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'summary': summary,
    'word_count': wordCount,
  };

  @override
  String toString() {
    final truncated = summary != null
        ? '${summary!.substring(0, summary!.length.clamp(0, 100))}...'
        : 'null';
    return 'PodcastTranscriptModel(message: $message, summary: $truncated, wordCount: $wordCount)';
  }
}


// lib/feature/media/model/episode_detail_model.dart

class EpisodeDetail {
  final String? title;
  final String? podcastName;
  final String? artist;
  final String? releaseDate;        // RFC 2822 format
  final int? durationMs;
  final String? url;                 // iTunes/Apple link
  final String? audioUrl;            // Direct .mp3 link
  final String? imageUrl;
  final String? description;
  final String? platform;
  final String? jobId;
  final bool? transcriptionReady;
  final String? transcriptionStatus;
  final String? topic;
  final String? message;

  EpisodeDetail({
    this.title,
    this.podcastName,
    this.artist,
    this.releaseDate,
    this.durationMs,
    this.url,
    this.audioUrl,
    this.imageUrl,
    this.description,
    this.platform,
    this.jobId,
    this.transcriptionReady,
    this.transcriptionStatus,
    this.topic,
    this.message,
  });

  // =============== FROM JSON ===============
  factory EpisodeDetail.fromJson(Map<String, dynamic> json) {
    return EpisodeDetail(
      title: json['title'] as String?,
      podcastName: json['podcast_name'] as String?,
      artist: json['artist'] as String?,
      releaseDate: json['release_date'] as String?,
      durationMs: json['duration_ms'] as int?,
      url: json['url'] as String?,
      audioUrl: json['audio_url'] as String?,
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
      platform: json['platform'] as String?,
      jobId: json['job_id'] as String?,
      transcriptionReady: json['transcription_ready'] as bool?,
      transcriptionStatus: json['transcription_status'] as String?,
      topic: json['topic'] as String?,
      message: json['message'] as String?,
    );
  }

  // =============== TO JSON ===============
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'podcast_name': podcastName,
      'artist': artist,
      'release_date': releaseDate,
      'duration_ms': durationMs,
      'url': url,
      'audio_url': audioUrl,
      'image_url': imageUrl,
      'description': description,
      'platform': platform,
      'job_id': jobId,
      'transcription_ready': transcriptionReady,
      'transcription_status': transcriptionStatus,
      'topic': topic,
      'message': message,
    };
  }

  @override
  String toString() => jsonEncode(toJson());
}