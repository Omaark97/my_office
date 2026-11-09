enum DocumentCategory {
  identification('identification', 'Identification Documents'),
  saleDeed('saleDeed', 'Vehicle Sale Deeds'),
  salePowerOfAttorney('salePowerOfAttorney', 'Sale Power of Attorney'),
  powerOfAttorney('powerOfAttorney', 'Special/General Power of Attorney'),
  policeReport('policeReport', 'Police Reports'),
  inheritanceCertificate('inheritanceCertificate', 'Inheritance Certificates'),
  lienRelease('lienRelease', 'Lien Release'),
  scrapCertificate('scrapCertificate', 'Vehicle Scrap Certificate'),
  other('other', 'Other');

  const DocumentCategory(this.key, this.label);

  final String key;
  final String label;

  static DocumentCategory fromKey(String key) {
    for (final category in values) {
      if (category.key == key) return category;
    }
    throw FormatException('Unknown document category: "$key"');
  }
}
