String notificationCategoryFromMessage(String message) {
  final lower = message.toLowerCase();
  final hasTiLe = lower.contains('tỉ lệ cược') || lower.contains('tỷ lệ cược');
  if (hasTiLe) {
    return 'Tỷ lệ cược tốt!';
  }
  final hasCapNhat = lower.contains('cập nhật');
  final hasTranDau = lower.contains('trận đấu');
  if (hasCapNhat || hasTranDau) {
    return 'Cập nhật kết quả trận đấu';
  }
  return 'Khác';
}
