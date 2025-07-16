class NoteModel {
  final String id;
  final String title;
  final String content;
  final NoteType type;
  final DateTime timestamp;
  final String? thumbnail;
  final bool hasAudio;
  final String? duration;
  final List<String> tags;
  final String? category;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.timestamp,
    this.thumbnail,
    this.hasAudio = false,
    this.duration,
    this.tags = const [],
    this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type.toString(),
      'timestamp': timestamp.toIso8601String(),
      'thumbnail': thumbnail,
      'hasAudio': hasAudio,
      'duration': duration,
      'tags': tags,
      'category': category,
    };
  }

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      type: NoteType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => NoteType.text,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      thumbnail: json['thumbnail'],
      hasAudio: json['hasAudio'] ?? false,
      duration: json['duration'],
      tags: List<String>.from(json['tags'] ?? []),
      category: json['category'],
    );
  }

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    NoteType? type,
    DateTime? timestamp,
    String? thumbnail,
    bool? hasAudio,
    String? duration,
    List<String>? tags,
    String? category,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      thumbnail: thumbnail ?? this.thumbnail,
      hasAudio: hasAudio ?? this.hasAudio,
      duration: duration ?? this.duration,
      tags: tags ?? this.tags,
      category: category ?? this.category,
    );
  }
}

enum NoteType { text, audio, image, mixed }

class WeeklySummaryModel {
  final String id;
  final String title;
  final DateTime weekStart;
  final DateTime weekEnd;
  final String insights;
  final List<String> keyTakeaways;
  final List<String> tasksIdentified;
  final List<String> studyQuestions;
  final int totalNotes;
  final Map<String, int> categoryBreakdown;
  final bool isGenerated;
  final DateTime? generatedAt;

  WeeklySummaryModel({
    required this.id,
    required this.title,
    required this.weekStart,
    required this.weekEnd,
    required this.insights,
    required this.keyTakeaways,
    required this.tasksIdentified,
    required this.studyQuestions,
    required this.totalNotes,
    required this.categoryBreakdown,
    this.isGenerated = false,
    this.generatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'weekStart': weekStart.toIso8601String(),
      'weekEnd': weekEnd.toIso8601String(),
      'insights': insights,
      'keyTakeaways': keyTakeaways,
      'tasksIdentified': tasksIdentified,
      'studyQuestions': studyQuestions,
      'totalNotes': totalNotes,
      'categoryBreakdown': categoryBreakdown,
      'isGenerated': isGenerated,
      'generatedAt': generatedAt?.toIso8601String(),
    };
  }

  factory WeeklySummaryModel.fromJson(Map<String, dynamic> json) {
    return WeeklySummaryModel(
      id: json['id'],
      title: json['title'],
      weekStart: DateTime.parse(json['weekStart']),
      weekEnd: DateTime.parse(json['weekEnd']),
      insights: json['insights'],
      keyTakeaways: List<String>.from(json['keyTakeaways'] ?? []),
      tasksIdentified: List<String>.from(json['tasksIdentified'] ?? []),
      studyQuestions: List<String>.from(json['studyQuestions'] ?? []),
      totalNotes: json['totalNotes'],
      categoryBreakdown: Map<String, int>.from(json['categoryBreakdown'] ?? {}),
      isGenerated: json['isGenerated'] ?? false,
      generatedAt: json['generatedAt'] != null
          ? DateTime.parse(json['generatedAt'])
          : null,
    );
  }
}
