import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class AuthService {
  final SupabaseService _supabaseService = SupabaseService();

  // Get current user
  User? get currentUser => _supabaseService.currentUser;

  // Auth state stream
  Stream<AuthState> get authStateChanges => _supabaseService.authStateChanges;

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _supabaseService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );

      if (response.user != null) {
        // User profile will be created automatically via database trigger
        await Future.delayed(Duration(seconds: 1)); // Allow trigger to complete
      }

      return response;
    } catch (error) {
      throw Exception('Sign up failed: $error');
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseService.signIn(
        email: email,
        password: password,
      );

      return response;
    } catch (error) {
      throw Exception('Sign in failed: $error');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
    } catch (error) {
      throw Exception('Sign out failed: $error');
    }
  }

  // Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      await _supabaseService.resetPassword(email: email);
    } catch (error) {
      throw Exception('Password reset failed: $error');
    }
  }

  // Google sign in
  Future<bool> signInWithGoogle() async {
    try {
      final result = await _supabaseService.signInWithGoogle();
      return result;
    } catch (error) {
      throw Exception('Google sign in failed: $error');
    }
  }

  // Apple sign in
  Future<bool> signInWithApple() async {
    try {
      final result = await _supabaseService.signInWithApple();
      return result;
    } catch (error) {
      throw Exception('Apple sign in failed: $error');
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      return await _supabaseService.getCurrentUserProfile();
    } catch (error) {
      throw Exception('Failed to get user profile: $error');
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required Map<String, dynamic> updates,
  }) async {
    try {
      if (currentUser == null) throw Exception('User not authenticated');

      await _supabaseService.updateUserProfile(
        userId: currentUser!.id,
        updates: updates,
      );
    } catch (error) {
      throw Exception('Failed to update user profile: $error');
    }
  }

  // Validate email format
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate password strength
  bool isValidPassword(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    return true;
  }

  // Get password strength score
  int getPasswordStrength(String password) {
    int score = 0;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;
    return score;
  }

  // Get password strength label
  String getPasswordStrengthLabel(int score) {
    switch (score) {
      case 0:
      case 1:
        return 'Weak';
      case 2:
      case 3:
        return 'Medium';
      case 4:
      case 5:
        return 'Strong';
      default:
        return 'Weak';
    }
  }
}
