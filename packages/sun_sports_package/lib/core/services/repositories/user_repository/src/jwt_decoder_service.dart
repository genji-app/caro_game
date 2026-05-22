import 'package:jwt_decoder/jwt_decoder.dart';

/// Service for decoding JWT tokens
///
/// This service provides utilities to decode JWT tokens and extract
/// information from the payload without verifying the signature.
/// Signature verification is handled by the backend.
abstract class JwtDecoderService {
  /// Decode JWT token and return payload as Map
  ///
  /// Returns null if token is invalid or empty.
  /// Does not verify signature - only decodes the payload.
  Map<String, dynamic>? decodeToken(String token);

  /// Check if token is expired
  ///
  /// Returns true if token is expired or invalid.
  bool isTokenExpired(String token);

  /// Get token expiration date
  ///
  /// Returns null if token is invalid or doesn't have expiration.
  DateTime? getExpirationDate(String token);
}

/// Implementation of JwtDecoderService using jwt_decoder package
class JwtDecoderServiceImpl implements JwtDecoderService {
  @override
  Map<String, dynamic>? decodeToken(String token) {
    try {
      if (token.isEmpty) return null;

      // Decode JWT (doesn't verify signature)
      final decodedToken = JwtDecoder.decode(token);
      return decodedToken;
    } catch (e) {
      // Error decoding JWT token
      return null;
    }
  }

  @override
  bool isTokenExpired(String token) {
    try {
      if (token.isEmpty) return true;
      return JwtDecoder.isExpired(token);
    } catch (e) {
      // If we can't decode, consider it expired
      return true;
    }
  }

  @override
  DateTime? getExpirationDate(String token) {
    try {
      if (token.isEmpty) return null;
      return JwtDecoder.getExpirationDate(token);
    } catch (e) {
      return null;
    }
  }
}
