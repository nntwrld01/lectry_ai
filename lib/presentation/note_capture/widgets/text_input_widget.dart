import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TextInputWidget extends StatefulWidget {
  final Function(String) onContentChanged;
  final String initialContent;

  const TextInputWidget({
    Key? key,
    required this.onContentChanged,
    this.initialContent = '',
  }) : super(key: key);

  @override
  State<TextInputWidget> createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<TextInputWidget> {
  late TextEditingController _textController;
  late FocusNode _focusNode;
  bool _isBold = false;
  bool _isItalic = false;
  bool _isBulletList = false;
  int _characterCount = 0;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialContent);
    _focusNode = FocusNode();
    _characterCount = widget.initialContent.length;

    _textController.addListener(() {
      setState(() {
        _characterCount = _textController.text.length;
      });
      widget.onContentChanged(_textController.text);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleBold() {
    setState(() {
      _isBold = !_isBold;
    });
    HapticFeedback.lightImpact();
  }

  void _toggleItalic() {
    setState(() {
      _isItalic = !_isItalic;
    });
    HapticFeedback.lightImpact();
  }

  void _toggleBulletList() {
    setState(() {
      _isBulletList = !_isBulletList;
    });
    HapticFeedback.lightImpact();

    if (_isBulletList) {
      final currentText = _textController.text;
      final selection = _textController.selection;
      final newText = currentText.substring(0, selection.start) +
          '• ' +
          currentText.substring(selection.start);
      _textController.text = newText;
      _textController.selection = TextSelection.collapsed(
        offset: selection.start + 2,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          // Formatting Toolbar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                _buildFormatButton(
                  icon: 'format_bold',
                  isActive: _isBold,
                  onTap: _toggleBold,
                  tooltip: 'Bold',
                ),
                SizedBox(width: 3.w),
                _buildFormatButton(
                  icon: 'format_italic',
                  isActive: _isItalic,
                  onTap: _toggleItalic,
                  tooltip: 'Italic',
                ),
                SizedBox(width: 3.w),
                _buildFormatButton(
                  icon: 'format_list_bulleted',
                  isActive: _isBulletList,
                  onTap: _toggleBulletList,
                  tooltip: 'Bullet List',
                ),
                Spacer(),
                Text(
                  '\$_characterCount characters',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // Text Editor
          Expanded(
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                ),
              ),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
                  fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
                  height: 1.5,
                ),
                decoration: InputDecoration(
                  hintText: 'Start typing your note...',
                  hintStyle: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.6),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () {
                  HapticFeedback.lightImpact();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatButton({
    required String icon,
    required bool isActive,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isActive
                ? Border.all(
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.3),
                  )
                : null,
          ),
          child: CustomIconWidget(
            iconName: icon,
            color: isActive
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
      ),
    );
  }
}
