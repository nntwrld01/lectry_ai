import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final Map<String, dynamic>? userProfile;
  final VoidCallback onEditProfile;

  const ProfileHeaderWidget({
    super.key,
    required this.userProfile,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    final fullName = userProfile?['full_name'] ?? 'User';
    final email = userProfile?['email'] ?? 'user@example.com';
    final role = userProfile?['role'] ?? 'basic';
    final avatarUrl = userProfile?['avatar_url'];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Picture and Info
          Row(
            children: [
              // Profile Picture
              Container(
                width: 15.w,
                height: 15.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                  border: Border.all(
                    color:
                        AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: avatarUrl != null
                    ? ClipOval(
                        child: Image.network(
                          avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildDefaultAvatar(fullName),
                        ),
                      )
                    : _buildDefaultAvatar(fullName),
              ),
              SizedBox(width: 4.w),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      email,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: _getRoleColor(role).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getRoleDisplayName(role),
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: _getRoleColor(role),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Edit Button
              IconButton(
                onPressed: onEditProfile,
                icon: CustomIconWidget(
                  iconName: 'edit',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 5.w,
                ),
                style: IconButton.styleFrom(
                  backgroundColor:
                      AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                  padding: EdgeInsets.all(2.w),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                icon: 'note',
                label: 'Notes',
                value: '${userProfile?['notes_count'] ?? 0}',
                color: AppTheme.lightTheme.primaryColor,
              ),
              _buildStatItem(
                icon: 'summarize',
                label: 'Summaries',
                value: '${userProfile?['summaries_count'] ?? 0}',
                color: AppTheme.lightTheme.colorScheme.secondary,
              ),
              _buildStatItem(
                icon: 'category',
                label: 'Categories',
                value: '${userProfile?['categories_count'] ?? 0}',
                color: AppTheme.lightTheme.colorScheme.tertiary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(String fullName) {
    final initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';
    return Center(
      child: Text(
        initial,
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          color: AppTheme.lightTheme.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: icon,
            color: color,
            size: 5.w,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'premium':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'admin':
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'premium':
        return 'Premium';
      case 'admin':
        return 'Admin';
      default:
        return 'Basic';
    }
  }
}
