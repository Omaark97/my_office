import 'package:flutter_test/flutter_test.dart';
import 'package:my_office/features/transactions/domain/phone_number.dart';
import 'package:my_office/features/transactions/domain/received_date.dart';
import 'package:my_office/features/transactions/domain/transaction_draft.dart';
import 'package:my_office/features/transactions/domain/transaction_type.dart';

void main() {
  group('normalizePhone', () {
    test('keeps Lebanese formats as typed', () {
      expect(normalizePhone('03 123 456'), '03 123 456');
      expect(normalizePhone('71123456'), '71123456');
      expect(normalizePhone('+961 3 123 456'), '+961 3 123 456');
      expect(normalizePhone('00961-1-234567'), '00961-1-234567');
    });

    test('tidies spaces', () {
      expect(normalizePhone('  03   123\t456 '), '03 123 456');
    });

    test('turns Arabic-Indic digits into 0-9', () {
      expect(normalizePhone('٠٣ ١٢٣ ٤٥٦'), '03 123 456');
      expect(normalizePhone('۰۳۱۲۳۴۵۶'), '03123456');
      expect(normalizePhone('+٩٦١ ٧٨ ٩٠٠ ٠٠٠'), '+961 78 900 000');
    });

    test('an empty or missing phone becomes null', () {
      expect(normalizePhone(null), isNull);
      expect(normalizePhone(''), isNull);
      expect(normalizePhone('   '), isNull);
    });
  });

  group('isValidClientName', () {
    test('accepts Arabic and English names', () {
      expect(isValidClientName('Test User 1'), isTrue);
      expect(isValidClientName('أحمد'), isTrue);
    });

    test('rejects names that are empty after normalizing', () {
      expect(isValidClientName(''), isFalse);
      expect(isValidClientName('   '), isFalse);
      expect(isValidClientName('ـــ'), isFalse);
      expect(isValidClientName('َُِ'), isFalse);
    });
  });

  group('received dates', () {
    test('a picked day is stored as 12:00 local time, in UTC', () {
      final stored = receivedDateFor(DateTime(2024, 5, 15, 23, 59));

      expect(stored.isUtc, isTrue);
      expect(stored.toLocal(), DateTime(2024, 5, 15, 12));
    });

    test('calendarDay drops the time of day in local time', () {
      expect(calendarDay(DateTime(2024, 5, 15, 18, 30)), DateTime(2024, 5, 15));
    });

    test('allows days from 1 January 1980 up to today', () {
      final today = DateTime(2026, 11, 13, 9);

      expect(isAllowedReceivedDay(DateTime(1980, 1, 1), today: today), isTrue);
      expect(
        isAllowedReceivedDay(DateTime(2026, 11, 13), today: today),
        isTrue,
      );
      expect(
        isAllowedReceivedDay(DateTime(1979, 12, 31), today: today),
        isFalse,
      );
      expect(
        isAllowedReceivedDay(DateTime(2026, 11, 14), today: today),
        isFalse,
      );
    });
  });

  test('cleaned trims the name, normalizes the phone and keeps UTC', () {
    final draft = TransactionDraft(
      type: TransactionType.lienRelease,
      clientName: '  أحمد مصطفى  ',
      clientPhone: ' ٠٣ ١٢٣ ٤٥٦ ',
      dateReceived: DateTime(2024, 5, 15, 12),
    ).cleaned();

    expect(draft.clientName, 'أحمد مصطفى');
    expect(draft.clientPhone, '03 123 456');
    expect(draft.dateReceived.isUtc, isTrue);
    expect(draft.type, TransactionType.lienRelease);
  });
}
