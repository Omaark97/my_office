import '../domain/document_category.dart';
import '../domain/transaction.dart';
import '../domain/transaction_document.dart';
import '../domain/transaction_status.dart';
import '../domain/transaction_type.dart';
import 'transaction_repository.dart';

class InMemoryTransactionRepository implements TransactionRepository {
  InMemoryTransactionRepository({
    List<Transaction>? transactions,
    Map<String, List<TransactionDocument>>? documents,
    DateTime Function()? clock,
  }) : _transactions = List.of(transactions ?? _testTransactions()),
       _documents = Map.of(documents ?? _testDocuments()),
       _clock = clock ?? DateTime.now;

  final List<Transaction> _transactions;
  final Map<String, List<TransactionDocument>> _documents;
  final DateTime Function() _clock;

  @override
  Future<List<Transaction>> getTransactions() async {
    final newestFirst = List.of(_transactions)..sort(_newestReceivedFirst);
    return List.unmodifiable(newestFirst.take(transactionPageSize));
  }

  @override
  Future<List<TransactionDocument>> getDocuments(String transactionId) async {
    return List.unmodifiable(_documents[transactionId] ?? const []);
  }

  @override
  Future<void> updateStatus(String id, TransactionStatus status) async {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index == -1) {
      throw StateError('No transaction with id "$id"');
    }
    final now = _clock().toUtc();
    _transactions[index] = _transactions[index].copyWith(
      status: status,
      dateCompleted: status == TransactionStatus.completed ? now : null,
      updatedAt: now,
    );
  }
}

int _newestReceivedFirst(Transaction a, Transaction b) {
  final byDate = b.dateReceived.compareTo(a.dateReceived);
  return byDate != 0 ? byDate : b.id.compareTo(a.id);
}

const _staffUid = 'test-staff-uid';

DateTime _day(int year, int month, int day) =>
    DateTime.utc(year, month, day, 12);

int _megabytes(double mb) => (mb * 1024 * 1024).round();

List<Transaction> _testTransactions() {
  return [
    Transaction(
      id: 'test-1',
      type: TransactionType.publicTaxiRegistration,
      clientName: 'Test User 1',
      status: TransactionStatus.completed,
      dateReceived: _day(2024, 5, 15),
      dateCompleted: _day(2024, 5, 15),
      createdBy: _staffUid,
      createdAt: _day(2024, 5, 15),
      updatedAt: _day(2024, 5, 15),
    ),
    Transaction(
      id: 'test-2',
      type: TransactionType.licenseRenewal,
      clientName: 'Test User 2',
      status: TransactionStatus.pending,
      dateReceived: _day(2024, 6, 1),
      createdBy: _staffUid,
      createdAt: _day(2024, 6, 1),
      updatedAt: _day(2024, 6, 1),
    ),
    Transaction(
      id: 'test-3',
      type: TransactionType.lienRelease,
      clientName: 'Test User 3',
      status: TransactionStatus.completed,
      dateReceived: _day(2024, 4, 15),
      dateCompleted: _day(2024, 4, 20),
      createdBy: _staffUid,
      createdAt: _day(2024, 4, 15),
      updatedAt: _day(2024, 4, 20),
    ),
    Transaction(
      id: 'test-4',
      type: TransactionType.privateCarOwnershipTransfer,
      clientName: 'Test User 4',
      status: TransactionStatus.pending,
      dateReceived: _day(2024, 5, 30),
      createdBy: _staffUid,
      createdAt: _day(2024, 5, 30),
      updatedAt: _day(2024, 5, 30),
    ),
    Transaction(
      id: 'test-5',
      type: TransactionType.publicTaxiRegistration,
      clientName: 'Test User 5',
      status: TransactionStatus.pending,
      dateReceived: _day(2024, 5, 30),
      createdBy: _staffUid,
      createdAt: _day(2024, 5, 30),
      updatedAt: _day(2024, 5, 30),
    ),
  ];
}

TransactionDocument _testDocument({
  required String transactionId,
  required String id,
  required String name,
  required double megabytes,
  required DocumentCategory category,
  required DateTime uploadedAt,
}) {
  final isPdf = name.endsWith('.pdf');
  return TransactionDocument(
    id: id,
    name: name,
    mimeType: isPdf ? 'application/pdf' : 'image/jpeg',
    sizeBytes: _megabytes(megabytes),
    category: category,
    uploadedAt: uploadedAt,
    uploadedBy: _staffUid,
    storagePath:
        'transactions/$transactionId/documents/$id.${isPdf ? 'pdf' : 'jpg'}',
  );
}

Map<String, List<TransactionDocument>> _testDocuments() {
  return {
    'test-1': [
      _testDocument(
        transactionId: 'test-1',
        id: 'doc-1',
        name: 'ID_Front.jpg',
        megabytes: 1.2,
        category: DocumentCategory.identification,
        uploadedAt: _day(2024, 5, 15),
      ),
      _testDocument(
        transactionId: 'test-1',
        id: 'doc-2',
        name: 'Taxi_License.pdf',
        megabytes: 2.5,
        category: DocumentCategory.other,
        uploadedAt: _day(2024, 5, 15),
      ),
      _testDocument(
        transactionId: 'test-1',
        id: 'doc-3',
        name: 'Sale_Deed.pdf',
        megabytes: 3.1,
        category: DocumentCategory.saleDeed,
        uploadedAt: _day(2024, 5, 15),
      ),
    ],
    'test-2': [
      _testDocument(
        transactionId: 'test-2',
        id: 'doc-4',
        name: 'Current_License.jpg',
        megabytes: 1.2,
        category: DocumentCategory.identification,
        uploadedAt: _day(2024, 6, 1),
      ),
      _testDocument(
        transactionId: 'test-2',
        id: 'doc-5',
        name: 'Proof_of_Residency.pdf',
        megabytes: 2.8,
        category: DocumentCategory.other,
        uploadedAt: _day(2024, 6, 1),
      ),
    ],
    'test-3': [
      _testDocument(
        transactionId: 'test-3',
        id: 'doc-6',
        name: 'Bank_Release_Letter.pdf',
        megabytes: 0.8,
        category: DocumentCategory.lienRelease,
        uploadedAt: _day(2024, 4, 15),
      ),
    ],
    'test-4': [
      _testDocument(
        transactionId: 'test-4',
        id: 'doc-7',
        name: 'Buyer_ID.jpg',
        megabytes: 1.4,
        category: DocumentCategory.identification,
        uploadedAt: _day(2024, 5, 30),
      ),
      _testDocument(
        transactionId: 'test-4',
        id: 'doc-8',
        name: 'Seller_ID.jpg',
        megabytes: 1.3,
        category: DocumentCategory.identification,
        uploadedAt: _day(2024, 5, 30),
      ),
      _testDocument(
        transactionId: 'test-4',
        id: 'doc-9',
        name: 'Notary_POA.pdf',
        megabytes: 2.2,
        category: DocumentCategory.salePowerOfAttorney,
        uploadedAt: _day(2024, 5, 30),
      ),
      _testDocument(
        transactionId: 'test-4',
        id: 'doc-10',
        name: 'Vehicle_Registration.pdf',
        megabytes: 1.8,
        category: DocumentCategory.other,
        uploadedAt: _day(2024, 5, 30),
      ),
    ],
  };
}
