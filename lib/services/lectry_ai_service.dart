import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/note_model.dart';
import '../models/openai_models.dart';
import './openai_client.dart';
import './openai_service.dart';

class LectryAIService {
  static final LectryAIService _instance = LectryAIService._internal();
  late final OpenAIClient _openAIClient;
  late final SharedPreferences _prefs;

  factory LectryAIService() {
    return _instance;
  }

  LectryAIService._internal() {
    _openAIClient = OpenAIClient(OpenAIService().dio);
  }

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Generate summary from text notes
  Future<String> generateNoteSummary(String noteContent) async {
    try {
      final messages = [
        Message(
          role: 'user',
          content: [
            {
              'type': 'text',
              'text': '''
Analyze this note and provide a structured summary:

Note Content: $noteContent

Please provide:
1. Key points (3-5 bullet points)
2. Main topics covered
3. Any actionable items or tasks mentioned
4. Important concepts or terms

Format the response clearly with headers.
'''
            }
          ],
        ),
      ];

      final response = await _openAIClient.createChatCompletion(
        messages: messages,
        model: 'gpt-4o-mini',
        options: {'temperature': 0.7},
      );

      return response.text;
    } catch (e) {
      throw Exception('Failed to generate note summary: $e');
    }
  }

  /// Generate weekly summary from multiple notes
  Future<WeeklySummaryModel> generateWeeklySummary(
      List<NoteModel> notes) async {
    try {
      final notesSummary = notes
          .map((note) => {
                'title': note.title,
                'content': note.content,
                'type': note.type.toString(),
                'timestamp': note.timestamp.toIso8601String(),
                'category': note.category ?? 'General',
                'tags': note.tags,
              })
          .toList();

      final messages = [
        Message(
          role: 'user',
          content: [
            {
              'type': 'text',
              'text': '''
Generate a comprehensive weekly summary based on these notes:

${jsonEncode(notesSummary)}

Please provide a JSON response with the following structure:
{
  "insights": "Overall insights about the week's learning and productivity",
  "keyTakeaways": ["takeaway1", "takeaway2", "takeaway3"],
  "tasksIdentified": ["task1", "task2", "task3"],
  "studyQuestions": ["question1", "question2", "question3"],
  "categoryBreakdown": {"category1": count, "category2": count}
}

Focus on:
- Learning patterns and knowledge gaps
- Productivity insights
- Actionable next steps
- Study recommendations
- Important concepts that need reinforcement

Make it engaging and actionable for a student or professional.
'''
            }
          ],
        ),
      ];

      final response = await _openAIClient.createChatCompletion(
        messages: messages,
        model: 'gpt-4o',
        options: {'temperature': 0.7},
      );

      // Parse the AI response
      final aiData = jsonDecode(response.text);

      // Calculate week start and end
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(Duration(days: 6));

      // Create category breakdown
      final categoryBreakdown = <String, int>{};
      for (final note in notes) {
        final category = note.category ?? 'General';
        categoryBreakdown[category] = (categoryBreakdown[category] ?? 0) + 1;
      }

      return WeeklySummaryModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Week of ${_formatDate(weekStart)} - ${_formatDate(weekEnd)}',
        weekStart: weekStart,
        weekEnd: weekEnd,
        insights: aiData['insights'] ?? 'No insights available',
        keyTakeaways: List<String>.from(aiData['keyTakeaways'] ?? []),
        tasksIdentified: List<String>.from(aiData['tasksIdentified'] ?? []),
        studyQuestions: List<String>.from(aiData['studyQuestions'] ?? []),
        totalNotes: notes.length,
        categoryBreakdown: categoryBreakdown,
        isGenerated: true,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to generate weekly summary: $e');
    }
  }

  /// Transcribe audio to text
  Future<String> transcribeAudio(File audioFile) async {
    try {
      final transcription = await _openAIClient.transcribeAudio(
        audioFile: audioFile,
        model: 'whisper-1',
      );
      return transcription.text;
    } catch (e) {
      throw Exception('Failed to transcribe audio: $e');
    }
  }

  /// Analyze image and extract text/content
  Future<String> analyzeImage(Uint8List imageBytes) async {
    try {
      final response = await _openAIClient.generateTextFromImage(
        imageBytes: imageBytes,
        promptText: '''
Analyze this image and extract all text content, diagrams, and key information.

Please provide:
1. All visible text (transcribed accurately)
2. Description of any diagrams, charts, or visual elements
3. Key concepts or subjects shown
4. Any mathematical formulas or equations
5. Overall context and purpose of the content

Format the response clearly with headers for each section.
''',
        model: 'gpt-4o',
      );
      return response.text;
    } catch (e) {
      throw Exception('Failed to analyze image: $e');
    }
  }

  /// Generate study questions from note content
  Future<List<String>> generateStudyQuestions(String noteContent) async {
    try {
      final messages = [
        Message(
          role: 'user',
          content: [
            {
              'type': 'text',
              'text': '''
Based on this note content, generate 5-7 study questions that would help reinforce understanding:

$noteContent

Format: Return only the questions as a JSON array of strings.
Example: ["Question 1?", "Question 2?", "Question 3?"]
'''
            }
          ],
        ),
      ];

      final response = await _openAIClient.createChatCompletion(
        messages: messages,
        model: 'gpt-4o-mini',
        options: {'temperature': 0.7},
      );

      final questions = jsonDecode(response.text) as List;
      return questions.map((q) => q.toString()).toList();
    } catch (e) {
      throw Exception('Failed to generate study questions: $e');
    }
  }

  /// Save notes to local storage
  Future<void> saveNotes(List<NoteModel> notes) async {
    final notesJson = notes.map((note) => note.toJson()).toList();
    await _prefs.setString('notes', jsonEncode(notesJson));
  }

  /// Load notes from local storage
  Future<List<NoteModel>> loadNotes() async {
    final notesString = _prefs.getString('notes');
    if (notesString == null) return [];

    final notesJson = jsonDecode(notesString) as List;
    return notesJson.map((json) => NoteModel.fromJson(json)).toList();
  }

  /// Save weekly summary to local storage
  Future<void> saveWeeklySummary(WeeklySummaryModel summary) async {
    final summariesString = _prefs.getString('weekly_summaries') ?? '[]';
    final summariesJson = jsonDecode(summariesString) as List;

    // Remove existing summary for the same week
    summariesJson.removeWhere(
        (s) => s['weekStart'] == summary.weekStart.toIso8601String());

    // Add new summary
    summariesJson.add(summary.toJson());

    await _prefs.setString('weekly_summaries', jsonEncode(summariesJson));
  }

  /// Load weekly summaries from local storage
  Future<List<WeeklySummaryModel>> loadWeeklySummaries() async {
    final summariesString = _prefs.getString('weekly_summaries') ?? '[]';
    final summariesJson = jsonDecode(summariesString) as List;
    return summariesJson
        .map((json) => WeeklySummaryModel.fromJson(json))
        .toList();
  }

  /// Check if weekly summary exists for current week
  Future<WeeklySummaryModel?> getCurrentWeeklySummary() async {
    final summaries = await loadWeeklySummaries();
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    for (final summary in summaries) {
      if (summary.weekStart.year == weekStart.year &&
          summary.weekStart.month == weekStart.month &&
          summary.weekStart.day == weekStart.day) {
        return summary;
      }
    }
    return null;
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}
