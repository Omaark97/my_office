// Small helpers for reading a saved map back into a model.
//
// They throw a FormatException with the field name when data is missing or
// has the wrong type, so a broken record is easy to find.

String readString(Map<String, dynamic> map, String field) {
  final value = map[field];
  if (value is String) return value;
  throw FormatException('Field "$field" must be a String, got: $value');
}

String? readOptionalString(Map<String, dynamic> map, String field) {
  final value = map[field];
  if (value == null || value is String) return value as String?;
  throw FormatException('Field "$field" must be a String or null, got: $value');
}

int readInt(Map<String, dynamic> map, String field) {
  final value = map[field];
  if (value is int) return value;
  throw FormatException('Field "$field" must be an int, got: $value');
}

/// Reads a date and returns it in UTC.
DateTime readDate(Map<String, dynamic> map, String field) {
  final value = map[field];
  if (value is DateTime) return value.toUtc();
  throw FormatException('Field "$field" must be a DateTime, got: $value');
}

/// Reads an optional date and returns it in UTC, or null.
DateTime? readOptionalDate(Map<String, dynamic> map, String field) {
  final value = map[field];
  if (value == null) return null;
  if (value is DateTime) return value.toUtc();
  throw FormatException(
    'Field "$field" must be a DateTime or null, got: $value',
  );
}
