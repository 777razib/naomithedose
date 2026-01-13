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


class TranscriptionResult {
  final String? jobId;
  final String? status;
  final String? summary;           // might be used elsewhere
  final String? error;
  //final String? combinedSummary;   // <-- THIS IS THE MISSING FIELD

  TranscriptionResult({
    this.jobId,
    this.status,
    this.summary,
    this.error,
    //this.combinedSummary,
  });

  factory TranscriptionResult.fromJson(Map<String, dynamic> json) {
    return TranscriptionResult(
      jobId: json['job_id'] as String?,
      status: json['status'] as String?,
      summary: json['summary'] as String?,
      error: json['error'] as String?,
      // Support both snake_case and camelCase from API
     // combinedSummary: json['combined_summary'] as String? ?? json['combinedSummary'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_id': jobId,
      'status': status,
      'summary': summary,
      'error': error,
      //'combined_summary': combinedSummary,
    };
  }

  @override
  String toString() => jsonEncode(toJson());
}
