const _arabicIndicZero = 0x0660;
const _easternArabicIndicZero = 0x06F0;
final _whitespaceRun = RegExp(r'\s+');

String? normalizePhone(String? phone) {
  if (phone == null) return null;
  final westernDigits = String.fromCharCodes(phone.runes.map(_toWesternDigit));
  final tidy = westernDigits.replaceAll(_whitespaceRun, ' ').trim();
  return tidy.isEmpty ? null : tidy;
}

int _toWesternDigit(int rune) {
  if (rune >= _arabicIndicZero && rune <= _arabicIndicZero + 9) {
    return 0x30 + rune - _arabicIndicZero;
  }
  if (rune >= _easternArabicIndicZero && rune <= _easternArabicIndicZero + 9) {
    return 0x30 + rune - _easternArabicIndicZero;
  }
  return rune;
}
