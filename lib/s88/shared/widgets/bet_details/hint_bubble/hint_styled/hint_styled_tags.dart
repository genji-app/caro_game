import 'package:flutter/material.dart';
import 'package:styled_text/styled_text.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';

/// Styled text tag definitions for hint bubble content
///
/// Tag Categories:
/// - Structure: `<title>`, `<content>`, `<bullet>`, `<simple>`, `<example-title>`, `<result-title>`, `<bullet-point>`
/// - Entity: `<team>`, `<selection>`, `<selection-team>`, `<period>`
/// - Numeric: `<positive>`, `<negative>`, `<handicap>`, `<score>`, `<money>`, `<number>`
/// - Result: `<win>`, `<lose>`, `<draw>`, `<halfwin>`, `<halflose>`
/// - Case: `<case>`, `<condition>`
class HintStyledTags {
  HintStyledTags._();

  // ===========================================================================
  // Tag Name Constants
  // ===========================================================================

  // Structure tags
  static const String tagTitle = 'title';
  static const String tagContent = 'content';
  static const String tagBullet = 'bullet';
  static const String tagSimple = 'simple';
  static const String tagExampleTitle = 'example-title';
  static const String tagResultTitle = 'result-title';
  static const String tagBulletPoint = 'bullet-point';

  // Entity tags
  static const String tagTeam = 'team';
  static const String tagSelection = 'selection';
  static const String tagSelectionTeam = 'selection-team';
  static const String tagPeriod = 'period';

  // Numeric tags
  static const String tagPositive = 'positive';
  static const String tagNegative = 'negative';
  static const String tagHandicap = 'handicap';
  static const String tagScore = 'score';
  static const String tagMoney = 'money';
  static const String tagNumber = 'number';

  // Result tags
  static const String tagWin = 'win';
  static const String tagLose = 'lose';
  static const String tagDraw = 'draw';
  static const String tagHalfWin = 'halfwin';
  static const String tagHalfLose = 'halflose';

  // Case tags
  static const String tagCase = 'case';
  static const String tagCondition = 'condition';

  // ===========================================================================
  // Tag Map
  // ===========================================================================

  /// Get styled text tags for hint content
  static Map<String, StyledTextTag> get tags {
    final base = AppTextStyles.paragraphXSmall(
      color: AppColorStyles.contentPrimary,
    );

    return {
      // ========================================
      // Structure Tags
      // ========================================
      /// Main title tag - Green, bold
      'title': StyledTextTag(
        style: base.copyWith(
          color: AppColors.green300,
          fontWeight: FontWeight.w600,
        ),
      ),

      /// Content wrapper tag - Default style
      'content': StyledTextTag(style: base),

      /// Bullet content tag - Default style
      'bullet': StyledTextTag(style: base),

      /// Simple explanation tag - Green
      'simple': StyledTextTag(style: base.copyWith(color: AppColors.green300)),

      /// Example section title tag - Default style
      'example-title': StyledTextTag(style: base),

      /// Result section title tag - Default style
      'result-title': StyledTextTag(style: base),

      /// Bullet point character (•) tag - Default style
      'bullet-point': StyledTextTag(style: base),

      // ========================================
      // Entity Tags
      // ========================================
      /// Team name tag - Yellow
      'team': StyledTextTag(style: base.copyWith(color: AppColors.yellow300)),

      /// Selection name tag - Default style
      'selection': StyledTextTag(style: base),

      /// Selection team name in example tag - Yellow
      'selection-team': StyledTextTag(
        style: base.copyWith(color: AppColors.yellow300),
      ),

      /// Period/time tag - Green
      'period': StyledTextTag(style: base.copyWith(color: AppColors.green300)),

      // ========================================
      // Numeric Tags
      // ========================================
      /// Positive odds ratio tag - Green
      'positive': StyledTextTag(
        style: base.copyWith(color: AppColors.green300),
      ),

      /// Negative odds ratio tag - Red
      'negative': StyledTextTag(style: base.copyWith(color: AppColors.red300)),

      /// Handicap value tag - Default style
      'handicap': StyledTextTag(style: base),

      /// Score value tag - Yellow
      'score': StyledTextTag(style: base.copyWith(color: AppColors.yellow300)),

      /// Money amount tag - Default style
      'money': StyledTextTag(style: base),

      /// Number value tag - Default style
      'number': StyledTextTag(style: base),

      // ========================================
      // Result Tags
      // ========================================
      /// Win result tag - Default style
      'win': StyledTextTag(style: base),

      /// Lose result tag - Default style
      'lose': StyledTextTag(style: base),

      /// Draw/refund result tag - Default style
      'draw': StyledTextTag(style: base),

      /// Half win result tag - Default style
      'halfwin': StyledTextTag(style: base),

      /// Half lose result tag - Default style
      'halflose': StyledTextTag(style: base),

      // ========================================
      // Case Tags
      // ========================================
      /// Case label tag (TH1, TH2, etc.) - Default style
      'case': StyledTextTag(style: base),

      /// Condition description tag - Default style
      'condition': StyledTextTag(style: base),
    };
  }
}
