/// Livestream Response Model
///
/// Response from GET /api/v1/streaming/{eventId}
/// API returns numeric keys:
/// - "0": Livestream URL (h5Link)
/// - "4": Status message (e.g., "OK")
class LivestreamResponse {
  /// Livestream URL for H5/web player
  final String? url;

  /// Status message from API
  final String? status;

  const LivestreamResponse({this.url, this.status});

  /// Factory constructor for JSON deserialization
  /// Handles both old format (h5Link) and new format (numeric keys)
  factory LivestreamResponse.fromJson(Map<String, dynamic> json) {
    // Try new format first (numeric keys), fallback to old format
    final rawUrl = json['0']?.toString() ?? json['h5Link']?.toString();
    final status = json['4']?.toString() ?? json['status']?.toString();

    // Sanitize URL: trim trailing "?=" or "?" (malformed query can cause
    // server to return HTML or wrong content → iOS "format not supported")
    final url = rawUrl != null && rawUrl.isNotEmpty
        ? _sanitizeLivestreamUrl(rawUrl)
        : null;

    return LivestreamResponse(url: url, status: status);
  }

  static String _sanitizeLivestreamUrl(String url) {
    String s = url.trim();
    // Remove trailing "?=" or "?" with no value (API sometimes returns ?=)
    while (s.endsWith('=') || s.endsWith('?')) {
      s = s.substring(0, s.length - 1);
    }
    return s;
  }

  /// Check if livestream URL is available and valid
  bool get hasUrl => url != null && url!.isNotEmpty;

  /// Check if response indicates success
  bool get isSuccess => status == 'OK' || hasUrl;

  @override
  String toString() => 'LivestreamResponse(url: $url, status: $status)';
}
