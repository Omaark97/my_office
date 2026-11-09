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

  static TransactionType fromKey(String key) {
    for (final type in values) {
      if (type.key == key) return type;
    }
    throw FormatException('Unknown transaction type: "$key"');
  }
}
