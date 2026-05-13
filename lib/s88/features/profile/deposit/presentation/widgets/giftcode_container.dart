import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/giftcode_deposit_request.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/providers/deposit_form_providers.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/providers/deposit_providers.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/state/deposit_state.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/shared/widgets/buttons/buttons.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';

/// Container for Giftcode payment method form
class GiftCodeContainer extends ConsumerStatefulWidget {
  const GiftCodeContainer({super.key});

  @override
  ConsumerState<GiftCodeContainer> createState() => _GiftCodeContainerState();
}

class _GiftCodeContainerState extends ConsumerState<GiftCodeContainer> {
  final TextEditingController _giftCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Listen to form changes to sync with provider
    _giftCodeController.addListener(() {
      ref
          .read(giftcodeFormProvider.notifier)
          .updateGiftcode(_giftCodeController.text);
    });
  }

  @override
  void dispose() {
    _giftCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(giftcodeFormProvider);
    final submitState = ref.watch(giftcodeSubmitNotifierProvider);

    // React to submit state changes (success / error toast)
    ref.listen<GiftcodeSubmitState>(giftcodeSubmitNotifierProvider, (
      previous,
      next,
    ) {
      next.maybeWhen(
        success: (message) {
          if (!mounted) return;
          AppToast.showSuccess(
            context,
            message: message ?? 'Sử dụng giftcode thành công',
          );
          // Reset form + submit state after success
          _giftCodeController.clear();
          ref.read(giftcodeFormProvider.notifier).reset();
          ref.read(giftcodeSubmitNotifierProvider.notifier).reset();
        },
        error: (message) {
          if (!mounted) return;
          // Empty message → silent (status == 500 in legacy flow)
          if (message.isNotEmpty) {
            AppToast.showError(context, message: message);
          }
          // Reset submit state so user can retry
          ref.read(giftcodeSubmitNotifierProvider.notifier).reset();
        },
        orElse: () {},
      );
    });

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildGiftCodeForm(formState),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          // Bottom button (fixed)
          _buildBottomButton(formState, submitState),
        ],
      ),
    );
  }

  /// Giftcode input form with validation error
  Widget _buildGiftCodeForm(GiftcodeFormState formState) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Label
      // Text(
      //   'Nhập Giftcode',
      //   style: AppTextStyles.labelMedium(
      //     color: AppColors.gray300, // #9c9b95
      //   ),
      // ),
      if (formState.giftCodeError != null) ...[
        const SizedBox(height: 4),
        Text(
          formState.giftCodeError!,
          style: AppTextStyles.labelSmall(color: Colors.red),
        ),
      ],
      // const SizedBox(height: 8),
      // Input field
      Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.gray900, // #111010
          border: Border.all(
            color: formState.giftCodeError != null
                ? Colors.red
                : AppColors.gray700, // #252423
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _giftCodeController,
          style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
          decoration: InputDecoration(
            hintText: 'Nhập Giftcode',
            hintStyle: AppTextStyles.paragraphMedium(
              color: AppColors.gray400, // #74736f
            ).copyWith(fontWeight: FontWeight.w400),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          keyboardType: TextInputType.text,
        ),
      ),
    ],
  );

  /// Submit button with enable/disable + loading states
  Widget _buildBottomButton(
    GiftcodeFormState formState,
    GiftcodeSubmitState submitState,
  ) {
    final isSubmitting = submitState.maybeWhen(
      submitting: () => true,
      orElse: () => false,
    );
    return DepositActionButton(
      text: isSubmitting ? 'Đang xử lý...' : 'Xác nhận',
      isEnabled: formState.isValid && !isSubmitting,
      onTap: () => _handleSubmit(formState),
    );
  }

  /// Handle submit button tap
  Future<void> _handleSubmit(GiftcodeFormState formState) async {
    // Validate form before submitting
    if (!ref.read(giftcodeFormProvider.notifier).validate()) {
      AppToast.showError(context, message: 'Vui lòng kiểm tra lại thông tin');
      return;
    }

    // Avoid double-submit
    final isSubmitting = ref
        .read(giftcodeSubmitNotifierProvider)
        .maybeWhen(submitting: () => true, orElse: () => false);
    if (isSubmitting) return;

    // Trigger API call via notifier
    await ref
        .read(giftcodeSubmitNotifierProvider.notifier)
        .submit(GiftcodeDepositRequest(giftCode: formState.giftCode));
  }
}
