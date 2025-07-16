import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
import './widgets/preference_item_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/subscription_card_widget.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  bool _isLoading = true;
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic> _preferences = {};

  final AuthService _authService = AuthService();
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (!_authService.isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/authentication-screen');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final profile = await _supabaseService.getCurrentUserProfile();
      setState(() {
        _userProfile = profile;
        _preferences = profile?['preferences'] ?? {};
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorMessage('Failed to load profile: ${e.toString()}');
    }
  }

  Future<void> _updatePreference(String key, dynamic value) async {
    try {
      final updatedPreferences = Map<String, dynamic>.from(_preferences);
      updatedPreferences[key] = value;

      await _supabaseService.updateUserProfile(
          userId: _authService.currentUser!.id,
          updates: {'preferences': updatedPreferences});

      setState(() {
        _preferences = updatedPreferences;
      });
    } catch (e) {
      _showErrorMessage('Failed to update preference: ${e.toString()}');
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      Navigator.pushReplacementNamed(context, '/authentication-screen');
    } catch (e) {
      _showErrorMessage('Failed to sign out: ${e.toString()}');
    }
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
            title: Text('Profile & Settings',
                style: AppTheme.lightTheme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
            centerTitle: true),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                    color: AppTheme.lightTheme.primaryColor))
            : RefreshIndicator(
                onRefresh: _loadUserProfile,
                color: AppTheme.lightTheme.primaryColor,
                child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(children: [
                      SizedBox(height: 2.h),

                      // Profile Header
                      ProfileHeaderWidget(
                          userProfile: _userProfile,
                          onEditProfile: _handleEditProfile),

                      SizedBox(height: 3.h),

                      // Subscription Card
                      SubscriptionCardWidget(
                          subscriptionData: _userProfile?['subscription'],
                          onManageSubscription: _handleUpgrade),

                      SizedBox(height: 3.h),

                      // App Preferences
                      SettingsSectionWidget(
                          title: 'App Preferences',
                          children: [
                            PreferenceItemWidget(
                                title: 'Dark Mode',
                                subtitle: 'Switch to dark theme',
                                leadingIcon: 'dark_mode'),
                            PreferenceItemWidget(
                                title: 'Notifications',
                                subtitle: 'Receive push notifications',
                                leadingIcon: 'notifications'),
                            PreferenceItemWidget(
                                title: 'Auto-sync',
                                subtitle: 'Automatically sync notes',
                                leadingIcon: 'sync'),
                          ]),

                      SizedBox(height: 2.h),

                      // AI Preferences
                      SettingsSectionWidget(title: 'AI Features', children: [
                        PreferenceItemWidget(
                            title: 'Smart Summaries',
                            subtitle: 'Generate weekly summaries',
                            leadingIcon: 'summarize'),
                        PreferenceItemWidget(
                            title: 'Auto-categorize',
                            subtitle: 'Automatically categorize notes',
                            leadingIcon: 'category'),
                        PreferenceItemWidget(
                            title: 'Study Questions',
                            subtitle: 'Generate study questions',
                            leadingIcon: 'quiz'),
                      ]),

                      SizedBox(height: 2.h),

                      // Account Settings
                      SettingsSectionWidget(title: 'Account', children: [
                        ListTile(
                            leading: CustomIconWidget(
                                iconName: 'help',
                                color:
                                    AppTheme.lightTheme.colorScheme.onSurface,
                                size: 6.w),
                            title: Text('Help & Support',
                                style: AppTheme.lightTheme.textTheme.bodyLarge),
                            trailing: CustomIconWidget(
                                iconName: 'chevron_right',
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                                size: 5.w),
                            onTap: _handleHelp),
                        ListTile(
                            leading: CustomIconWidget(
                                iconName: 'privacy_tip',
                                color:
                                    AppTheme.lightTheme.colorScheme.onSurface,
                                size: 6.w),
                            title: Text('Privacy Policy',
                                style: AppTheme.lightTheme.textTheme.bodyLarge),
                            trailing: CustomIconWidget(
                                iconName: 'chevron_right',
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                                size: 5.w),
                            onTap: _handlePrivacyPolicy),
                        ListTile(
                            leading: CustomIconWidget(
                                iconName: 'logout',
                                color: AppTheme.lightTheme.colorScheme.error,
                                size: 6.w),
                            title: Text('Sign Out',
                                style: AppTheme.lightTheme.textTheme.bodyLarge
                                    ?.copyWith(
                                        color: AppTheme
                                            .lightTheme.colorScheme.error)),
                            onTap: _handleSignOut),
                      ]),

                      SizedBox(height: 4.h),

                      // App Version
                      Text('Version 1.0.0',
                          style: AppTheme.lightTheme.textTheme.bodySmall
                              ?.copyWith(
                                  color: AppTheme.lightTheme.colorScheme
                                      .onSurfaceVariant)),

                      SizedBox(height: 2.h),
                    ]))));
  }

  void _handleEditProfile() {
    // Navigate to edit profile screen
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Edit profile coming soon!'),
        backgroundColor: AppTheme.lightTheme.primaryColor));
  }

  void _handleUpgrade() {
    // Navigate to subscription screen
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Upgrade features coming soon!'),
        backgroundColor: AppTheme.lightTheme.primaryColor));
  }

  void _handleHelp() {
    // Navigate to help screen
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Help & Support coming soon!'),
        backgroundColor: AppTheme.lightTheme.primaryColor));
  }

  void _handlePrivacyPolicy() {
    // Navigate to privacy policy screen
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Privacy policy coming soon!'),
        backgroundColor: AppTheme.lightTheme.primaryColor));
  }

  void _handleSignOut() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: Text('Sign Out'),
                content: Text('Are you sure you want to sign out?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel')),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _signOut();
                      },
                      child: Text('Sign Out',
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