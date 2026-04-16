// This file is kept for backward compatibility.
// Business logic has been moved to domain/services/market_converter_service.dart
//
// New code should import from:
// import 'package:co_caro_flame/s88/features/sport/domain/services/market_converter_service.dart';

export 'package:co_caro_flame/s88/features/sport/domain/services/market_converter_service.dart';

// Legacy aliases for backward compatibility
import 'package:co_caro_flame/s88/features/sport/domain/services/market_converter_service.dart';

/// @Deprecated('Use MarketConverterService instead')
/// Legacy class name, kept for backward compatibility
typedef LeagueDataConverter = MarketConverterService;

/// @Deprecated('Use LeagueEventDataUIExtension instead')
/// Legacy extension name, kept for backward compatibility
extension LeagueEventDataUIX on dynamic {
  // This extension is replaced by LeagueEventDataUIExtension
  // Import the new extension from market_converter_service.dart
}
