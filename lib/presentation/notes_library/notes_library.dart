import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
import './widgets/filter_chip_widget.dart';
import './widgets/note_card_widget.dart';
import './widgets/search_bar_widget.dart';

class NotesLibrary extends StatefulWidget {
  const NotesLibrary({super.key});

  @override
  State<NotesLibrary> createState() => _NotesLibraryState();
}

class _NotesLibraryState extends State<NotesLibrary> {
  List<Map<String, dynamic>> _notes = [];
  List<Map<String, dynamic>> _filteredNotes = [];
  List<Map<String, dynamic>> _categories = [];
  String _searchQuery = '';
  String _selectedFilter = 'All';
  bool _isLoading = true;

  final SupabaseService _supabaseService = SupabaseService();
  final AuthService _authService = AuthService();
  RealtimeChannel? _notesChannel;
  final TextEditingController _searchController = TextEditingController();
  final List<String> _recentSearches = [];

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
      final results = await Future.wait([
        _supabaseService.getUserNotes(),
        _supabaseService.getUserCategories(),
      ]);

      final notes = results[0];
      final categories = results[1];

      setState(() {
        _notes = notes;
        _categories = categories;
        _filteredNotes = notes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorMessage('Failed to load notes: ${e.toString()}');
    }
  }

  void _setupRealtimeSubscription() {
    if (!_authService.isAuthenticated) return;

    try {
      _notesChannel = _supabaseService.subscribeToUserNotes(onInsert: (note) {
        setState(() {
          _notes.insert(0, note);
          _applyFilters();
        });
      }, onUpdate: (note) {
        setState(() {
          final index = _notes.indexWhere((n) => n['id'] == note['id']);
          if (index != -1) {
            _notes[index] = note;
            _applyFilters();
          }
        });
      }, onDelete: (note) {
        setState(() {
          _notes.removeWhere((n) => n['id'] == note['id']);
          _applyFilters();
        });
      });
    } catch (e) {
      debugPrint('Failed to setup realtime subscription: $e');
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredNotes = _notes.where((note) {
        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          final title = note['title']?.toString().toLowerCase() ?? '';
          final content = note['content']?.toString().toLowerCase() ?? '';
          if (!title.contains(_searchQuery.toLowerCase()) &&
              !content.contains(_searchQuery.toLowerCase())) {
            return false;
          }
        }

        // Apply category filter
        if (_selectedFilter != 'All') {
          final categoryName = _getCategoryName(note['category_id']);
          if (categoryName != _selectedFilter) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  void _onFilterSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _applyFilters();
  }

  String _getCategoryName(String? categoryId) {
    if (categoryId == null) return 'General';
    final category = _categories.firstWhere((c) => c['id'] == categoryId,
        orElse: () => {'name': 'General'});
    return category['name'] ?? 'General';
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
                    size: 6.w),
                onPressed: () => Navigator.pop(context)),
            title: Text('Notes Library',
                style: AppTheme.lightTheme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
            centerTitle: true,
            actions: [
              IconButton(
                  icon: CustomIconWidget(
                      iconName: 'search',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 6.w),
                  onPressed: () {
                    // Focus search bar
                  }),
            ]),
        body: Column(children: [
          // Search Bar
          SearchBarWidget(
            controller: _searchController,
            onChanged: _onSearchChanged,
            recentSearches: _recentSearches,
          ),

          SizedBox(height: 2.h),

          // Filter Chips
          Container(
              height: 6.h,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: ListView(scrollDirection: Axis.horizontal, children: [
                FilterChipWidget(
                    label: 'All', 
                    isSelected: _selectedFilter == 'All',
                    onSelected: () => _onFilterSelected('All')),
                SizedBox(width: 2.w),
                ..._categories.map((category) {
                  final name = category['name'] as String;
                  return Row(children: [
                    FilterChipWidget(
                        label: name, 
                        isSelected: _selectedFilter == name,
                        onSelected: () => _onFilterSelected(name)),
                    SizedBox(width: 2.w),
                  ]);
                }).toList(),
              ])),

          SizedBox(height: 2.h),

          // Notes List
          Expanded(child: _buildNotesList()),
        ]),
        floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.pushNamed(context, '/note-capture'),
            backgroundColor: AppTheme.lightTheme.primaryColor,
            foregroundColor: Colors.white,
            child: CustomIconWidget(
                iconName: 'add', color: Colors.white, size: 6.w)));
  }

  Widget _buildNotesList() {
    if (_isLoading) {
      return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        CircularProgressIndicator(color: AppTheme.lightTheme.primaryColor),
        SizedBox(height: 2.h),
        Text('Loading notes...',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant)),
      ]));
    }

    if (_filteredNotes.isEmpty) {
      return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        CustomIconWidget(
            iconName: 'note_add',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 15.w),
        SizedBox(height: 2.h),
        Text(
            _searchQuery.isNotEmpty || _selectedFilter != 'All'
                ? 'No notes found'
                : 'No notes yet',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant)),
        SizedBox(height: 1.h),
        Text(
            _searchQuery.isNotEmpty || _selectedFilter != 'All'
                ? 'Try adjusting your search or filters'
                : 'Tap + to create your first note',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center),
      ]));
    }

    return RefreshIndicator(
        onRefresh: _initializeData,
        color: AppTheme.lightTheme.primaryColor,
        child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: _filteredNotes.length,
            itemBuilder: (context, index) {
              final note = _filteredNotes[index];
              return Padding(
                  padding: EdgeInsets.only(bottom: 2.h),
                  child: NoteCardWidget(
                      note: note,
                      categoryName: _getCategoryName(note['category_id']),
                      onTap: () => _handleNoteTap(note),
                      onEdit: () => _handleNoteEdit(note),
                      onDelete: () => _handleNoteDelete(note)));
            }));
  }

  void _handleNoteTap(Map<String, dynamic> note) {
    // Navigate to note detail/edit screen
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Open note: ${note["title"]}'),
        backgroundColor: AppTheme.lightTheme.primaryColor));
  }

  void _handleNoteEdit(Map<String, dynamic> note) {
    // Navigate to note edit screen
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Edit note: ${note["title"]}'),
        backgroundColor: AppTheme.lightTheme.primaryColor));
  }

  void _handleNoteDelete(Map<String, dynamic> note) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: Text('Delete Note'),
                content:
                    Text('Are you sure you want to delete "${note["title"]}"?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel')),
                  TextButton(
                      onPressed: () async {
                        Navigator.pop(context);

                        try {
                          await _supabaseService.deleteNote(noteId: note['id']);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Note deleted successfully'),
                              backgroundColor:
                                  AppTheme.lightTheme.primaryColor));
                        } catch (e) {
                          _showErrorMessage(
                              'Failed to delete note: ${e.toString()}');
                        }
                      },
                      child: Text('Delete',
                          style: TextStyle(
                              color: AppTheme.lightTheme.colorScheme.error))),
                ]));
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.error));
  }
}