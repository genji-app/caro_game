String formatNotificationRelativeTime(DateTime createdAt, {DateTime? now}) {
  final n = now ?? DateTime.now();
  var diff = n.difference(createdAt);
  if (diff.isNegative) {
    diff = Duration.zero;
  }
  if (diff.inHours >= 24) {
    return '${diff.inDays} ngày';
  }
  if (diff.inHours >= 1) {
    return '${diff.inHours} giờ';
  }
  if (diff.inMinutes >= 1) {
    return '${diff.inMinutes} phút';
  }
  return '< 1 phút';
}
