import 'package:flutter/material.dart';

import '../domain/document_category.dart';
import '../domain/transaction_type.dart';

// Icons live here, not in the domain enums, because the domain layer must
// not import Flutter.

extension TransactionTypeIcon on TransactionType {
  IconData get icon {
    switch (this) {
      case TransactionType.privateCarRegistration:
        return Icons.directions_car;
      case TransactionType.motorcycleRegistration:
        return Icons.two_wheeler;
      case TransactionType.privateCarOwnershipTransfer:
        return Icons.swap_horiz;
      case TransactionType.motorcycleOwnershipTransfer:
        return Icons.sync_alt;
      case TransactionType.lienRelease:
        return Icons.lock_open;
      case TransactionType.publicTaxiRegistration:
        return Icons.local_taxi;
      case TransactionType.privateFreightRegistration:
        return Icons.local_shipping;
      case TransactionType.licenseRenewal:
        return Icons.card_membership;
      case TransactionType.specialPlateAllocation:
        return Icons.pin;
      case TransactionType.other:
        return Icons.more_horiz;
    }
  }
}

extension DocumentCategoryIcon on DocumentCategory {
  IconData get icon {
    switch (this) {
      case DocumentCategory.identification:
        return Icons.badge;
      case DocumentCategory.saleDeed:
        return Icons.description;
      case DocumentCategory.salePowerOfAttorney:
        return Icons.draw;
      case DocumentCategory.powerOfAttorney:
        return Icons.gavel;
      case DocumentCategory.policeReport:
        return Icons.local_police;
      case DocumentCategory.inheritanceCertificate:
        return Icons.family_restroom;
      case DocumentCategory.lienRelease:
        return Icons.lock_open;
      case DocumentCategory.scrapCertificate:
        return Icons.delete_forever;
      case DocumentCategory.other:
        return Icons.more_horiz;
    }
  }
}
