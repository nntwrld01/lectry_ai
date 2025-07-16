import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
import './widgets/camera_input_widget.dart';
import './widgets/category_tags_widget.dart';
import './widgets/text_input_widget.dart';
import './widgets/voice_input_widget.dart';

class NoteCapture extends StatefulWidget {
  const NoteCapture({super.key});

  @override
  State<NoteCapture> createState() => _NoteCaptureState();
}

class _NoteCaptureState extends State<NoteCapture>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  bool _isSaving = false;

  final SupabaseService _supabaseService = SupabaseService();
  final AuthService _authService = AuthService();
  final LectryAIService _aiService = LectryAIService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  String _selectedCategory = 'General';
  String? _selectedCategoryId;
  List<String> _selectedTags = [];
  List<Map<String, dynamic>> _categories = [];

  // Content from different input methods
  String _textContent = '';
  String _voiceContent = '';
  String _imageContent = '';
  File? _capturedImage;
  File? _recordedAudio;

  final List<String> _availableTags = [
    'important',
    'urgent',
    'todo',
    'reminder',
    'review',
    'follow-up',
    'deadline',
    'notes',
    'lecture',
    'meeting',
    'brainstorm',
    'planning',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (!_authService.isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/authentication-screen');
      return;
    }

    try {
      await _aiService.initialize();
      final categories = await _supabaseService.getUserCategories();
      setState(() {
        _categories = categories;
        // Set default category
        if (categories.isNotEmpty) {
          final generalCategory = categories.firstWhere(
            (c) => c['name'] == 'General',
            orElse: () => categories.first,
          );
          _selectedCategory = generalCategory['name'];
          _selectedCategoryId = generalCategory['id'];
        }
      });
    } catch (e) {
      _showErrorMessage('Failed to load categories: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Capture Note',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isSaving)
            Padding(
              padding: EdgeInsets.only(right: 4.w),
              child: Center(
                child: SizedBox(
                  width: 5.w,
                  height: 5.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.lightTheme.primaryColor,
                    ),
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _isSaving ? null : _saveNote,
              child: Text(
                'Save',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.lightTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.shadow
                      .withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.lightTheme.primaryColor,
              unselectedLabelColor:
                  AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              indicatorColor: AppTheme.lightTheme.primaryColor,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                  icon: CustomIconWidget(iconName: 'edit', size: 5.w),
                  text: 'Text',
                ),
                Tab(
                  icon: CustomIconWidget(iconName: 'mic', size: 5.w),
                  text: 'Voice',
                ),
                Tab(
                  icon: CustomIconWidget(iconName: 'camera_alt', size: 5.w),
                  text: 'Camera',
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Text Input Tab
                TextInputWidget(
                  onContentChanged: (content) {
                    setState(() {
                      _textContent = content;
                    });
                  },
                ),

                // Voice Input Tab
                VoiceInputWidget(
                  onVoiceRecorded: _handleVoiceRecording,
                  onTranscriptionComplete: _handleTranscriptionComplete,
                  isLoading: _isLoading,
                ),

                // Camera Input Tab
                CameraInputWidget(
                  onImageCaptured: _handleImageCapture,
                  onImageAnalyzed: _handleImageAnalysis,
                  isLoading: _isLoading,
                  capturedImage: _capturedImage,
                ),
              ],
            ),
          ),

          // Category and Tags Section
          Container(
            padding: EdgeInsets.all(4.w),
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.shadow
                      .withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: CategoryTagsWidget(
              categories: _categories.map((c) => c['name'] as String).toList(),
              selectedCategory: _selectedCategory,
              onCategorySelected: (category) {
                setState(() {
                  _selectedCategory = category;
                  _selectedCategoryId = _categories.firstWhere(
                    (c) => c['name'] == category,
                  )['id'];
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleVoiceRecording(File audioFile) async {
    setState(() {
      _recordedAudio = audioFile;
      _isLoading = true;
    });

    try {
      final transcription = await _aiService.transcribeAudio(audioFile);
      setState(() {
        _voiceContent = transcription;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorMessage('Failed to transcribe audio: ${e.toString()}');
    }
  }

  void _handleTranscriptionComplete(String transcription) {
    setState(() {
      _voiceContent = transcription;
      _titleController.text = _titleController.text.isEmpty
          ? 'Voice Note ${DateTime.now().toString().substring(0, 16)}'
          : _titleController.text;
      _contentController.text = transcription;
    });
  }

  Future<void> _handleImageCapture(File imageFile) async {
    setState(() {
      _capturedImage = imageFile;
      _isLoading = true;
    });

    try {
      final imageBytes = await imageFile.readAsBytes();
      final analysis = await _aiService.analyzeImage(imageBytes);

      setState(() {
        _imageContent = analysis;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorMessage('Failed to analyze image: ${e.toString()}');
    }
  }

  void _handleImageAnalysis(String analysis) {
    setState(() {
      _imageContent = analysis;
      _titleController.text = _titleController.text.isEmpty
          ? 'Image Note ${DateTime.now().toString().substring(0, 16)}'
          : _titleController.text;
      _contentController.text = analysis;
    });
  }

  Future<void> _saveNote() async {
    if (_titleController.text.trim().isEmpty) {
      _showErrorMessage('Please enter a title for your note');
      return;
    }

    final content = _getContentFromActiveTab();
    if (content.trim().isEmpty) {
      _showErrorMessage('Please add some content to your note');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Create note in Supabase
      final noteData = await _supabaseService.createNote(
        title: _titleController.text.trim(),
        content: content,
        type: _getNoteTypeString(),
        categoryId: _selectedCategoryId,
        thumbnailUrl: _capturedImage?.path,
        audioUrl: _recordedAudio?.path,
        hasAudio: _recordedAudio != null,
        duration: _recordedAudio != null ? '0:00' : null,
        tags: _selectedTags,
      );

      // Generate AI summary for the note (optional, don't block on failure)
      try {
        final summary = await _aiService.generateNoteSummary(content);
        debugPrint('AI Summary: $summary');
      } catch (e) {
        debugPrint('Failed to generate AI summary: $e');
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Note saved successfully!'),
          backgroundColor: AppTheme.lightTheme.primaryColor,
        ),
      );

      // Navigate back
      Navigator.pop(context);
    } catch (e) {
      _showErrorMessage('Failed to save note: ${e.toString()}');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  String _getContentFromActiveTab() {
    switch (_tabController.index) {
      case 0:
        return _contentController.text.trim();
      case 1:
        return _voiceContent.trim();
      case 2:
        return _imageContent.trim();
      default:
        return '';
    }
  }

  String _getNoteTypeString() {
    switch (_tabController.index) {
      case 0:
        return 'text';
      case 1:
        return 'audio';
      case 2:
        return 'image';
      default:
        return 'text';
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
      ),
    );
  }
}
