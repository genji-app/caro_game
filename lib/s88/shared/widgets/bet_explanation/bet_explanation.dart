/// Bet Explanation Module
///
/// Provides a shared, reusable tooltip widget for displaying bet explanations
/// across the application with consistent behavior and smart positioning.
///
/// ## Components:
/// - [BetExplanationTooltip] - Main tooltip widget
/// - [BetTooltipConfig] - Configuration class
/// - Extension methods for converting bet models to HintData
///
/// ## Usage:
/// ```dart
/// // Simple usage with default icon
/// BetExplanationTooltip.icon(
///   hintData: singleBet.toHintData(),
///   iconColor: AppColorStyles.contentSecondary,
/// )
///
/// // Custom trigger
/// BetExplanationTooltip(
///   hintData: bet.toHintData(),
///   triggerBuilder: (onTap) => TextButton(
///     onPressed: onTap,
///     child: Text('Info'),
///   ),
/// )
///
/// // Custom configuration
/// BetExplanationTooltip.icon(
///   hintData: myHintData,
///   config: BetTooltipConfig(
///     tooltipWidth: 300,
///     rootOverlay: true,
///   ),
/// )
/// ```
library;

export 'bet_explanation_tooltip.dart';
export 'bet_tooltip_config.dart';
export 'bet_data_extensions.dart';
