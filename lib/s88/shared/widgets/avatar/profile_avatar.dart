import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/providers/user_provider/user_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';

class ProfileAvatar extends ConsumerWidget {
  /// Default constructor primarily for a custom child (e.g. Identity icon, initials)
  const ProfileAvatar({
    this.child,
    this.size,
    this.borderRadius = const BorderRadius.all(Radius.circular(100)),
    this.fallback,
    this.onPressed,
    super.key,
  }) : url = null,
       _useProvider = false;

  /// Constructor for URL-based avatar
  const ProfileAvatar.url(
    this.url, {
    this.size,
    this.borderRadius = const BorderRadius.all(Radius.circular(100)),
    this.fallback,
    this.onPressed,
    super.key,
  }) : child = null,
       _useProvider = false;

  /// Constructor that automatically uses the current user's avatar from provider
  const ProfileAvatar.user({
    this.size,
    this.borderRadius = const BorderRadius.all(Radius.circular(100)),
    this.fallback,
    this.onPressed,
    super.key,
  }) : url = null,
       child = null,
       _useProvider = true;

  final BorderRadiusGeometry? borderRadius;
  final Size? size;
  final Widget? child;
  final Widget? fallback;
  final String? url;
  final VoidCallback? onPressed;
  final bool _useProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveUrl = _useProvider
        ? ref.watch(userInfoProvider)?.avatarUrl
        : url;

    final urlEmpty = effectiveUrl?.isEmpty ?? true;

    final Widget defaultFallback = _useProvider
        ? ImageHelper.getNetworkImage(
            imageUrl: AppImages.avatar,
            fit: BoxFit.cover,
          )
        : const SizedBox.shrink();

    final avatarWidget = urlEmpty
        ? (fallback ?? defaultFallback)
        : ImageHelper.getNetworkImage(
            imageUrl: effectiveUrl!,
            fit: BoxFit.cover,
          );

    final avatar = SizedBox.fromSize(
      size: size,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.1),
          border: Border.all(
            color: const Color(0x1FFFFCDB), // rgba(255,252,219,0.12)
            width: 1.25,
          ),
          borderRadius: borderRadius,
        ),
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.zero,
          child: child ?? avatarWidget,
        ),
      ),
    );

    if (onPressed != null) {
      return InkWell(
        onTap: onPressed,
        borderRadius: borderRadius is BorderRadius
            ? borderRadius as BorderRadius
            : null,
        child: avatar,
      );
    }

    return avatar;
  }
}
