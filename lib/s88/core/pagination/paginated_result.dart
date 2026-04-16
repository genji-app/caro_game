class PaginatedResult<T> {
  final List<T> items; // Danh sách dữ liệu trang hiện tại
  final int totalCount; // Tổng số bản ghi (biến count của bạn)
  final int currentCursor; // Chính là biến current/skip bạn truyền vào ban đầu
  final int limit; // Số lượng item mỗi trang
  final int? nextCursor; // Offset cho trang tiếp theo (null nếu hết dữ liệu)
  final bool isLastPage; // Cờ báo hiệu đã đến trang cuối

  PaginatedResult({
    required this.items,
    required this.totalCount,
    required this.currentCursor,
    required this.limit,
    required this.isLastPage,
    this.nextCursor,
  });
}
