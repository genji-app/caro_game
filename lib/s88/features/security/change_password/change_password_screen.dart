import 'package:flutter/material.dart' hide CloseButton;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/features/security/security.dart';
import 'package:co_caro_flame/s88/shared/profile_navigation_system/profile_navigation_system.dart';
import 'package:co_caro_flame/s88/shared/widgets/buttons/buttons.dart';
import 'package:co_caro_flame/s88/shared/widgets/sb_bottom_navigation_bar.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  static MaterialPageRoute<void> route() =>
      MaterialPageRoute(builder: (context) => const ChangePasswordScreen());

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  late final TextEditingController _currentPassController;
  late final TextEditingController _newPassController;
  late final TextEditingController _confirmPassController;

  @override
  void initState() {
    super.initState();
    _currentPassController = TextEditingController();
    _newPassController = TextEditingController();
    _confirmPassController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(changePasswordProvider.notifier);

    // Handle Side Effects (Success/Error Messages)
    ref.listen<ChangePasswordState>(changePasswordProvider, (previous, next) {
      if (previous?.status == next.status) return;

      switch (next.status) {
        case ChangePasswordStatus.success:
          notifier.resetState();
          _currentPassController.clear();
          _newPassController.clear();
          _confirmPassController.clear();
          AppToast.showSuccess(context, message: 'Đổi mật khẩu thành công!');
          break;
        case ChangePasswordStatus.failure:
          if (next.errorMessage != null) {
            AppToast.showError(context, message: next.errorMessage!);
          }
          break;
        case ChangePasswordStatus.initial:
        case ChangePasswordStatus.loading:
        case ChangePasswordStatus.invalid:
          break;
      }
    });

    return ProfileNavigationScaffold.withCenterTitle(
      title: const Text(I18n.txtChangePassword),
      body: SingleChildScrollView(
        padding: ProfileNavigationScaffold.kBodyHorizontalPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 24,
          children: [
            // Current Password Field - only rebuilds when currentPasswordError changes
            _CurrentPasswordField(
              controller: _currentPassController,
              onChanged: notifier.setCurrentPassword,
            ),

            // New Password Field - only rebuilds when newPasswordError changes
            _NewPasswordField(
              controller: _newPassController,
              onChanged: notifier.setNewPassword,
            ),

            // Confirm Password Field - only rebuilds when confirmPasswordError changes
            _ConfirmPasswordField(
              controller: _confirmPassController,
              onChanged: notifier.setConfirmPassword,
            ),
            const Gap(36),
          ],
        ),
      ),
      bottomNavigationBar: const SBBottomNavigationBar.withDivider(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: ChangePasswordSubmitButton(),
        ),
      ),
    );
  }
}

// =============================================================================
// Private Widgets - Isolated rebuilds with select
// =============================================================================

class _CurrentPasswordField extends ConsumerWidget {
  const _CurrentPasswordField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errorText = ref.watch(
      changePasswordProvider.select((s) => s.currentPasswordError),
    );
    return PasswordInputField(
      label: const Text(I18n.txtCurrentPassword),
      errorText: errorText,
      controller: controller,
      onChanged: onChanged,
    );
  }
}

class _NewPasswordField extends ConsumerWidget {
  const _NewPasswordField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errorText = ref.watch(
      changePasswordProvider.select((s) => s.newPasswordError),
    );
    return PasswordInputField(
      label: const Text(I18n.txtNewPassword),
      errorText: errorText,
      controller: controller,
      onChanged: onChanged,
    );
  }
}

class _ConfirmPasswordField extends ConsumerWidget {
  const _ConfirmPasswordField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errorText = ref.watch(
      changePasswordProvider.select((s) => s.confirmPasswordError),
    );
    return PasswordInputField(
      label: const Text(I18n.txtReEnterNewPassword),
      errorText: errorText,
      controller: controller,
      onChanged: onChanged,
    );
  }
}

// =============================================================================
// Submit Button - Uses select to only rebuild when canSubmit/isLoading changes
// =============================================================================

class ChangePasswordSubmitButton extends ConsumerWidget {
  const ChangePasswordSubmitButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canSubmit = ref.watch(
      changePasswordProvider.select((s) => s.canSubmit),
    );
    final isLoading = ref.watch(
      changePasswordProvider.select((s) => s.isLoading),
    );
    final notifier = ref.read(changePasswordProvider.notifier);
    final labelTxt = isLoading ? '' : I18n.txtChangePassword;

    return Opacity(
      opacity: canSubmit ? 1 : 0.5,
      child: ShineButton(
        text: labelTxt,
        width: double.infinity,
        style: ShineButtonStyle.primaryYellow,
        size: ShineButtonSize.large,
        onPressed: canSubmit ? notifier.submit : null,
        trailingIcon: isLoading
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColorStyles.contentPrimary,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
