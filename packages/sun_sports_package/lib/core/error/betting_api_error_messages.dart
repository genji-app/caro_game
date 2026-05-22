/// When place-bet fails without a mapped code or server message.
const String bettingApiPlaceBetFailureFallback =
    'Đặt cược thất bại. Vui lòng thử lại!';

/// When parlay place-bet fails without a mapped code or server message.
const String bettingApiParlayComboFailureFallback =
    'Đặt cược xiên thất bại. Vui lòng thử lại!';

/// When calculate-bet fails (unmapped code, server text, or client).
const String bettingApiCalculateBetFailureFallback =
    'Không thể tính toán cược. Vui lòng thử lại!';

/// When calculate combo fails (unmapped code, server text, or client).
const String bettingApiCalculateParlayFailureFallback =
    'Không thể tính toán cược xiên. Vui lòng thử lại!';

String? bettingApiErrorMessage(int? errorCode) {
  switch (errorCode) {
    case 400:
      return 'Yêu cầu không hợp lệ!';
    case 600:
      return 'Bạn không đủ số dư để cược, vui lòng nạp thêm!';
    case 601:
      return 'Trận đấu không tồn tại. Vui lòng thử lại!';
    case 602:
      return 'Kèo không tồn tại. Vui lòng thử lại!';
    case 603:
      return 'Tỳ lệ cược đã thay đổi';
    case 604:
      return 'Tỷ số đã thay đổi';
    case 605:
      return 'Số tiền cược phải lớn hơn mức cược tối thiểu!';
    case 606:
      return 'Số tiền cược phải nhỏ hơn mức cược tối đa!';
    case 607:
      return 'Không tìm thấy tỷ lệ cược';
    case 608:
    case 609:
    case 610:
      return 'Bạn không thể cược tỷ lệ này!';
    case 611:
    case 613:
      return 'Không tìm thấy tỷ lệ cược';
    case 614:
      return 'Người chơi đã bị khóa. Vui lòng liên hệ CSKH.';
    case 615:
      return 'Tiền cược không được nhỏ hơn mức cược tối thiểu!';
    case 616:
      return 'Tỷ lệ kèo không hỗ trợ, vui lòng thử lại hoặc chọn kèo khác.';
    case 617:
      return 'Số tiền cược phải nhỏ hơn mức cược tối đa!';
    case 618:
      return 'Vượt mức số tiền đặt của kèo này. Vui lòng thử lại với số '
          'tiền nhỏ hơn hoặc chọn kèo khác.';
    default:
      return null;
  }
}

/// Mapped [errorCode] first, then non-empty [serverMessage], else [fallback].
String bettingApiErrorDisplayMessage(
  int? errorCode, {
  String? serverMessage,
  required String fallback,
}) {
  final mapped = bettingApiErrorMessage(errorCode);
  if (mapped != null) {
    return mapped;
  }
  final trimmed = serverMessage?.trim();
  if (trimmed != null && trimmed.isNotEmpty) {
    return trimmed;
  }
  return fallback;
}

bool bettingApiErrorIsMoneyRelated(int? errorCode) {
  return errorCode == 600 ||
      errorCode == 605 ||
      errorCode == 606 ||
      errorCode == 615 ||
      errorCode == 617 ||
      errorCode == 618;
}

/// Odds/line changed: API [603], mapped text (Tỳ/Tỷ lệ…), or WS wording.
bool bettingApiErrorIndicatesOddsChanged({
  required int? errorCode,
  String? message,
}) {
  if (errorCode == 603) {
    return true;
  }
  final t = message ?? '';
  return t.toLowerCase().contains('lệ cược đã thay đổi') || t.toLowerCase().contains('kèo đã thay đổi');
}
