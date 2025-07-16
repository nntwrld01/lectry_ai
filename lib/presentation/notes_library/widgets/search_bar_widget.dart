import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final List<String> recentSearches;

  const SearchBarWidget({
    Key? key,
    required this.controller,
    required this.onChanged,
    required this.recentSearches,
  }) : super(key: key);

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  bool _isExpanded = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isExpanded = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        children: [
          // Search Input Field
          Container(
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowLight,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'search',
                    color: AppTheme.textSecondaryLight,
                    size: 20,
                  ),
                ),
                suffixIcon: widget.controller.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          widget.controller.clear();
                          widget.onChanged('');
                        },
                        icon: CustomIconWidget(
                          iconName: 'clear',
                          color: AppTheme.textSecondaryLight,
                          size: 20,
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.all(3.w),
                        child: CustomIconWidget(
                          iconName: 'mic',
                          color: AppTheme.textSecondaryLight,
                          size: 20,
                        ),
                      ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 2.h,
                ),
                hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
              ),
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ),

          // Recent Searches (when expanded)
          if (_isExpanded && widget.recentSearches.isNotEmpty) ...[
            SizedBox(height: 1.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowLight,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Searches',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Clear recent searches
                        },
                        child: Text(
                          'Clear All',
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  ...widget.recentSearches
                      .map((search) => _buildRecentSearchItem(search)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecentSearchItem(String search) {
    return GestureDetector(
      onTap: () {
        widget.controller.text = search;
        widget.onChanged(search);
        _focusNode.unfocus();
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: 'history',
              color: AppTheme.textSecondaryLight,
              size: 16,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                search,
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
            ),
            GestureDetector(
              onTap: () {
                // Remove this search from recent searches
              },
              child: CustomIconWidget(
                iconName: 'close',
                color: AppTheme.textSecondaryLight,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
