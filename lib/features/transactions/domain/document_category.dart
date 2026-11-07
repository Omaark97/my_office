/// What kind of paper a scanned document is.
///
/// Each value has a fixed [key] that is saved in the database. Never change
/// an existing key. The [label] is only for display.
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

  /// Finds the category saved under [key]. Throws a [FormatException] for an
  /// unknown key.
  static DocumentCategory fromKey(String key) {
    for (final category in values) {
      if (category.key == key) return category;
    }
    throw FormatException('Unknown document category: "$key"');
  }
}
