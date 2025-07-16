import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NoteCardWidget extends StatelessWidget {
  final Map<String, dynamic> note;
  final String categoryName;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const NoteCardWidget({
    super.key,
    required this.note,
    required this.categoryName,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.parse(note['created_at']);
    final timeAgo = _getTimeAgo(createdAt);
    final noteType = note['type'] ?? 'text';
    final hasAudio = note['has_audio'] ?? false;
    final tags = note['tags'] as List<dynamic>? ?? [];
    final categoryColor = note['categories']?['color'] ?? '#3B82F6';

    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Note Type Icon
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: _getTypeColor(noteType).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: _getTypeIcon(noteType),
                        color: _getTypeColor(noteType),
                        size: 4.w,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    // Title and Category
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note['title'] ?? 'Untitled Note',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.w, vertical: 0.5.h),
                                decoration: BoxDecoration(
                                  color: Color(int.parse(categoryColor
                                          .replaceFirst('#', '0xFF')))
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  categoryName,
                                  style: AppTheme
                                      .lightTheme.textTheme.labelSmall
                                      ?.copyWith(
                                    color: Color(int.parse(categoryColor
                                        .replaceFirst('#', '0xFF'))),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (hasAudio) ...[
                                SizedBox(width: 2.w),
                                CustomIconWidget(
                                  iconName: 'volume_up',
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  size: 3.w,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Actions Menu
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          onEdit();
                        } else if (value == 'delete') {
                          onDelete();
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'edit',
                                color:
                                    AppTheme.lightTheme.colorScheme.onSurface,
                                size: 4.w,
                              ),
                              SizedBox(width: 2.w),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'delete',
                                color: AppTheme.lightTheme.colorScheme.error,
                                size: 4.w,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Delete',
                                style: TextStyle(
                                  color: AppTheme.lightTheme.colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        child: CustomIconWidget(
                          iconName: 'more_vert',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 4.w,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                // Content Preview
                Text(
                  note['content'] ?? 'No content',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (tags.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  // Tags
                  Wrap(
                    spacing: 2.w,
                    runSpacing: 1.h,
                    children: tags.take(3).map((tag) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color:
                              AppTheme.lightTheme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag.toString(),
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                SizedBox(height: 2.h),
                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      timeAgo,
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (note['duration'] != null)
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'access_time',
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            size: 3.w,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            note['duration'],
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _getTypeIcon(String type) {
    switch (type) {
      case 'audio':
        return 'mic';
      case 'image':
        return 'image';
      case 'mixed':
        return 'layers';
      default:
        return 'description';
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'audio':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'image':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'mixed':
        return AppTheme.lightTheme.colorScheme.primary;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }
}
