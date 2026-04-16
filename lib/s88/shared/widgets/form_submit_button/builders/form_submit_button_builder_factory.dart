import 'package:co_caro_flame/s88/shared/widgets/form_control/form_control.dart';
import '../form_submit_button_data.dart';
import '../form_submit_button_style.dart';
import 'primary_yellow_button_builder.dart';
import 'secondary_button_builder.dart';

/// Factory for creating form submit button builders based on style.
class FormSubmitButtonBuilderFactory {
  // Cache builders to avoid recreation.
  static final Map<
    FormSubmitButtonStyle,
    FormControlBuilder<FormSubmitButtonData>
  >
  _builders = {
    FormSubmitButtonStyle.primaryYellow: const PrimaryYellowButtonBuilder(),
    FormSubmitButtonStyle.secondary: const SecondaryButtonBuilder(),
  };

  /// Returns the builder for the given style.
  ///
  /// O(1) lookup performance.
  static FormControlBuilder<FormSubmitButtonData> getBuilder(
    FormSubmitButtonStyle style,
  ) {
    return _builders[style]!;
  }
}
