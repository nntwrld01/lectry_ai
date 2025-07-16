import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
import './widgets/empty_state_widget.dart';
import './widgets/quick_stats_widget.dart';
import './widgets/recent_notes_list_widget.dart';
import './widgets/weekly_summary_card_widget.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _notes = [];
  Map<String, dynamic>? _currentWeeklySummary;
  Map<String, dynamic> _userStats = {};

  final SupabaseService _supabaseService = SupabaseService();
  final AuthService _authService = AuthService();
  RealtimeChannel? _notesChannel;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupRealtimeSubscription();
  }

  @override
  void dispose() {
    _notesChannel?.unsubscribe();
    super.dispose();
  }

  Future<void> _initializeData() async {
    if (!_authService.isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/authentication-screen');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final client = await _supabaseService.client;

      // Load user data in parallel
      final results = await Future.wait([
        _supabaseService.getUserNotes(),
        _supabaseService.getUserWeeklySummaries(),
        _supabaseService.getUserStats(),
      ]);

      final notes = results[0] as List<Map<String, dynamic>>;
      final summaries = results[1] as List<Map<String, dynamic>>;
      final stats = results[2] as Map<String, dynamic>;

      setState(() {
        _notes = notes;
        _currentWeeklySummary = summaries.isNotEmpty ? summaries.first : null;
        _userStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorMessage('Failed to load data: ${e.toString()}');
    }
  }

  void _setupRealtimeSubscription() {
    if (!_authService.isAuthenticated) return;

    try {
      _notesChannel = _supabaseService.subscribeToUserNotes(
        onInsert: (note) {
          setState(() {
            _notes.insert(0, note);
          });
          _updateStats();
        },
        onUpdate: (note) {
          setState(() {
            final index = _notes.indexWhere((n) => n['id'] == note['id']);
            if (index != -1) {
              _notes[index] = note;
            }
          });
        },
        onDelete: (note) {
          setState(() {
            _notes.removeWhere((n) => n['id'] == note['id']);
          });
          _updateStats();
        },
      );
    } catch (e) {
      debugPrint('Failed to setup realtime subscription: $e');
    }
  }

  Future<void> _updateStats() async {
    try {
      final stats = await _supabaseService.getUserStats();
      setState(() {
        _userStats = stats;
      });
    } catch (e) {
      debugPrint('Failed to update stats: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppTheme.lightTheme.primaryColor,
          child: CustomScrollView(
            slivers: [
              _buildHeader(),
              _buildMainContent(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Good ${_getTimeOfDay()}, ${_getUserName()}!",
                    style:
                        AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    _getCurrentDateString(),
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile-settings'),
              child: Container(
                padding: EdgeInsets.all(2.w),
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
                child: CustomIconWidget(
                  iconName: 'settings',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 6.w,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppTheme.lightTheme.primaryColor,
              ),
              SizedBox(height: 2.h),
              Text(
                'Loading your notes...',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_notes.isEmpty) {
      return SliverFillRemaining(
        child: EmptyStateWidget(
          onGetStarted: _handleCaptureFirstNote,
        ),
      );
    }

    return SliverList(
      delegate: SliverChildListDelegate([
        // Weekly Summary Card
        if (_currentWeeklySummary != null)
          WeeklySummaryCardWidget(
            summaryData: _currentWeeklySummary!,
            onViewFullSummary: () => _navigateToSummaries(),
          ),

        SizedBox(height: 2.h),

        // Quick Stats
        QuickStatsWidget(statsData: _userStats),

        SizedBox(height: 3.h),

        // Recent Notes Section
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recent Notes",
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () => _navigateToNotesLibrary(),
                child: Text(
                  "View All",
                  style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 1.h),

        // Recent Notes List
        RecentNotesListWidget(
          notes: _notes.take(5).toList(),
          onNoteEdit: _handleNoteEdit,
          onNoteDelete: _handleNoteDelete,
          onNoteTap: _handleNoteTap,
        ),

        SizedBox(height: 10.h), // Bottom padding for FAB
      ]),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _handleBottomNavTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        selectedItemColor: AppTheme.lightTheme.primaryColor,
        unselectedItemColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'home',
              color: _currentIndex == 0
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 6.w,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                CustomIconWidget(
                  iconName: 'note',
                  color: _currentIndex == 1
                      ? AppTheme.lightTheme.primaryColor
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 6.w,
                ),
                if (_notes.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(1.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 4.w,
                        minHeight: 4.w,
                      ),
                      child: Text(
                        '${_notes.length}',
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontSize: 8.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                CustomIconWidget(
                  iconName: 'summarize',
                  color: _currentIndex == 2
                      ? AppTheme.lightTheme.primaryColor
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 6.w,
                ),
                if (_currentWeeklySummary != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 2.w,
                      height: 2.w,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.tertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Summaries',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'person',
              color: _currentIndex == 3
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 6.w,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _handleNoteCapturePress,
      backgroundColor: AppTheme.lightTheme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      child: CustomIconWidget(
        iconName: 'add',
        color: Colors.white,
        size: 7.w,
      ),
    );
  }

  String _getCurrentDateString() {
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return "${months[now.month - 1]} ${now.day}, ${now.year}";
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  String _getUserName() {
    final user = _authService.currentUser;
    return user?.userMetadata?['full_name'] ?? 'User';
  }

  Future<void> _handleRefresh() async {
    await _initializeData();
  }

  void _handleBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Navigator.pushNamed(context, '/notes-library');
        break;
      case 2:
        _navigateToSummaries();
        break;
      case 3:
        Navigator.pushNamed(context, '/profile-settings');
        break;
    }
  }

  void _handleNoteCapturePress() {
    _showNoteCaptureModal();
  }

  void _showNoteCaptureModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: 30.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            SizedBox(height: 1.h),
            Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              "Capture Note",
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCaptureOption(
                    icon: 'camera_alt',
                    label: 'Camera',
                    onTap: () => _handleCameraCapture(),
                  ),
                  _buildCaptureOption(
                    icon: 'mic',
                    label: 'Voice',
                    onTap: () => _handleVoiceCapture(),
                  ),
                  _buildCaptureOption(
                    icon: 'edit',
                    label: 'Text',
                    onTap: () => _handleTextCapture(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptureOption({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 20.w,
        height: 20.w,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: AppTheme.lightTheme.primaryColor,
              size: 8.w,
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.lightTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCameraCapture() {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/note-capture');
  }

  void _handleVoiceCapture() {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/note-capture');
  }

  void _handleTextCapture() {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/note-capture');
  }

  void _handleCaptureFirstNote() {
    Navigator.pushNamed(context, '/note-capture');
  }

  void _navigateToSummaries() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Summaries screen coming soon!'),
        backgroundColor: AppTheme.lightTheme.primaryColor,
      ),
    );
  }

  void _navigateToNotesLibrary() {
    Navigator.pushNamed(context, '/notes-library');
  }

  void _handleNoteEdit(Map<String, dynamic> note) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit note: ${note["title"]}'),
        backgroundColor: AppTheme.lightTheme.primaryColor,
      ),
    );
  }

  void _handleNoteDelete(Map<String, dynamic> note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Note'),
        content: Text('Are you sure you want to delete "${note["title"]}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                await _supabaseService.deleteNote(noteId: note['id']);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Note deleted successfully'),
                    backgroundColor: AppTheme.lightTheme.primaryColor,
                  ),
                );
              } catch (e) {
                _showErrorMessage('Failed to delete note: ${e.toString()}');
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppTheme.lightTheme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNoteTap(Map<String, dynamic> note) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Open note: ${note["title"]}'),
        backgroundColor: AppTheme.lightTheme.primaryColor,
      ),
    );
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
