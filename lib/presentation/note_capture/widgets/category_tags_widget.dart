import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CategoryTagsWidget extends StatefulWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryTagsWidget({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  State<CategoryTagsWidget> createState() => _CategoryTagsWidgetState();
}

class _CategoryTagsWidgetState extends State<CategoryTagsWidget> {
  final TextEditingController _customTagController = TextEditingController();
  bool _showCustomTagInput = false;
  List<String> _customTags = [];

  @override
  void dispose() {
    _customTagController.dispose();
    super.dispose();
  }

  void _toggleCustomTagInput() {
    setState(() {
      _showCustomTagInput = !_showCustomTagInput;
    });
    HapticFeedback.lightImpact();
  }

  void _addCustomTag() {
    final tagName = _customTagController.text.trim();
    if (tagName.isNotEmpty && !_customTags.contains(tagName)) {
      setState(() {
        _customTags.add(tagName);
        _customTagController.clear();
        _showCustomTagInput = false;
      });
      widget.onCategorySelected(tagName);
      HapticFeedback.lightImpact();
    }
  }

  void _removeCustomTag(String tag) {
    setState(() {
      _customTags.remove(tag);
      if (widget.selectedCategory == tag) {
        widget.onCategorySelected(widget.categories.first);
      }
    });
    HapticFeedback.lightImpact();
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'study':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'personal':
        return AppTheme.lightTheme.colorScheme.secondary;
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return Icons.work;
      case 'study':
        return Icons.school;
      case 'personal':
        return Icons.person;
      default:
        return Icons.label;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allCategories = [...widget.categories, ..._customTags];

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categories',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: _toggleCustomTagInput,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'add',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Custom',
                        style:
                            AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Custom Tag Input
          if (_showCustomTagInput)
            Container(
              margin: EdgeInsets.only(bottom: 2.h),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customTagController,
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Enter custom tag name',
                        hintStyle:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme
                              .lightTheme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.6),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppTheme.lightTheme.colorScheme.outline,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppTheme.lightTheme.colorScheme.outline,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _addCustomTag(),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  GestureDetector(
                    onTap: _addCustomTag,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: 'check',
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Category Tags
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: allCategories.map((category) {
              final isSelected = category == widget.selectedCategory;
              final isCustom = _customTags.contains(category);
              final categoryColor = _getCategoryColor(category);

              return GestureDetector(
                onTap: () {
                  widget.onCategorySelected(category);
                  HapticFeedback.lightImpact();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? categoryColor
                        : categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? categoryColor
                          : categoryColor.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: _getIconName(_getCategoryIcon(category)),
                        color: isSelected ? Colors.white : categoryColor,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        category,
                        style:
                            AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                          color: isSelected ? Colors.white : categoryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (isCustom) ...[
                        SizedBox(width: 2.w),
                        GestureDetector(
                          onTap: () => _removeCustomTag(category),
                          child: CustomIconWidget(
                            iconName: 'close',
                            color: isSelected ? Colors.white : categoryColor,
                            size: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 1.h),
        ],
      ),
    );
  }

  String _getIconName(IconData iconData) {
    if (iconData == Icons.work) return 'work';
    if (iconData == Icons.school) return 'school';
    if (iconData == Icons.person) return 'person';
    if (iconData == Icons.label) return 'label';
    return 'label';
  }
}
