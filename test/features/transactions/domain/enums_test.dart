import 'package:flutter_test/flutter_test.dart';
import 'package:my_office/features/transactions/domain/document_category.dart';
import 'package:my_office/features/transactions/domain/transaction_status.dart';
import 'package:my_office/features/transactions/domain/transaction_type.dart';

void main() {
  // These tests lock the saved keys. If one fails, someone renamed a key that
  // is already stored in the database. Add a new value instead.
  group('TransactionType', () {
    test('has exactly the agreed keys', () {
      expect(TransactionType.values.map((t) => t.key), [
        'privateCarRegistration',
        'motorcycleRegistration',
        'privateCarOwnershipTransfer',
        'motorcycleOwnershipTransfer',
        'lienRelease',
        'publicTaxiRegistration',
        'privateFreightRegistration',
        'licenseRenewal',
        'specialPlateAllocation',
        'other',
      ]);
    });

    test('fromKey finds every value by its key', () {
      for (final type in TransactionType.values) {
        expect(TransactionType.fromKey(type.key), type);
      }
    });

    test('fromKey throws for an unknown key', () {
      expect(() => TransactionType.fromKey('spaceship'), throwsFormatException);
    });
  });

  group('TransactionStatus', () {
    test('has exactly the agreed keys', () {
      expect(TransactionStatus.values.map((s) => s.key), [
        'pending',
        'completed',
        'cancelled',
      ]);
    });

    test('fromKey finds every value by its key', () {
      for (final status in TransactionStatus.values) {
        expect(TransactionStatus.fromKey(status.key), status);
      }
    });

    test('fromKey throws for an unknown key', () {
      expect(() => TransactionStatus.fromKey('Done'), throwsFormatException);
    });
  });

  group('DocumentCategory', () {
    test('has exactly the agreed keys', () {
      expect(DocumentCategory.values.map((c) => c.key), [
        'identification',
        'saleDeed',
        'salePowerOfAttorney',
        'powerOfAttorney',
        'policeReport',
        'inheritanceCertificate',
        'lienRelease',
        'scrapCertificate',
        'other',
      ]);
    });

    test('fromKey finds every value by its key', () {
      for (final category in DocumentCategory.values) {
        expect(DocumentCategory.fromKey(category.key), category);
      }
    });

    test('fromKey throws for an unknown key', () {
      expect(() => DocumentCategory.fromKey('photo'), throwsFormatException);
    });
  });
}
