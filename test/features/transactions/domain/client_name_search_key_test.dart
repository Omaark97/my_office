import 'package:flutter_test/flutter_test.dart';
import 'package:my_office/features/transactions/domain/client_name_search_key.dart';

void main() {
  group('spacing and Latin letters', () {
    test('trims and collapses spaces, tabs and new lines', () {
      expect(clientNameSearchKey('  Test   User\t\n1  '), 'test user 1');
    });

    test('lowercases Latin letters', () {
      expect(clientNameSearchKey('TEST User'), 'test user');
    });

    test('an empty or blank name gives an empty key', () {
      expect(clientNameSearchKey(''), '');
      expect(clientNameSearchKey('   '), '');
    });
  });

  group('Arabic letters', () {
    test('unifies أ إ آ to ا', () {
      expect(clientNameSearchKey('أحمد'), 'احمد');
      expect(clientNameSearchKey('إبراهيم'), 'ابراهيم');
      expect(clientNameSearchKey('آدم'), 'ادم');
    });

    test('turns ة into ه', () {
      expect(clientNameSearchKey('فاطمة'), 'فاطمه');
    });

    test('turns ى into ي', () {
      expect(clientNameSearchKey('مصطفى'), 'مصطفي');
      expect(clientNameSearchKey('يحيى'), 'يحيي');
    });

    test('removes tashkeel', () {
      expect(clientNameSearchKey('مُحَمَّد'), 'محمد');
      expect(clientNameSearchKey('عَلِيٌّ'), 'علي');
    });

    test('removes tatweel', () {
      expect(clientNameSearchKey('محـــمد'), 'محمد');
    });

    test('does not change plain Arabic letters', () {
      expect(clientNameSearchKey('خالد'), 'خالد');
    });
  });

  group('whole names', () {
    test('normalizes everything at once', () {
      expect(clientNameSearchKey('  أَحمـد   مصطفى  '), 'احمد مصطفي');
    });

    test('mixed Arabic and English names', () {
      expect(clientNameSearchKey('أحمد  ALI'), 'احمد ali');
    });

    test('common spelling variants give the same key', () {
      final pairs = [
        ('أحمد', 'احمد'),
        ('إسراء', 'اسراء'),
        ('فاطمة', 'فاطمه'),
        ('مصطفى', 'مصطفي'),
        ('مُنى', 'مني'),
        ('آمنة يوسف', 'امنه   يوسف'),
      ];
      for (final (written, typed) in pairs) {
        expect(
          clientNameSearchKey(written),
          clientNameSearchKey(typed),
          reason: '$written vs $typed',
        );
      }
    });
  });
}
