import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VoiceInputWidget extends StatefulWidget {
  final Function(File) onVoiceRecorded;
  final Function(String) onTranscriptionComplete;
  final bool isLoading;

  const VoiceInputWidget({
    super.key,
    required this.onVoiceRecorded,
    required this.onTranscriptionComplete,
    this.isLoading = false,
  });

  @override
  State<VoiceInputWidget> createState() => _VoiceInputWidgetState();
}

class _VoiceInputWidgetState extends State<VoiceInputWidget> {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  bool _isRecording = false;
  bool _isPlaying = false;
  bool _hasRecording = false;
  String _recordingPath = '';
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  String _transcriptionText = '';

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Recording Status
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isRecording
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                // Recording Icon and Status
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    color: _isRecording
                        ? AppTheme.lightTheme.colorScheme.error
                        : AppTheme.lightTheme.primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: _isRecording
                        ? [
                            BoxShadow(
                              color: AppTheme.lightTheme.colorScheme.error
                                  .withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: _isRecording ? 'stop' : 'mic',
                      color: Colors.white,
                      size: 10.w,
                    ),
                  ),
                ),

                SizedBox(height: 2.h),

                // Status Text
                Text(
                  _isRecording
                      ? 'Recording...'
                      : _hasRecording
                          ? 'Recording Complete'
                          : 'Tap to Start Recording',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: _isRecording
                        ? AppTheme.lightTheme.colorScheme.error
                        : AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 1.h),

                // Recording Duration
                if (_isRecording || _hasRecording)
                  Text(
                    _formatDuration(_recordingDuration),
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Control Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Record/Stop Button
              ElevatedButton(
                onPressed: _isRecording ? _stopRecording : _startRecording,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRecording
                      ? AppTheme.lightTheme.colorScheme.error
                      : AppTheme.lightTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: _isRecording ? 'stop' : 'mic',
                      color: Colors.white,
                      size: 5.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      _isRecording ? 'Stop' : 'Record',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Play/Pause Button
              if (_hasRecording)
                ElevatedButton(
                  onPressed: _isPlaying ? _pausePlayback : _startPlayback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
                    foregroundColor: Colors.white,
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: _isPlaying ? 'pause' : 'play_arrow',
                        color: Colors.white,
                        size: 5.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        _isPlaying ? 'Pause' : 'Play',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          SizedBox(height: 3.h),

          // Transcription Section
          if (_hasRecording) ...[
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'transcribe',
                        color: AppTheme.lightTheme.primaryColor,
                        size: 5.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Transcription',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  if (widget.isLoading)
                    Row(
                      children: [
                        SizedBox(
                          width: 5.w,
                          height: 5.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.lightTheme.primaryColor,
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          'Transcribing audio...',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    )
                  else if (_transcriptionText.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppTheme
                            .lightTheme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _transcriptionText,
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                    )
                  else
                    ElevatedButton(
                      onPressed: _transcribeAudio,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.lightTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Transcribe Audio'),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        final audioPath =
            '${tempDir.path}/voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: audioPath,
        );

        setState(() {
          _isRecording = true;
          _recordingPath = audioPath;
          _recordingDuration = Duration.zero;
          _hasRecording = false;
          _transcriptionText = '';
        });

        _startTimer();
      } else {
        _showErrorMessage('Microphone permission denied');
      }
    } catch (e) {
      _showErrorMessage('Failed to start recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _recorder.stop();
      _recordingTimer?.cancel();

      setState(() {
        _isRecording = false;
        _hasRecording = true;
      });

      if (_recordingPath.isNotEmpty) {
        final audioFile = File(_recordingPath);
        widget.onVoiceRecorded(audioFile);
      }
    } catch (e) {
      _showErrorMessage('Failed to stop recording: $e');
    }
  }

  Future<void> _startPlayback() async {
    try {
      await _player.setFilePath(_recordingPath);
      await _player.play();

      setState(() {
        _isPlaying = true;
      });

      _player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          setState(() {
            _isPlaying = false;
          });
        }
      });
    } catch (e) {
      _showErrorMessage('Failed to play audio: $e');
    }
  }

  Future<void> _pausePlayback() async {
    try {
      await _player.pause();
      setState(() {
        _isPlaying = false;
      });
    } catch (e) {
      _showErrorMessage('Failed to pause audio: $e');
    }
  }

  Future<void> _transcribeAudio() async {
    if (_recordingPath.isEmpty) return;

    try {
      final audioFile = File(_recordingPath);
      widget.onVoiceRecorded(audioFile);
    } catch (e) {
      _showErrorMessage('Failed to transcribe audio: $e');
    }
  }

  void _startTimer() {
    _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration = Duration(seconds: timer.tick);
      });
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
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
