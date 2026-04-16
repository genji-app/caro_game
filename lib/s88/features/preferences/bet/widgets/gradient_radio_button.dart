import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';

class GradientRadioButton extends StatelessWidget {
  const GradientRadioButton({
    this.onChanged,
    this.child,
    this.selected = false,
    super.key,
  });

  final ValueChanged<bool>? onChanged;
  final Widget? child;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(100);
    const padding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    const unselectedButtonColor = AppColorStyles.backgroundTertiary;
    final iconTheme = IconTheme.of(context);

    Color surfaceColor = AppColorStyles.contentPrimary;
    Widget icon = const UnCheckedIcon();
    VoidCallback? onPressed = onChanged != null
        ? () => onChanged?.call(!selected)
        : null;

    if (selected) {
      surfaceColor = AppColors.yellow200;
      icon = const CheckedIcon();
      onPressed = null;
    }

    return SizedBox(
      height: 48,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: unselectedButtonColor,
          shape: RoundedRectangleBorder(
            // side: const BorderSide(width: 0.50, color: Color(0xFFFFD791)),
            // side: const BorderSide(width: 0.50, color: Color(0xFFFFD791)),
            borderRadius: borderRadius,
          ),
        ),
        // clipBehavior: Clip.hardEdge,
        // decoration: BoxDecoration(
        //   // border: Border,/
        //   // bor
        //   border: Border(bottom: BorderSide()),
        //   borderRadius: borderRadius,
        //   color: unselectedButtonColor,
        // ),
        child: Stack(
          children: [
            // Background
            // Container(
            //   decoration: BoxDecoration(
            //     borderRadius: borderRadius,
            //     color: buttonColor,
            //   ),
            //   child: const SizedBox.expand(),
            // ),
            if (selected)
              Positioned.fill(
                // bottom: 2,
                child: ImageHelper.load(
                  path: AppIcons.tabActive,
                  fit: BoxFit.fitWidth,
                ),
              ),
            // if (selected)
            //   const Positioned.fill(
            //     top: 25.49,
            //     // top: 20.49,
            //     child: GradientButtonBackground(),
            //     // child: GradientButtonBorderBottom(),
            //   ),
            // if (selected)
            //   const Positioned.fill(
            //     left: 32,
            //     right: 32,
            //     // top: 47,
            //     top: 43.49,
            //     child: GradientButtonBorderBottom(),
            //   ),

            // Content Surface
            Padding(
              padding: padding,
              child: IconTheme(
                data: iconTheme.copyWith(color: surfaceColor, size: 16),
                child: DefaultTextStyle(
                  style: AppTextStyles.buttonSmall(color: surfaceColor),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      icon,
                      DefaultTextStyle(
                        style: AppTextStyles.buttonSmall(color: surfaceColor),
                        child: Center(child: child),
                      ),
                      const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
            ),

            // Tapable
            SizedBox.expand(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // surfaceTintColor: AppColorStyles.borderSecondary,
                  backgroundColor: Colors.transparent,
                  foregroundColor: surfaceColor,
                  shape: RoundedRectangleBorder(borderRadius: borderRadius),
                ),
                // borderRadius: borderRadius,
                onPressed: onPressed,
                child: const SizedBox.expand(),
              ),
              // child: InkWell(
              //   borderRadius: borderRadius,
              //   onTap: onPressed,
              //   child: const SizedBox.expand(),
              // ),
            ),
          ],
        ),
      ),
    );
  }
}

class CheckedIcon extends StatelessWidget {
  const CheckedIcon({super.key});
  //  AppAssets.icons.checkboxBaseChecked.svg();
  //  Container(
  //         width: 20,
  //         height: 20,
  //         decoration: BoxDecoration(
  //           shape: BoxShape.circle,
  //           // Tạo hiệu ứng vòng tròn vàng với tâm tối bằng border
  //           border: Border.all(
  //             color: primaryColor,
  //             width: 5.0, // Độ dày viền tạo nên phần màu vàng
  //           ),
  //           color:
  //               gradientBottom, // Màu tâm hình tròn trùng với màu nền nút
  //         ),
  //       ),
  @override
  Widget build(BuildContext context) => Container(
    width: 16,
    height: 16,
    clipBehavior: Clip.antiAlias,
    decoration: ShapeDecoration(
      color: const Color(0xFFFAC414) /* Color-Yellow-400 */,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
    ),
    child: Stack(
      children: [
        Positioned(
          left: 5,
          top: 5,
          child: Container(
            width: 6,
            height: 6,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: const Color(0xFF1B1A19) /* Color-Gray-800 */,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class UnCheckedIcon extends StatelessWidget {
  const UnCheckedIcon({super.key});

  @override
  Widget build(BuildContext context) =>
      ImageHelper.load(path: AppIcons.checkboxBaseOutline);
}

// class GradientButtonBackground extends StatelessWidget {
//   const GradientButtonBackground({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Định nghĩa màu sắc dựa trên hình ảnh
//     const Color primaryColor = Color(0xFFEBC34F); // Màu vàng cho text và icon
//     const Color gradientTop = Color(
//       0xFF3D3D3D,
//     ); // Màu gradient phía trên (sáng hơn một chút)
//     const Color gradientBottom = Color(
//       0xFF2A2A2A,
//     ); // Màu gradient phía dưới (tối hơn)

//     return Container(
//       // width: 323.7,
//       // width: double.infinity,
//       // height: 16.51,
//       decoration: BoxDecoration(
//         boxShadow: <BoxShadow>[
//           BoxShadow(
//             color: Color(0x00000000),
//             offset: Offset(40.29999923706055, 40.29999923706055),
//             blurRadius: 40.29999923706055,
//           ),
//         ],
//         gradient: RadialGradient(
//           colors: [Color(0xFF231B0D00).withOpacity(0), Color(0xFFFFD791)],
//           // colors: [Color(0xFF231B0D00).withOpacity(0), Color(0xFFFFD791)],
//           // colors: [Color(90.11% 572.05%00),Color(rgb(25500),Color(21500),Color(145 0%00),Color(rgba(3500),Color(2700),Color(1300),Color(0) 100%)00)]
//         ),
//         borderRadius: BorderRadius.all(const Radius.circular(9999.0)),
//       ),
//     );

//     return Container(
//       // Padding để tạo khoảng cách bên trong nút
//       // padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
//       decoration: BoxDecoration(
//         // Tạo hình dạng viên thuốc (bo tròn mạnh các góc)
//         borderRadius: BorderRadius.circular(50.0),
//         // Tạo nền gradient chuyển màu từ trên xuống dưới
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [Color(0xFF231B0D00).withOpacity(0), Color(0xFFFFD791)],
//           // colors: [gradientTop, gradientBottom],
//         ),
//         // gradient: const LinearGradient(
//         //   begin: Alignment.topCenter,
//         //   end: Alignment.bottomCenter,
//         //   colors: [Color(0x00231B0C), Color(0xFFFFD791)],
//         //   // colors: [gradientTop, gradientBottom],
//         // ),
//         // Thêm bóng đổ nhẹ để nút trông nổi bật hơn (tùy chọn)
//         // boxShadow: [
//         //   BoxShadow(
//         //     color: Colors.black.withOpacity(0.2),
//         //     blurRadius: 6,
//         //     offset: const Offset(0, 3),
//         //   ),
//         // ],
//         boxShadow: const [
//           BoxShadow(
//             color: Color(0x00000000),
//             offset: Offset(40.29999923706055, 40.29999923706055),
//             blurRadius: 40.29999923706055,
//           ),
//         ],
//       ),
//       child: const SizedBox.expand(),
//     );
//   }
// }

// class GradientButtonBorderBottom extends StatelessWidget {
//   const GradientButtonBorderBottom({super.key});

//   @override
//   // ignore: prefer_expression_function_bodies
//   Widget build(BuildContext context) {
//     // Định nghĩa màu sắc dựa trên hình ảnh

//     final colors = [Color(0xF231B0D00).withOpacity(0), Color(0xFFFFD791)];

//     return Container(
//       // Padding để tạo khoảng cách bên trong nút
//       // padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
//       decoration: BoxDecoration(
//         // Tạo hình dạng viên thuốc (bo tròn mạnh các góc)
//         borderRadius: BorderRadius.circular(100.0),
//         // Tạo nền gradient chuyển màu từ trên xuống dưới
//         gradient: LinearGradient(
//           // gradient: RadialGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: colors,
//           // colors: [gradientTop, gradientBottom],
//         ),

//         // Thêm bóng đổ nhẹ để nút trông nổi bật hơn (tùy chọn)
//         // boxShadow: [
//         //   BoxShadow(
//         //     color: Colors.black.withOpacity(0.2),
//         //     blurRadius: 6,
//         //     offset: const Offset(0, 3),
//         //   ),
//         // ],
//         boxShadow: const [
//           BoxShadow(
//             color: Color(0x00000000),
//             offset: Offset(40.29999923706055, 40.29999923706055),
//             blurRadius: 40.29999923706055,
//           ),
//         ],
//       ),
//       child: const SizedBox.expand(),
//     );
//   }
// }

// class Button extends StatelessWidget {
//   const Button({super.key});

//   @override
//   Widget build(BuildContext context) => Container(
//     height: 48,
//     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//     clipBehavior: Clip.antiAlias,
//     decoration: ShapeDecoration(
//       color: const Color(0xFF1B1A19) /* Background-Tertiary */,
//       shape: RoundedRectangleBorder(
//         side: const BorderSide(width: 0.50, color: Color(0xFFFFD791)),
//         borderRadius: BorderRadius.circular(100),
//       ),
//     ),
//     // decoration: ShapeDecoration(
//     //   color: const Color(0xFF1B1A19) /* Background-Tertiary */,
//     //   shape: RoundedRectangleBorder(
//     //     side: const BorderSide(width: 0.50, color: Color(0xFFFFD791)),
//     //     borderRadius: BorderRadius.circular(100),
//     //   ),
//     // ),
//     child: Stack(
//       children: [
//         Positioned.fill(
//           left: 9.15,
//           top: 42,
//           // top: 43.49,
//           child: Container(
//             width: 323.70,
//             height: 16.51,
//             decoration: const ShapeDecoration(
//               gradient: RadialGradient(
//                 center: Alignment(0.50, 0.50),
//                 radius: 5.72,
//                 colors: [Color(0xFFFFD791), Color(0x00231B0C)],
//               ),
//               shape: OvalBorder(),
//             ),
//           ),
//         ),
//         // const CheckedIcon(),
//         const Center(
//           child: Text(
//             'Maylaysia',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: Color(0xFFFEEE94) /* Color-Yellow-200 */,
//               fontSize: 16,
//               fontFamily: 'Inter',
//               fontWeight: FontWeight.w500,
//               height: 1.50,
//             ),
//           ),
//         ),

//         // Opacity(
//         //   opacity: 0,
//         //   child: Container(
//         //     width: 16,
//         //     height: 16,
//         //     clipBehavior: Clip.antiAlias,
//         //     decoration: ShapeDecoration(
//         //       color: const Color(0xFFCA8403) /* Color-Yellow-600 */,
//         //       shape: RoundedRectangleBorder(
//         //         borderRadius: BorderRadius.circular(9999),
//         //       ),
//         //     ),
//         //     child: Stack(
//         //       children: [
//         //         Positioned(
//         //           left: 5,
//         //           top: 5,
//         //           child: Container(
//         //             width: 6,
//         //             height: 6,
//         //             clipBehavior: Clip.antiAlias,
//         //             decoration: ShapeDecoration(
//         //               color: Colors.white /* Colors-Foreground-fg-white */,
//         //               shape: RoundedRectangleBorder(
//         //                 borderRadius: BorderRadius.circular(9999),
//         //               ),
//         //             ),
//         //           ),
//         //         ),
//         //       ],
//         //     ),
//         //   ),
//         // ),
//       ],
//     ),
//   );
// }
