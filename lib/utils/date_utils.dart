/// Calendar/date helpers (mirrors Flutter Material [DateUtils.dateOnly] behavior).
abstract final class DateUtils {
  DateUtils._();

  /// Returns a [DateTime] with the same calendar date as [date] and time set
  /// to 00:00:00.000.
  ///
  /// If [date] is UTC, the result is UTC; otherwise the result is local.
  static DateTime dateOnly(DateTime date) {
    return date.isUtc
        ? DateTime.utc(date.year, date.month, date.day)
        : DateTime(date.year, date.month, date.day);
  }
}
