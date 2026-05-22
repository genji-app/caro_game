import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/spacing_styles.dart';
import 'package:sun_sports/features/game/game.dart';
import 'package:sun_sports/shared/widgets/buttons/buttons.dart';

/// A view that maps [GamePlayerFailureState] to the appropriate
/// error message and actions.
class GamePlayerFailureView extends StatelessWidget {
  const GamePlayerFailureView({
    required this.failureState,
    required this.onClose,
    required this.onRetry,
    super.key,
  });

  final GamePlayerFailureState failureState;
  final VoidCallback onClose;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isRetryable = failureState.isRetryable;
    final failureMessage = failureState.failureMessage;

    return switch (failureState.failureType) {
      GamePlayerErrorType.maintenance => _FailureContent(
        message: const Text('Game đang bảo trì.'),
        secondaryMessage: const Text('Xin quay lại sau!'),
        onPrimaryAction: onClose,
        primaryActionText: I18n.txtBackToHome,
      ),
      GamePlayerErrorType.network => _FailureContent(
        icon: const _ErrorIcon(),
        message: const Text('Không có kết nối mạng'),
        secondaryMessage: Text(
          failureMessage ??
              (isRetryable
                  ? 'Kiểm tra kết nối và thử lại'
                  : 'Không thể kết nối sau nhiều lần thử. Kiểm tra lại mạng và vào lại.'),
        ),
        onPrimaryAction: isRetryable ? onRetry : onClose,
        primaryActionText: isRetryable ? I18n.txtRetry : I18n.txtGoBack,
      ),
      GamePlayerErrorType.serverError => _FailureContent(
        icon: const _ErrorIcon(),
        message: const Text('Lỗi máy chủ'),
        secondaryMessage: Text(
          failureMessage ??
              (isRetryable
                  ? 'Máy chủ gặp sự cố, vui lòng thử lại'
                  : 'Máy chủ không phản hồi sau nhiều lần thử. Vui lòng thử lại sau.'),
        ),
        onPrimaryAction: isRetryable ? onRetry : onClose,
        primaryActionText: isRetryable ? I18n.txtRetry : I18n.txtGoBack,
      ),
      GamePlayerErrorType.orientationSetupFailed => _FailureContent(
        icon: const _ErrorIcon(),
        message: const Text('Lỗi xoay màn hình'),
        secondaryMessage: const Text(
          'Không thể áp dụng hướng màn hình. Vui lòng quay lại và thử lại.',
        ),
        onPrimaryAction: onClose,
        primaryActionText: I18n.txtGoBack,
      ),
      GamePlayerErrorType.sessionExpired => _FailureContent(
        icon: const _ErrorIcon(),
        message: const Text('Phiên đăng nhập hết hạn'),
        secondaryMessage: const Text('Vui lòng đăng nhập lại để tiếp tục'),
        onPrimaryAction: onClose,
        primaryActionText: I18n.txtGoBack,
      ),
      GamePlayerErrorType.comingSoon => _FailureContent(
        icon: const _ErrorIcon(),
        message: const Text('Game sắp ra mắt'),
        secondaryMessage: const Text('Nội dung này chưa được phát hành'),
        onPrimaryAction: onClose,
        primaryActionText: I18n.txtGoBack,
      ),
      GamePlayerErrorType.unavailable => _FailureContent(
        icon: const _ErrorIcon(),
        message: const Text('Game không khả dụng'),
        secondaryMessage: const Text(
          'Game này hiện đang tạm dừng hoặc đang phát triển',
        ),
        onPrimaryAction: onClose,
        primaryActionText: I18n.txtGoBack,
      ),
      GamePlayerErrorType.loadTimeout => _FailureContent(
        icon: const _ErrorIcon(),
        message: const Text('Tải game quá lâu'),
        secondaryMessage: const Text(
          'Vui lòng kiểm tra kết nối mạng hoặc thử lại',
        ),
        onPrimaryAction: isRetryable ? onRetry : onClose,
        primaryActionText: isRetryable ? I18n.txtRetry : I18n.txtGoBack,
      ),
      GamePlayerErrorType.missingGameUrl => _FailureContent(
        icon: const _ErrorIcon(),
        message: const Text('Không tìm thấy game'),
        secondaryMessage: const Text('Không lấy được địa chỉ trò chơi'),
        onPrimaryAction: onClose,
        primaryActionText: I18n.txtGoBack,
      ),
      GamePlayerErrorType.unknown => _FailureContent(
        icon: const _ErrorIcon(),
        message: Text(failureMessage ?? I18n.msgSomethingWentWrong),
        onPrimaryAction: isRetryable ? onRetry : onClose,
        primaryActionText: isRetryable ? I18n.txtRetry : I18n.txtGoBack,
      ),
    };
  }
}

class _FailureContent extends StatelessWidget {
  const _FailureContent({
    required this.message,
    this.secondaryMessage,
    this.icon,
    this.onPrimaryAction,
    this.primaryActionText,
  });

  final Widget message;
  final Widget? secondaryMessage;
  final Widget? icon;
  final VoidCallback? onPrimaryAction;
  final String? primaryActionText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacingStyles.space400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, const Gap(AppSpacingStyles.space400)],
          DefaultTextStyle(
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.headingXSmall(
              color: AppColorStyles.contentPrimary,
            ),
            child: message,
          ),
          if (secondaryMessage != null) ...[
            const Gap(AppSpacingStyles.space200),
            DefaultTextStyle(
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.paragraphSmall(
                color: AppColorStyles.contentSecondary,
              ),
              child: secondaryMessage!,
            ),
          ],
          if (onPrimaryAction != null) ...[
            const Gap(AppSpacingStyles.space800),
            ShineButton(
              onPressed: onPrimaryAction,
              text: primaryActionText ?? I18n.txtRetry,
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorIcon extends StatelessWidget {
  const _ErrorIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.error_outline_rounded,
        color: Colors.redAccent,
        size: 32,
      ),
    );
  }
}
