import 'dart:typed_data';
import 'dart:convert';

/// Support classes for OpenAI API
class Message {
  final String role;
  final dynamic content;

  Message({required this.role, required this.content});
}

class Completion {
  final String text;

  Completion({required this.text});
}

class StreamCompletion {
  final String content;
  final String? finishReason;
  final String? systemFingerprint;

  StreamCompletion({
    required this.content,
    this.finishReason,
    this.systemFingerprint,
  });
}

class GeneratedImage {
  final String? url;
  final String? base64Data;

  GeneratedImage({this.url, this.base64Data});

  // Convert base64 data to image bytes
  Uint8List? get imageBytes =>
      base64Data != null ? base64Decode(base64Data!) : null;
}

class UsageInfo {
  final int totalTokens;
  final int inputTokens;
  final int outputTokens;
  final Map<String, dynamic>? inputTokensDetails;

  UsageInfo({
    required this.totalTokens,
    required this.inputTokens,
    required this.outputTokens,
    this.inputTokensDetails,
  });

  factory UsageInfo.fromJson(Map<String, dynamic> json) {
    return UsageInfo(
      totalTokens: json['total_tokens'] ?? 0,
      inputTokens: json['input_tokens'] ?? 0,
      outputTokens: json['output_tokens'] ?? 0,
      inputTokensDetails: json['input_tokens_details'],
    );
  }
}

class ImageGenerationResult {
  final List<GeneratedImage> images;
  final UsageInfo? usage;

  ImageGenerationResult({required this.images, this.usage});
}

class Transcription {
  final String text;

  Transcription({required this.text});
}

class OpenAIException implements Exception {
  final int statusCode;
  final String message;

  OpenAIException({required this.statusCode, required this.message});

  @override
  String toString() => 'OpenAIException: $statusCode - $message';
}
