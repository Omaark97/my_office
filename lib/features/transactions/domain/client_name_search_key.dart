final _arabicDiacriticsAndTatweel = RegExp('[\u064B-\u065F\u0670\u0640]');
final _alefWithHamzaOrMadda = RegExp('[\u0622\u0623\u0625]');
const _plainAlef = '\u0627';
const _taMarbuta = '\u0629';
const _ha = '\u0647';
const _alefMaqsura = '\u0649';
const _ya = '\u064A';
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
