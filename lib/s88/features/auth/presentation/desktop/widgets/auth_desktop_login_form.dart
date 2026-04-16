import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:co_caro_flame/s88/core/services/config/sb_config.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/auth_validator.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
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

/// Login form widget for desktop/tablet
class AuthDesktopLoginForm extends ConsumerStatefulWidget {
  final VoidCallback onSwitchToRegister;

  const AuthDesktopLoginForm({required this.onSwitchToRegister, super.key});

  @override
  ConsumerState<AuthDesktopLoginForm> createState() =>
      _AuthDesktopLoginFormState();
}

class _AuthDesktopLoginFormState extends ConsumerState<AuthDesktopLoginForm> {
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginFormState = ref.watch(loginFormNotifierProvider);
    final loginFormNotifier = ref.read(loginFormNotifierProvider.notifier);
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final isUsernameValid =
        AuthValidator.validateLoginUsername(loginFormState.username) == null;
    final isPasswordValid =
        AuthValidator.validatePassword(loginFormState.password) == null;
    final canSubmit =
        !loginFormState.isSubmitting && isUsernameValid && isPasswordValid;

    // Listen to auth state changes
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      next.maybeWhen(
        authenticated: (auth) {
          // Sync global auth state for header to update
          ref.read(global_auth.authProvider.notifier).syncFromSbLogin();
          // Initialize sport socket after login (Main + Chat already connected)
          initializeSportSocketAfterLogin(ref);
          AppToast.showSuccess(context, message: 'Đăng nhập thành công!');
          // Navigate only when GoRouter is in context (in-app auth flow).
          // When no GoRouter (startup: MaterialApp with home), do nothing so
          // App rebuilds and switches to MaterialApp.router.
          final goRouter = GoRouter.maybeOf(context);
          if (goRouter != null) {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
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
          // Show error toast
          AppToast.showError(context, message: message);
        },
        orElse: () {},
      );
    });

    void submitForm() async {
      if (canSubmit && loginFormNotifier.validate()) {
        loginFormNotifier.setSubmitting(true);
        await authNotifier.login(
          loginFormState.username,
          loginFormState.password,
        );
        loginFormNotifier.setSubmitting(false);
      }
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter): submitForm,
      },
      child: Focus(
        autofocus: true,
        child: Column(
      children: [
        const Spacer(),
        // Logo
        ImageHelper.load(
          path: AppImages.logoS88Home,
          width: 150,
          height: 150,
          fit: BoxFit.contain,
        ),
        const Gap(28),
        // Login form container
        Container(
          width: 448,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          decoration: BoxDecoration(
            color: AppColorStyles.backgroundSecondary,
            gradient: RadialGradient(
              center: Alignment(0.0, -6.4),
              radius: 2.9,
              tileMode: TileMode.clamp,
              colors: [
                const Color.fromARGB(170, 249, 219, 175),
                AppColorStyles.backgroundSecondary,
              ],
            ),
            // border: Border.all(color: const Color(0xFF393836), width: 1),
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
            // mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                'Đăng nhập',
                style: AppTextStyles.headingSmall(
                  color: AppColors.yellow50, // #fefbe8
                ),
              ),
              const Gap(48),
              // Form fields
              Column(
                children: [
                  AuthTextField(
                    label: 'Tài khoản',
                    controller: _usernameController,
                    errorText: loginFormState.usernameError,
                    onChanged: (value) {
                      loginFormNotifier.updateUsername(value);
                    },
                  ),
                  const Gap(16),
                  AuthTextField(
                    label: 'Mật khẩu',
                    controller: _passwordController,
                    isPassword: true,
                    errorText: loginFormState.passwordError,
                    onChanged: (value) {
                      loginFormNotifier.updatePassword(value);
                    },
                  ),
                  const Gap(8),
                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        launchUrl(
                          Uri.parse(
                            SbConfig.livechatUrl,
                          ),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Quên mật khẩu?',
                          style:
                              AppTextStyles.paragraphSmall(
                                color: AppColorStyles.contentSecondary,
                              ).copyWith(
                                decoration: TextDecoration.underline,
                                decorationColor:
                                    AppColorStyles.contentSecondary,
                              ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(48),
              // Submit button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: Opacity(
                  opacity: canSubmit ? 1 : 0.5,
                  child: ShineButton(
                    text: loginFormState.isSubmitting ? '' : 'Tiếp tục',
                    height: 48,
                    width: double.infinity,
                    style: ShineButtonStyle.primaryYellow,
                    onPressed: canSubmit
                        ? () async {
                            if (loginFormNotifier.validate()) {
                              loginFormNotifier.setSubmitting(true);
                              await authNotifier.login(
                                loginFormState.username,
                                loginFormState.password,
                              );
                              loginFormNotifier.setSubmitting(false);
                            }
                          }
                        : null,
                    trailingIcon: loginFormState.isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Spacer to push register link to bottom
        const Spacer(),
        // Register link - at the bottom
        Container(
          margin: const EdgeInsets.only(bottom: 8, top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Không có tài khoản?',
                style: AppTextStyles.paragraphSmall(
                  color: AppColorStyles.contentSecondary,
                ),
              ),
              const Gap(16),
              SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: widget.onSwitchToRegister,
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
                    'Đăng ký ngay',
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
