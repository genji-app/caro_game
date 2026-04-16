import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/auth_validator.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/log_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/services/adapters/sport_socket_adapter_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/auth_provider.dart'
    as global_auth;
import 'package:co_caro_flame/s88/features/auth/domain/providers/auth_providers.dart';
import 'package:co_caro_flame/s88/features/auth/domain/state/auth_state.dart';
import 'package:co_caro_flame/s88/features/auth/presentation/desktop/widgets/otp_dialog.dart';
import 'package:co_caro_flame/s88/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/shared/responsive/responsive_builder.dart';
import 'package:co_caro_flame/s88/shared/widgets/buttons/shine_button.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';

/// Register form widget for desktop/tablet
class AuthDesktopRegisterForm extends ConsumerStatefulWidget {
  const AuthDesktopRegisterForm({required this.onSwitchToLogin, super.key});

  final VoidCallback onSwitchToLogin;

  @override
  ConsumerState<AuthDesktopRegisterForm> createState() =>
      _AuthDesktopRegisterFormState();
}

class _AuthDesktopRegisterFormState
    extends ConsumerState<AuthDesktopRegisterForm> {
  late final TextEditingController _usernameController;
  late final TextEditingController _displayNameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _displayNameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _displayNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes - this is efficient, doesn't cause rebuilds
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      next.maybeWhen(
        authenticated: (auth) {
          // Sync global auth state for header to update
          ref.read(global_auth.authProvider.notifier).syncFromSbLogin();
          // Initialize sport socket after register (Main + Chat already connected)
          initializeSportSocketAfterLogin(ref);
          AppToast.showSuccess(context, message: 'Đăng ký thành công!');
          // Navigate back to previous screen
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/');
          }
        },
        otpRequired: (sessionId, message, username, password) {
          // Show OTP dialog
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (context) => OtpDialog(
              sessionId: sessionId,
              message: message,
              username: username,
              password: password,
            ),
          );
        },
        error: (message, showPopup) {
          LogHelper.error(message);
          // Show error toast
          AppToast.showError(context, message: message);
        },
        orElse: () {},
      );
    });

    void submitForm() async {
      final state = ref.read(registerFormNotifierProvider);
      final isValid =
          !state.isSubmitting &&
          AuthValidator.validateRegisterUsername(state.username) == null &&
          AuthValidator.validatePassword(state.password) == null &&
          AuthValidator.validateConfirmPassword(
                state.confirmPassword,
                state.password,
              ) ==
              null &&
          AuthValidator.validateDisplayName(state.displayName, state.username) ==
              null;
      if (!isValid) return;

      final registerFormNotifier = ref.read(
        registerFormNotifierProvider.notifier,
      );
      final authNotifier = ref.read(authNotifierProvider.notifier);

      registerFormNotifier.setSubmitting(true);
      await authNotifier.register(
        username: state.username,
        password: state.password,
        displayName: state.displayName,
      );
      registerFormNotifier.setSubmitting(false);
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter): submitForm,
      },
      child: Focus(
        autofocus: true,
        child: Column(
      children: [
        // Logo
        const Spacer(),
        ImageHelper.load(
          path: AppImages.logoS88Home,
          width: 150,
          height: 150,
          fit: BoxFit.contain,
        ),
        const Gap(28),
        // Register form container
        Container(
          width: 448,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          decoration: BoxDecoration(
            color: AppColorStyles.backgroundSecondary,
            gradient: RadialGradient(
              center: Alignment(
                0.0,
                ResponsiveBuilder.isMobile(context) ? -5.9 : -6.4,
              ),
              radius: 2.9,
              tileMode: TileMode.clamp,
              colors: [
                const Color.fromARGB(170, 249, 219, 175),
                AppColorStyles.backgroundSecondary,
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, -0.65),
                blurRadius: 0.3,
                spreadRadius: 0.4,
                blurStyle: BlurStyle.inner,
                color: Colors.white.withOpacity(0.15),
              ),
            ],
          ),
          child: Column(
            children: [
              // Title
              Text(
                'Đăng ký tài khoản',
                style: AppTextStyles.headingSmall(color: AppColors.yellow50),
              ),
              const Gap(48),
              // Form fields
              Column(
                children: [
                  // Username field - only rebuilds when username changes
                  Consumer(
                    builder: (context, ref, _) {
                      final username = ref.watch(
                        registerFormNotifierProvider.select((s) => s.username),
                      );
                      return AuthTextField(
                        label: 'Tài khoản',
                        controller: _usernameController,
                        errorText:
                            AuthValidator.validateRegisterUsernameRealtime(
                              username,
                            ),
                        onChanged: (value) {
                          ref
                              .read(registerFormNotifierProvider.notifier)
                              .updateUsername(value);
                        },
                        onEditingComplete: () {
                          ref
                              .read(registerFormNotifierProvider.notifier)
                              .checkUsernameAvailability();
                        },
                      );
                    },
                  ),
                  const Gap(16),
                  // Password field - only rebuilds when password changes
                  Consumer(
                    builder: (context, ref, _) {
                      final password = ref.watch(
                        registerFormNotifierProvider.select((s) => s.password),
                      );
                      return AuthTextField(
                        label: 'Mật khẩu',
                        controller: _passwordController,
                        isPassword: true,
                        errorText: AuthValidator.validatePasswordRealtime(
                          password,
                        ),
                        onChanged: (value) {
                          ref
                              .read(registerFormNotifierProvider.notifier)
                              .updatePassword(value);
                        },
                      );
                    },
                  ),
                  const Gap(16),
                  // Confirm password field - rebuilds when confirmPassword or password changes
                  Consumer(
                    builder: (context, ref, _) {
                      final confirmPassword = ref.watch(
                        registerFormNotifierProvider.select(
                          (s) => s.confirmPassword,
                        ),
                      );
                      final password = ref.watch(
                        registerFormNotifierProvider.select((s) => s.password),
                      );
                      return AuthTextField(
                        label: 'Xác nhận mật khẩu',
                        controller: _confirmPasswordController,
                        isPassword: true,
                        errorText:
                            AuthValidator.validateConfirmPasswordRealtime(
                              confirmPassword,
                              password,
                            ),
                        onChanged: (value) {
                          ref
                              .read(registerFormNotifierProvider.notifier)
                              .updateConfirmPassword(value);
                        },
                      );
                    },
                  ),
                  const Gap(16),
                  // Display name field - rebuilds when displayName or username changes
                  Consumer(
                    builder: (context, ref, _) {
                      final displayName = ref.watch(
                        registerFormNotifierProvider.select(
                          (s) => s.displayName,
                        ),
                      );
                      final username = ref.watch(
                        registerFormNotifierProvider.select((s) => s.username),
                      );
                      return AuthTextField(
                        label: 'Tên hiển thị',
                        controller: _displayNameController,
                        errorText: AuthValidator.validateDisplayNameRealtime(
                          displayName,
                          username,
                        ),
                        onChanged: (value) {
                          ref
                              .read(registerFormNotifierProvider.notifier)
                              .updateDisplayName(value);
                        },
                      );
                    },
                  ),
                ],
              ),
              const Gap(16),
              // Submit button - only rebuilds when validation state changes
              _SubmitButton(onSwitchToLogin: widget.onSwitchToLogin),
              const Gap(12),
            ],
          ),
        ),

        // Spacer to push login link to bottom
        const Spacer(),

        // Login link - at the bottom (static, no Consumer needed)
        Container(
          margin: const EdgeInsets.only(bottom: 8, top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Đã có tài khoản?',
                style: AppTextStyles.paragraphSmall(
                  color: AppColorStyles.contentSecondary,
                ),
              ),
              const Gap(16),
              SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: widget.onSwitchToLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gray700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(1000),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    'Đăng nhập ngay',
                    style: AppTextStyles.buttonSmall(
                      color: AppColors.yellow200,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    )),
    );
  }
}

/// Separate widget for submit button to isolate rebuilds
class _SubmitButton extends ConsumerWidget {
  const _SubmitButton({required this.onSwitchToLogin});

  final VoidCallback onSwitchToLogin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use select to only rebuild when these specific values change
    final isSubmitting = ref.watch(
      registerFormNotifierProvider.select((s) => s.isSubmitting),
    );
    final username = ref.watch(
      registerFormNotifierProvider.select((s) => s.username),
    );
    final password = ref.watch(
      registerFormNotifierProvider.select((s) => s.password),
    );
    final confirmPassword = ref.watch(
      registerFormNotifierProvider.select((s) => s.confirmPassword),
    );
    final displayName = ref.watch(
      registerFormNotifierProvider.select((s) => s.displayName),
    );

    // Validation checks
    final isUsernameValid =
        AuthValidator.validateRegisterUsername(username) == null;
    final isPasswordValid = AuthValidator.validatePassword(password) == null;
    final isConfirmPasswordValid =
        AuthValidator.validateConfirmPassword(confirmPassword, password) ==
        null;
    final isDisplayNameValid =
        AuthValidator.validateDisplayName(displayName, username) == null;
    final canSubmit =
        !isSubmitting &&
        isUsernameValid &&
        isPasswordValid &&
        isConfirmPasswordValid &&
        isDisplayNameValid;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Opacity(
        opacity: canSubmit ? 1 : 0.5,
        child: ShineButton(
          text: isSubmitting ? '' : 'Tiếp tục',
          height: 48,
          width: double.infinity,
          style: ShineButtonStyle.primaryYellow,
          onPressed: canSubmit
              ? () async {
                  // Validate and show toast if error
                  final usernameError = AuthValidator.validateRegisterUsername(
                    username,
                  );
                  if (usernameError != null) {
                    AppToast.showError(context, message: usernameError);
                    return;
                  }

                  final passwordError = AuthValidator.validatePassword(
                    password,
                  );
                  if (passwordError != null) {
                    AppToast.showError(context, message: passwordError);
                    return;
                  }

                  final confirmPasswordError =
                      AuthValidator.validateConfirmPassword(
                        confirmPassword,
                        password,
                      );
                  if (confirmPasswordError != null) {
                    AppToast.showError(context, message: confirmPasswordError);
                    return;
                  }

                  final displayNameError = AuthValidator.validateDisplayName(
                    displayName,
                    username,
                  );
                  if (displayNameError != null) {
                    AppToast.showError(context, message: displayNameError);
                    return;
                  }

                  final registerFormNotifier = ref.read(
                    registerFormNotifierProvider.notifier,
                  );
                  final authNotifier = ref.read(authNotifierProvider.notifier);

                  registerFormNotifier.setSubmitting(true);
                  await authNotifier.register(
                    username: username,
                    password: password,
                    displayName: displayName,
                  );
                  registerFormNotifier.setSubmitting(false);
                }
              : null,
          trailingIcon: isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
