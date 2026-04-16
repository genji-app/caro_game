/// {@template game_utils}
/// Utility class for game repository data processing.
/// {@endtemplate}
class GameUtils {
  /// Generate image filename from game info.
  ///
  /// Formula: [providerId]_[gameCode]_[slugGameName]_thumb.webp
  ///
  /// Example:
  /// - providerId: "sunwin"
  /// - gameCode: "SEXY-001"
  /// - gameName: "Tài Xỉu Hot"
  /// Result: "sunwin_SEXY-001_tai_xiu_hot_thumb.webp"
  String generateImageName({
    required String providerId,
    required String gameCode,
    required String gameName,
  }) {
    // Create slug from game name
    final slug = slugify(gameName);

    // Format: [providerId]_[gameCode]_[slugGameName]_thumb.webp
    return '${providerId}_${gameCode}_${slug}_thumb.webp';
  }

  /// Convert string to slug (lowercase, Vietnamese → non-accented, spaces → hyphens)
  ///
  /// Examples:
  /// - "Baccarat Siêu Tốc A" → "baccarat-sieu-toc-a"
  /// - "Rồng Hổ" → "rong-ho"
  String slugify(String text) {
    // Convert Vietnamese characters to non-accented equivalents
    final normalized = removeDiacritics(text);

    return normalized
        .toLowerCase() // Convert to lowercase
        .trim() // Remove leading/trailing whitespace
        .replaceAll(RegExp(r'\s+'), '-') // Replace spaces with hyphen
        .replaceAll(
          RegExp(r'[^a-z0-9\-]'),
          '',
        ) // Keep only alphanumeric and hyphen
        .replaceAll(
          RegExp(r'-+'),
          '-',
        ) // Replace consecutive hyphens with single
        .replaceAll(RegExp(r'^-|-$'), ''); // Remove leading/trailing hyphens
  }

  /// Remove Vietnamese diacritics from a string.
  /// Converts "Tiếng Việt" to "Tieng Viet".
  ///
  /// Examples:
  /// - "Siêu Tốc" → "Sieu Toc"
  /// - "Rồng Hổ" → "Rong Ho"
  String removeDiacritics(String str) {
    const vietnamese = 'aAeEoOuUiIdDyY';
    const vietnameseRegex = <String>[
      'aàảãáạăằẳẵắặâầẩẫấậ',
      'AÀẢÃÁẠĂẰẲẴẮẶÂẦẨẪẤẬ',
      'eèẻẽéẹêềểễếệ',
      'EÈẺẼÉẸÊỀỂỄẾỆ',
      'oòỏõóọôồổỗốộơờởỡớợ',
      'OÒỎÕÓỌÔỒỔỖỐỘƠỜỞỠỚỢ',
      'uùủũúụưừửữứự',
      'UÙỦŨÚỤƯỪỬỮỨỰ',
      'iìỉĩíị',
      'IÌỈĨÍỊ',
      'dđ',
      'DĐ',
      'yỳỷỹýỵ',
      'YỲỶỸÝỴ',
    ];

    var result = str;
    for (var i = 0; i < vietnameseRegex.length; i++) {
      final regExp = RegExp('[${vietnameseRegex[i]}]');
      result = result.replaceAll(regExp, vietnamese[i]);
    }
    return result;
  }
}
