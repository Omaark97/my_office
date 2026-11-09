import 'package:flutter_test/flutter_test.dart';
import 'package:my_office/features/transactions/presentation/formatters.dart';

void main() {
  group('formatDate', () {
    test('pads month and day with zeros', () {
      expect(formatDate(DateTime.utc(2024, 5, 3, 12)), '2024-05-03');
    });

    test('shows a local time as its own local date', () {
      expect(formatDate(DateTime(2024, 5, 15, 23, 30)), '2024-05-15');
      expect(formatDate(DateTime(2024, 5, 15, 0, 30)), '2024-05-15');
    });

    test('shows a UTC time in local time', () {
      final utc = DateTime.utc(2024, 5, 15, 22, 30);

      expect(formatDate(utc), formatDate(utc.toLocal()));
    });
  });

  group('formatFileSize', () {
    test('shows megabytes with one decimal, like the old test data', () {
      expect(formatFileSize(1258291), '1.2 MB');
      expect(formatFileSize(838861), '0.8 MB');
      expect(formatFileSize(3250586), '3.1 MB');
    });

    test('shows small files in kilobytes and bytes', () {
      expect(formatFileSize(46080), '45 KB');
      expect(formatFileSize(512), '512 B');
    });
  });
}
