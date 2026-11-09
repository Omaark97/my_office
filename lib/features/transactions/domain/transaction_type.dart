/// The kind of work the office does for a client.
///
/// Each value has a fixed [key] that is saved in the database. Never change
/// an existing key: old records would no longer be readable. The [label] is
/// only for display and can be changed at any time.
enum TransactionType {
  privateCarRegistration('privateCarRegistration', 'Private Car Registration'),
  motorcycleRegistration('motorcycleRegistration', 'Motorcycle Registration'),
  privateCarOwnershipTransfer(
    'privateCarOwnershipTransfer',
    'Private Car Ownership Transfer',
  ),
  motorcycleOwnershipTransfer(
    'motorcycleOwnershipTransfer',
    'Motorcycle Ownership Transfer',
  ),
  lienRelease('lienRelease', 'Lien Release'),
  publicTaxiRegistration('publicTaxiRegistration', 'Public Taxi Registration'),
  privateFreightRegistration(
    'privateFreightRegistration',
    'Private Freight Vehicle Registration',
  ),
  licenseRenewal('licenseRenewal', "Driver's License Renewal"),
  specialPlateAllocation(
    'specialPlateAllocation',
    'Special Plate Number Allocation',
  ),
  other('other', 'Other');

  const TransactionType(this.key, this.label);

  final String key;
  final String label;

  /// Finds the type saved under [key].
  ///
  /// Throws a [FormatException] for an unknown key, so bad data is noticed
  /// instead of silently shown as the wrong type.
  static TransactionType fromKey(String key) {
    for (final type in values) {
      if (type.key == key) return type;
    }
    throw FormatException('Unknown transaction type: "$key"');
  }
}
