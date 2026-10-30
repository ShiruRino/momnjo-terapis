import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

enum FeedbackBannerType {
  info,
  success,
  warning,
  danger,
}

class FeedbackBanner extends StatelessWidget {
  final String message;
  final String? title;
  final FeedbackBannerType type;
  final VoidCallback? onDismiss;
  final Widget? trailing;
  final EdgeInsetsGeometry margin;

  const FeedbackBanner({
    super.key,
    required this.message,
    this.title,
    this.type = FeedbackBannerType.info,
    this.onDismiss,
    this.trailing,
    this.margin = const EdgeInsets.only(bottom: 12),
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color iconColor;
    IconData iconData;

    switch (type) {
      case FeedbackBannerType.success:
        bg = AppColors.feedbackSuccessBg;
        border = const Color(0xFFC3E8D8);
        iconColor = AppColors.feedbackSuccess;
        iconData = Icons.check_circle_outline;
        break;
      case FeedbackBannerType.warning:
        bg = AppColors.feedbackWarningBg;
        border = const Color(0xFFFFDEC0);
        iconColor = AppColors.feedbackWarning;
        iconData = Icons.error_outline;
        break;
      case FeedbackBannerType.danger:
        bg = AppColors.feedbackDangerBg;
        border = const Color(0xFFF9C8CE);
        iconColor = AppColors.feedbackDanger;
        iconData = Icons.cancel_outlined;
        break;
      case FeedbackBannerType.info:
        bg = AppColors.feedbackInfoBg;
        border = const Color(0xFFC7D7F0);
        iconColor = AppColors.feedbackInfo;
        iconData = Icons.info_outline;
        break;
    }

    return Container(
      margin: margin,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconData, size: 20, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null && title!.isNotEmpty) ...[
                  Text(
                    title!,
                    style: AppTypography.supportBold.copyWith(color: AppColors.inkStrong),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  message,
                  style: AppTypography.support.copyWith(
                    color: AppColors.inkStrong,
                    height: 1.35,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ] else if (onDismiss != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onDismiss,
              child: const Icon(Icons.close, size: 18, color: AppColors.inkMuted),
            ),
          ],
        ],
      ),
    );
  }
}

