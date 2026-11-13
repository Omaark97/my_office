import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_office/features/transactions/presentation/text_direction.dart';

void main() {
  test('Arabic names are right-to-left', () {
    expect(textDirectionFor('أحمد'), TextDirection.rtl);
    expect(textDirectionFor('سامي يوسف'), TextDirection.rtl);
  });

  test('English names are left-to-right', () {
    expect(textDirectionFor('Test User'), TextDirection.ltr);
  });

  test('the first letter decides for mixed names', () {
    expect(textDirectionFor('أحمد Ali'), TextDirection.rtl);
    expect(textDirectionFor('Ali أحمد'), TextDirection.ltr);
  });

  test('spaces, digits and punctuation do not decide', () {
    expect(textDirectionFor('  ١٢ - أحمد'), TextDirection.rtl);
    expect(textDirectionFor('12 Test'), TextDirection.ltr);
  });

  test('empty text is left-to-right', () {
    expect(textDirectionFor(''), TextDirection.ltr);
    expect(textDirectionFor('   '), TextDirection.ltr);
  });
}
