import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/providers/pending_toast_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/features/auth/domain/providers/auth_providers.dart';
import 'package:co_caro_flame/s88/features/auth/presentation/desktop/widgets/auth_desktop_login_form.dart';
import 'package:co_caro_flame/s88/features/auth/presentation/desktop/widgets/auth_desktop_register_form.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';

/// Auth screen for desktop/tablet platforms
class AuthDesktopScreen extends ConsumerStatefulWidget {
  const AuthDesktopScreen({super.key, this.showLogin = true});

  final bool showLogin;

  @override
  ConsumerState<AuthDesktopScreen> createState() => _AuthDesktopScreenState();
}

class _AuthDesktopScreenState extends ConsumerState<AuthDesktopScreen> {
  late bool _showLogin;

  @override
  void initState() {
    super.initState();
    _showLogin = widget.showLogin;
    // Check for pending toast after first frame (for native platforms)
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _showPendingToast();
    });
  }

  void _showPendingToast() {
    final pendingToast = ref.read(pendingToastProvider);
    if (pendingToast != null) {
      // Clear pending toast first to prevent showing again
      ref.read(pendingToastProvider.notifier).state = null;

      // Show the toast
      if (mounted) {
        if (pendingToast.isError) {
          AppToast.showError(
            context,
            message: pendingToast.message,
            title: pendingToast.title,
            duration: const Duration(seconds: 5),
          );
        } else {
          AppToast.showSuccess(
            context,
            message: pendingToast.message,
            title: pendingToast.title,
            duration: const Duration(seconds: 5),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            backgroundColor: AppColorStyles.backgroundPrimary, // #141414
            body: Stack(
              clipBehavior: Clip.none,
              children: [
                // Yellow oval shadow at top center
                if (constraints.maxHeight >= 828)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: ImageHelper.getNetworkImage(
                      imageUrl: AppImages.headerShadow,
                      fit: BoxFit.fill,
                    ),
                  ),

                Positioned.fill(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Container(
                        height: constraints.maxHeight,
                        padding: MediaQuery.viewPaddingOf(context),
                        // padding: MediaQuery.viewPaddingOf(context),
                        constraints: const BoxConstraints(
                          maxHeight: 828,
                          minHeight: 664,
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: _showLogin
                                    ? AuthDesktopLoginForm(
                                        key: const ValueKey('login'),
                                        onSwitchToRegister: () {
                                          ref
                                              .read(
                                                loginFormNotifierProvider
                                                    .notifier,
                                              )
                                              .reset();
                                          setState(() {
                                            _showLogin = false;
                                          });
                                        },
                                      )
                                    : AuthDesktopRegisterForm(
                                        key: const ValueKey('register'),
                                        onSwitchToLogin: () {
                                          ref
                                              .read(
                                                registerFormNotifierProvider
                                                    .notifier,
                                              )
                                              .reset();
                                          setState(() {
                                            _showLogin = true;
                                          });
                                        },
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
