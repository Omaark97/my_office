import 'package:flutter/widgets.dart';

final _rightToLeftLetter = RegExp(
  '[\u0590-\u065F\u066A-\u06EF\u06FA-\u08FF\uFB1D-\uFDFF\uFE70-\uFEFF]',
);
final _leftToRightLetter = RegExp('[A-Za-z\u00C0-\u024F]');

TextDirection textDirectionFor(String text) {
  for (final character in text.characters) {
    if (_rightToLeftLetter.hasMatch(character)) return TextDirection.rtl;
    if (_leftToRightLetter.hasMatch(character)) return TextDirection.ltr;
  }
  return TextDirection.ltr;
}
