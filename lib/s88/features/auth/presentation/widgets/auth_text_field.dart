import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';

/// Custom text field for authentication screens
/// Supports different states: default, active, filled, error
/// Supports password mode with show/hide toggle
class AuthTextField extends StatefulWidget {
  final String label;
  final String? placeholder;
  final TextEditingController? controller;
  final bool isPassword;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;

  const AuthTextField({
    Key? key,
    required this.label,
    this.placeholder,
    this.controller,
    this.isPassword = false,
    this.errorText,
    this.onChanged,
    this.onEditingComplete,
    this.focusNode,
    this.keyboardType,
  }) : super(key: key);

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  bool get _hasContent =>
      widget.controller != null && widget.controller!.text.isNotEmpty;

  Color get _getBorderColor {
    if (widget.errorText != null) {
      return AppColors.red500; // #f63d68
    }
    if (_isFocused) {
      return AppColors.yellow300; // #fde272
    }
    return AppColorStyles.borderSecondary; // #252423
  }

  double get _getBorderWidth {
    if (widget.errorText != null || _isFocused) {
      return 2.0;
    }
    return 1.0;
  }

  Color get _getLabelColor {
    if (widget.errorText != null) {
      return AppColors.red500;
    }
    if (_isFocused) {
      return AppColors.yellow300;
    }
    if (_hasContent) {
      return AppColorStyles.contentSecondary; // #9c9b95
    }
    return Colors.transparent;
  }

  Color get _getTextColor {
    if (_hasContent || _isFocused) {
      return AppColorStyles.contentPrimary; // #fffef5
    }
    return AppColorStyles.contentTertiary; // #74736f
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColorStyles.backgroundSecondary, // #111010
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getBorderColor,
                width: _getBorderWidth,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      obscureText: widget.isPassword && _obscurePassword,
                      onChanged: (value) {
                        setState(() {});
                        widget.onChanged?.call(value);
                      },
                      onEditingComplete: widget.onEditingComplete,
                      keyboardType: widget.keyboardType,
                      style: AppTextStyles.paragraphMedium(
                        color: _getTextColor,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: (_hasContent || _isFocused)
                            ? null
                            : (widget.placeholder ?? widget.label),
                        hintStyle: AppTextStyles.paragraphMedium(
                          color: AppColorStyles.contentTertiary,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget.isPassword && _hasContent)
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: _obscurePassword
                            ? Icon(
                                Icons.visibility_off,
                                size: 20,
                                color: AppColorStyles.contentSecondary,
                              )
                            : Icon(
                                Icons.visibility,
                                size: 20,
                                color: AppColorStyles.contentSecondary,
                              ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Floating label
          if (_hasContent || _isFocused)
            Positioned(
              left: 12,
              top: -8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                color: AppColorStyles.backgroundSecondary,
                child: Text(
                  widget.label,
                  style: AppTextStyles.labelXSmall(color: _getLabelColor),
                ),
              ),
            ),
        ],
      ),
      // Error message
      if (widget.errorText != null)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            widget.errorText!,
            style: AppTextStyles.paragraphMedium(color: AppColors.red500),
          ),
        ),
    ],
  );
}
