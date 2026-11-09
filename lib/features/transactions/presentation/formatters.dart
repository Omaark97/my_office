String formatDate(DateTime date) {
  final local = date.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}

String formatFileSize(int bytes) {
  const kilobyte = 1024;
  const megabyte = 1024 * 1024;
  if (bytes < kilobyte) return '$bytes B';
  if (bytes < megabyte ~/ 10) return '${(bytes / kilobyte).round()} KB';
  return '${(bytes / megabyte).toStringAsFixed(1)} MB';
}
