/// Livestream Response Model
///
/// Response from GET /api/v1/streaming/{eventId}
/// API returns numeric keys:
/// - "0": Livestream URL (h5Link) - thường là PATH tương đối, chưa có domain
/// - "2": Stream type (0 livestream, 1 highlight, 2 replay 8', 3 replay 20')
/// - "4": Status message (e.g., "OK")
class LivestreamResponse {
  /// Livestream URL.
  ///
  /// Sau khi qua [wrapWithPlayerDomain] đây là URL player đầy đủ, sẵn sàng
  /// gán vào iframe/WebView. Trước đó nó chỉ là path tương đối từ API.
  final String? url;

  /// Status message from API
  final String? status;

  /// Stream type - quyết định domain player nào được dùng
  /// 0: livestream, 1: highlight, 3: replay 20' -> urlVideoJS
  /// 2: replay 8' -> urlVirtualVideoJS
  final int? type;

  const LivestreamResponse({this.url, this.status, this.type});

  /// Factory constructor for JSON deserialization
  /// Handles both old format (h5Link) and new format (numeric keys)
  factory LivestreamResponse.fromJson(Map<String, dynamic> json) {
    // Try new format first (numeric keys), fallback to old format
    final rawUrl = json['0']?.toString() ?? json['h5Link']?.toString();
    final status = json['4']?.toString() ?? json['status']?.toString();
    final type = _parseType(json['2'] ?? json['type']);

    // Sanitize URL: trim trailing "?=" or "?" (malformed query can cause
    // server to return HTML or wrong content → iOS "format not supported")
    final url = rawUrl != null && rawUrl.isNotEmpty
        ? _sanitizeLivestreamUrl(rawUrl)
        : null;

    return LivestreamResponse(url: url, status: status, type: type);
  }

  static int? _parseType(dynamic raw) {
    if (raw is int) return raw;
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  static String _sanitizeLivestreamUrl(String url) {
    String s = url.trim();
    // Remove trailing "?=" or "?" with no value (API sometimes returns ?=)
    while (s.endsWith('=') || s.endsWith('?')) {
      s = s.substring(0, s.length - 1);
    }
    return s;
  }

  /// Bọc [url] (path tương đối từ API) thành URL player đầy đủ.
  ///
  /// API chỉ trả về h5Link dạng `streamId?type=m3u8&streaming=antmedia&token=x`.
  /// Player thực sự nằm ở domain video, nhận stream qua query `link`:
  ///   `{videoDomain}/?link={encoded h5Link}&size={size}`
  ///
  /// Nếu [url] đã là URL tuyệt đối (http/https) thì giữ nguyên.
  LivestreamResponse wrapWithPlayerDomain({
    required String videoDomain,
    required String virtualVideoDomain,
    int size = 75,
  }) {
    final raw = url;
    if (raw == null || raw.isEmpty) return this;

    // Đã là URL đầy đủ (format cũ) -> không cần bọc
    if (raw.startsWith('http://') || raw.startsWith('https://')) return this;

    // type 2 = replay 8' dùng domain virtual, còn lại dùng video domain
    final domain = type == 2 ? virtualVideoDomain : videoDomain;
    if (domain.isEmpty) {
      // Không có domain player -> path tương đối sẽ load nhầm chính website.
      // Trả url null để UI hiển thị "không có livestream" thay vì đệ quy.
      return LivestreamResponse(url: null, status: status, type: type);
    }

    final base = domain.endsWith('/')
        ? domain.substring(0, domain.length - 1)
        : domain;
    final wrapped = '$base/?link=${Uri.encodeComponent(raw)}&size=$size';

    return LivestreamResponse(url: wrapped, status: status, type: type);
  }

  /// Check if livestream URL is available and valid
  bool get hasUrl => url != null && url!.isNotEmpty;

  /// Check if response indicates success
  bool get isSuccess => status == 'OK' || hasUrl;

  @override
  String toString() =>
      'LivestreamResponse(url: $url, status: $status, type: $type)';
}
