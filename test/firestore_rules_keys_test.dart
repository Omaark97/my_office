import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_office/features/transactions/domain/document_category.dart';
import 'package:my_office/features/transactions/domain/transaction_type.dart';

List<String> _keysListedInRulesFunction(String rules, String functionName) {
  final body = RegExp(
    'function $functionName\\(\\) \\{\\s*return \\[([^\\]]*)\\]',
  ).firstMatch(rules);
  if (body == null) {
    throw StateError('firestore.rules has no $functionName() list');
  }
  return [for (final key in RegExp("'([^']+)'").allMatches(body[1]!)) key[1]!];
}

void main() {
  final rules = File('firestore.rules').readAsStringSync();

  test('the rules allow exactly the TransactionType keys', () {
    expect(
      _keysListedInRulesFunction(rules, 'transactionTypes'),
      TransactionType.values.map((type) => type.key),
    );
  });

  test('the rules allow exactly the DocumentCategory keys', () {
    expect(
      _keysListedInRulesFunction(rules, 'documentCategories'),
      DocumentCategory.values.map((category) => category.key),
    );
  });
}
