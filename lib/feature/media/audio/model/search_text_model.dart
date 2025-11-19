// lib/feature/summary/model/topic_summary_model.dart


import 'dart:convert';

class TopicSummaryModel {
  final String topic;
  final List<String> occurrences;
  final int count;
  final String explanation;

  TopicSummaryModel({
    required this.topic,
    required this.occurrences,
    required this.count,
    required this.explanation,
  });

  /// Factory: JSON Map থেকে অবজেক্ট তৈরি
  factory TopicSummaryModel.fromJson(Map<String, dynamic> json) {
    return TopicSummaryModel(
      topic: json['topic'] as String,
      occurrences: (json['occurrences'] as List<dynamic>).cast<String>(),
      count: json['count'] as int,
      explanation: json['explanation'] as String,
    );
  }

  /// toJson: অবজেক্ট থেকে JSON Map
  Map<String, dynamic> toJson() {
    return {
      'topic': topic,
      'occurrences': occurrences,
      'count': count,
      'explanation': explanation,
    };
  }

  /// Optional: copyWith for immutable updates
  TopicSummaryModel copyWith({
    String? topic,
    List<String>? occurrences,
    int? count,
    String? explanation,
  }) {
    return TopicSummaryModel(
      topic: topic ?? this.topic,
      occurrences: occurrences ?? this.occurrences,
      count: count ?? this.count,
      explanation: explanation ?? this.explanation,
    );
  }

  @override
  String toString() {
    return 'TopicSummaryModel(topic: $topic, occurrences: $occurrences, count: $count, explanation: ${explanation.substring(0, explanation.length.clamp(0, 100))}...)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TopicSummaryModel &&
        other.topic == topic &&
        other.occurrences == occurrences &&
        other.count == count &&
        other.explanation == explanation;
  }

  @override
  int get hashCode =>
      topic.hashCode ^ occurrences.hashCode ^ count.hashCode ^ explanation.hashCode;
}


// lib/feature/media/model/transcription_result_model.dart


class TranscriptionResult {
  final String? jobId;
  final String? url;
  final String? title;
  final String? podcastName;
  final String? topic;
  final String? status;
  final int? wordCount;
  final String? combinedSummary;
  final int? topicMentionCount;
  final DateTime? createdAt;
  final DateTime? completedAt;

  TranscriptionResult({
    this.jobId,
    this.url,
    this.title,
    this.podcastName,
    this.topic,
    this.status,
    this.wordCount,
    this.combinedSummary,
    this.topicMentionCount,
    this.createdAt,
    this.completedAt,
  });

  factory TranscriptionResult.fromJson(Map<String, dynamic> json) {
    return TranscriptionResult(
      jobId: json['job_id'] as String?,
      url: json['url'] as String?,
      title: json['title'] as String?,
      podcastName: json['podcast_name'] as String?,
      topic: json['topic'] as String?,
      status: json['status'] as String?,
      wordCount: json['word_count'] as int?,
      combinedSummary: json['combined_summary'] as String?,
      topicMentionCount: json['topic_mention_count'] as int?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_id': jobId,
      'url': url,
      'title': title,
      'podcast_name': podcastName,
      'topic': topic,
      'status': status,
      'word_count': wordCount,
      'combined_summary': combinedSummary,
      'topic_mention_count': topicMentionCount,
      'created_at': createdAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  @override
  String toString() => jsonEncode(toJson());
}