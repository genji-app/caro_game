import 'package:flutter/widgets.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/shared/widgets/input/input.dart';

/// Pure presentational search bar component for games
///
/// This component doesn't know about any business logic or providers.
/// It simply renders a search input and delegates changes to the parent.
class GameFilterInput extends StatelessWidget {
  const GameFilterInput({super.key, this.onChanged});

  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return StyledTextField(
      filled: true,
      fillColor: AppColorStyles.backgroundTertiary,
      hoverColor: AppColorStyles.backgroundTertiary,
      borderRadius: BorderRadius.circular(10),
      // borderRadius: BorderRadius.circular(8),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      prefixIcon: SizedBox.square(
        dimension: 24,
        child: ImageHelper.getSVG(path: AppIcons.icSearch),
      ),
      hintText: I18n.txtSearchGame,
      onChanged: onChanged,
    );
  }
}
