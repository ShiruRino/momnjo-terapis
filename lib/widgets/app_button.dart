import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

enum AppButtonVariant {
  primary,
  secondary,
  danger,
  tertiary,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? icon;
  final double height;
  final double borderRadius;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.height = 48.0,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == AppButtonVariant.secondary || variant == AppButtonVariant.tertiary
                    ? AppColors.brand500
                    : Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Memproses...',
              style: _getTextStyle(isDisabled),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ] else ...[
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              text,
              style: _getTextStyle(isDisabled),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ],
    );

    Decoration decoration;
    if (isDisabled && !isLoading) {
      decoration = BoxDecoration(
        color: const Color(0xFFE5E8EF),
        borderRadius: BorderRadius.circular(borderRadius),
      );
    } else {
      switch (variant) {
        case AppButtonVariant.primary:
          decoration = BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: const [
              BoxShadow(
                color: Color(0x28AD3B64),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          );
          break;
        case AppButtonVariant.secondary:
          decoration = BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: AppColors.brand500, width: 1.5),
          );
          break;
        case AppButtonVariant.danger:
          decoration = BoxDecoration(
            color: AppColors.feedbackDanger,
            borderRadius: BorderRadius.circular(borderRadius),
          );
          break;
        case AppButtonVariant.tertiary:
          decoration = BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadius),
          );
          break;
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          decoration: decoration,
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.center,
            child: content,
          ),
        ),
      ),
    );
  }

  TextStyle _getTextStyle(bool isDisabled) {
    if (isDisabled && !isLoading) {
      return AppTypography.supportBold.copyWith(color: AppColors.inkLight);
    }
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.danger:
        return AppTypography.supportBold.copyWith(color: Colors.white);
      case AppButtonVariant.secondary:
      case AppButtonVariant.tertiary:
        return AppTypography.supportBold.copyWith(color: AppColors.brand500);
    }
  }
}
