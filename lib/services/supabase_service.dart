import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  late final SupabaseClient _client;
  bool _isInitialized = false;
  final Future<void> _initFuture;

  // Singleton pattern
  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal() : _initFuture = _initializeSupabase();

  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  // Internal initialization logic
  static Future<void> _initializeSupabase() async {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
          'SUPABASE_URL and SUPABASE_ANON_KEY must be defined using --dart-define.');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    _instance._client = Supabase.instance.client;
    _instance._isInitialized = true;
  }

  // Client getter (async)
  Future<SupabaseClient> get client async {
    if (!_isInitialized) {
      await _initFuture;
    }
    return _client;
  }

  // Sync client getter for when we know it's already initialized
  SupabaseClient get clientSync {
    if (!_isInitialized) {
      throw Exception('Supabase not initialized. Call client getter first.');
    }
    return _client;
  }

  // Auth helpers
  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Authentication methods
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': 'basic',
        },
      );
      return response;
    } catch (error) {
      throw Exception('Sign-up failed: $error');
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (error) {
      throw Exception('Sign-in failed: $error');
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (error) {
      throw Exception('Sign-out failed: $error');
    }
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (error) {
      throw Exception('Password reset failed: $error');
    }
  }

  // OAuth Sign-in
  Future<bool> signInWithGoogle() async {
    try {
      return await _client.auth.signInWithOAuth(OAuthProvider.google);
    } catch (error) {
      throw Exception('Google sign-in failed: $error');
    }
  }

  Future<bool> signInWithApple() async {
    try {
      return await _client.auth.signInWithOAuth(OAuthProvider.apple);
    } catch (error) {
      throw Exception('Apple sign-in failed: $error');
    }
  }

  // User profile methods
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to get user profile: $error');
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _client.from('user_profiles').update(updates).eq('id', userId);
    } catch (error) {
      throw Exception('Failed to update user profile: $error');
    }
  }

  // Notes methods
  Future<List<Map<String, dynamic>>> getUserNotes() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('notes')
          .select('*, categories!inner(name, color, icon)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get user notes: $error');
    }
  }

  Future<Map<String, dynamic>> createNote({
    required String title,
    required String content,
    required String type,
    String? categoryId,
    String? thumbnailUrl,
    String? audioUrl,
    bool hasAudio = false,
    String? duration,
    List<String> tags = const [],
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('notes')
          .insert({
            'title': title,
            'content': content,
            'type': type,
            'user_id': user.id,
            'category_id': categoryId,
            'thumbnail_url': thumbnailUrl,
            'audio_url': audioUrl,
            'has_audio': hasAudio,
            'duration': duration,
            'tags': tags,
          })
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to create note: $error');
    }
  }

  Future<void> updateNote({
    required String noteId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _client.from('notes').update(updates).eq('id', noteId);
    } catch (error) {
      throw Exception('Failed to update note: $error');
    }
  }

  Future<void> deleteNote({required String noteId}) async {
    try {
      await _client.from('notes').delete().eq('id', noteId);
    } catch (error) {
      throw Exception('Failed to delete note: $error');
    }
  }

  // Categories methods
  Future<List<Map<String, dynamic>>> getUserCategories() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('categories')
          .select()
          .eq('user_id', user.id)
          .order('is_system_category', ascending: false)
          .order('name', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get user categories: $error');
    }
  }

  Future<Map<String, dynamic>> createCategory({
    required String name,
    required String color,
    required String icon,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('categories')
          .insert({
            'name': name,
            'color': color,
            'icon': icon,
            'user_id': user.id,
          })
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to create category: $error');
    }
  }

  // Weekly summaries methods
  Future<List<Map<String, dynamic>>> getUserWeeklySummaries() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('weekly_summaries')
          .select()
          .eq('user_id', user.id)
          .order('week_start', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get weekly summaries: $error');
    }
  }

  Future<Map<String, dynamic>> createWeeklySummary({
    required String title,
    required String weekStart,
    required String weekEnd,
    required String insights,
    required List<String> keyTakeaways,
    required List<String> tasksIdentified,
    required List<String> studyQuestions,
    required int totalNotes,
    required Map<String, dynamic> categoryBreakdown,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('weekly_summaries')
          .insert({
            'title': title,
            'week_start': weekStart,
            'week_end': weekEnd,
            'insights': insights,
            'key_takeaways': keyTakeaways,
            'tasks_identified': tasksIdentified,
            'study_questions': studyQuestions,
            'total_notes': totalNotes,
            'category_breakdown': categoryBreakdown,
            'user_id': user.id,
            'is_generated': true,
            'generated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to create weekly summary: $error');
    }
  }

  // Real-time subscriptions
  RealtimeChannel subscribeToUserNotes({
    required Function(Map<String, dynamic>) onInsert,
    required Function(Map<String, dynamic>) onUpdate,
    required Function(Map<String, dynamic>) onDelete,
  }) {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    return _client
        .channel('user_notes_${user.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notes',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: user.id,
          ),
          callback: (payload) => onInsert(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'notes',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: user.id,
          ),
          callback: (payload) => onUpdate(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'notes',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: user.id,
          ),
          callback: (payload) => onDelete(payload.oldRecord),
        )
        .subscribe();
  }

  // Statistics methods
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get current week stats
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(Duration(days: 6));

      final results = await Future.wait([
        // Total notes count
        _client.from('notes').select().eq('user_id', user.id).count(),

        // Weekly notes count
        _client
            .from('notes')
            .select()
            .eq('user_id', user.id)
            .gte('created_at', weekStart.toIso8601String())
            .lte('created_at', weekEnd.toIso8601String())
            .count(),

        // Weekly summaries count
        _client
            .from('weekly_summaries')
            .select()
            .eq('user_id', user.id)
            .count(),
      ]);

      return {
        'total_notes': results[0].count ?? 0,
        'weekly_notes': results[1].count ?? 0,
        'weekly_summaries': results[2].count ?? 0,
        'week_progress': now.weekday / 7.0,
      };
    } catch (error) {
      throw Exception('Failed to get user stats: $error');
    }
  }
}
