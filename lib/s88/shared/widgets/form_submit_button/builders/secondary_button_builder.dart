import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/shared/widgets/buttons/buttons.dart';
import 'package:co_caro_flame/s88/shared/widgets/form_control/form_control.dart';
import '../form_submit_button_data.dart';

/// Builder for Secondary button style.
class SecondaryButtonBuilder
    implements FormControlBuilder<FormSubmitButtonData> {
  const SecondaryButtonBuilder();

  @override
  Widget buildIdle(
    BuildContext context,
    FormSubmitButtonData data,
    FormControlController controller,
  ) {
    return SecondaryButton.yellow(
      style: SecondaryButton.styleFrom(minimumSize: data.size),
      onPressed: controller.submit,
      label: Text(data.text),
    );
  }

  @override
  Widget buildDisabled(
    BuildContext context,
    FormSubmitButtonData data,
    FormControlController controller,
  ) {
    return SecondaryButton.yellow(
      style: SecondaryButton.styleFrom(minimumSize: data.size),
      onPressed: null,
      label: Text(data.text),
    );
  }

  @override
  Widget buildProcessing(
    BuildContext context,
    FormSubmitButtonData data,
    FormControlController controller,
  ) {
    return SecondaryButton.yellow(
      style: SecondaryButton.styleFrom(minimumSize: data.size),
      onPressed: null,
      label: SizedBox.square(
        dimension: data.loadingIndicatorSize,
        child: CircularProgressIndicator(
          strokeWidth: data.loadingIndicatorStroke,
          valueColor: const AlwaysStoppedAnimation<Color>(
            AppColorStyles.contentSecondary,
          ),
        ),
      ),
    );
  }

  @override
  Widget buildSuccess(
    BuildContext context,
    FormSubmitButtonData data,
    FormControlController controller,
  ) {
    // return SecondaryButton.yellow(
    //   style: SecondaryButton.styleFrom(minimumSize: data.size),
    //   onPressed: controller.reset,
    //   label: Text(data.text),
    // );
    return ElevatedButton(
      onPressed: controller.reset,
      style: ElevatedButton.styleFrom(
        minimumSize: data.size,
        backgroundColor: const Color(0xFF4CAF50),
        disabledBackgroundColor: const Color(0xFF4CAF50),
        disabledForegroundColor: Colors.white,
        elevation: 0,
      ),
      child: const Icon(Icons.check, color: Colors.white),
    );
  }

  @override
  Widget buildError(
    BuildContext context,
    FormSubmitButtonData data,
    FormControlController controller,
  ) {
    return SecondaryButton.yellow(
      style: SecondaryButton.styleFrom(minimumSize: data.size),
      onPressed: controller.reset,
      label: Text(data.text),
    );
  }
}
