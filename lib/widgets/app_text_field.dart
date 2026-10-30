import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final String? initialValue;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? errorMessage;
  final String? helperText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isReadOnly;
  final int maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final String? suffixUnit;

  const AppTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.initialValue,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.errorMessage,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.isReadOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.suffixUnit,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorMessage != null && widget.errorMessage!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label.isNotEmpty) ...[
          Text(
            widget.label,
            style: AppTypography.supportMedium.copyWith(
              color: AppColors.inkStrong,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: widget.controller,
          initialValue: widget.controller == null ? widget.initialValue : null,
          obscureText: widget.isPassword ? _obscureText : false,
          keyboardType: widget.keyboardType,
          readOnly: widget.isReadOnly,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          onChanged: widget.onChanged,
          style: AppTypography.body.copyWith(
            color: widget.isReadOnly ? AppColors.inkMuted : AppColors.inkStrong,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            filled: true,
            fillColor: widget.isReadOnly ? const Color(0xFFF8F9FB) : Colors.white,
            counterText: '', // Hide default counter if custom layout used
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.inkMuted,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : widget.suffixUnit != null
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.centerRight,
                        child: Text(
                          widget.suffixUnit!,
                          style: AppTypography.supportMedium.copyWith(color: AppColors.inkMuted),
                        ),
                      )
                    : (hasError
                        ? const Icon(
                            Icons.error_outline,
                            color: AppColors.feedbackDanger,
                            size: 20,
                          )
                        : widget.suffixIcon),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: widget.maxLines > 1 ? 14 : 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? AppColors.feedbackDanger : AppColors.surfaceBorder,
                width: hasError ? 1.5 : 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? AppColors.feedbackDanger : AppColors.surfaceBorder,
                width: hasError ? 1.5 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? AppColors.feedbackDanger : AppColors.brand500,
                width: 1.5,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.info_outline, size: 14, color: AppColors.feedbackDanger),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.errorMessage!,
                  style: AppTypography.caption.copyWith(color: AppColors.feedbackDanger),
                ),
              ),
            ],
          ),
        ] else if (widget.helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.helperText!,
            style: AppTypography.caption.copyWith(color: AppColors.inkMuted),
          ),
        ],
        if (widget.maxLength != null && widget.maxLines > 1) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${widget.controller?.text.length ?? 0}/${widget.maxLength}',
              style: AppTypography.caption.copyWith(color: AppColors.inkLight),
            ),
          ),
        ],
      ],
    );
  }
}

