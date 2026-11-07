// Turns stored values into the text shown on screen.

/// Shows a date as "2024-05-15", in the phone's local time zone.
///
/// Dates are stored in UTC. Converting with [DateTime.toLocal] first means a
/// transaction completed at 01:00 in Beirut (22:00 UTC the day before) still
/// shows Beirut's date.
String formatDate(DateTime date) {
  final local = date.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}

/// Shows a file size as "1.2 MB", or as "45 KB" for files under 0.1 MB.
String formatFileSize(int bytes) {
  const kilobyte = 1024;
  const megabyte = 1024 * 1024;
  if (bytes < kilobyte) return '$bytes B';
  if (bytes < megabyte ~/ 10) return '${(bytes / kilobyte).round()} KB';
  return '${(bytes / megabyte).toStringAsFixed(1)} MB';
}
