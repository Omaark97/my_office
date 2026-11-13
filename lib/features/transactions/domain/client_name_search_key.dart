final _arabicDiacriticsAndTatweel = RegExp('[ً-ٰٟـ]');
final _alefWithHamzaOrMadda = RegExp('[آأإ]');
const _plainAlef = 'ا';
const _taMarbuta = 'ة';
const _ha = 'ه';
const _alefMaqsura = 'ى';
const _ya = 'ي';
final _whitespaceRun = RegExp(r'\s+');

String clientNameSearchKey(String clientName) {
  return clientName
      .replaceAll(_arabicDiacriticsAndTatweel, '')
      .replaceAll(_alefWithHamzaOrMadda, _plainAlef)
      .replaceAll(_taMarbuta, _ha)
      .replaceAll(_alefMaqsura, _ya)
      .toLowerCase()
      .replaceAll(_whitespaceRun, ' ')
      .trim();
}
