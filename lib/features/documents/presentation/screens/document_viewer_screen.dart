import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../transactions/presentation/transaction_providers.dart';
import '../document_error_message.dart';
import '../document_providers.dart';

class DocumentViewerScreen extends ConsumerWidget {
  const DocumentViewerScreen({
    super.key,
    required this.transactionId,
    required this.documentId,
  });

  final String transactionId;
  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documents = ref.watch(transactionDocumentsProvider(transactionId));
    final document = documents.value
        ?.where((d) => d.id == documentId)
        .firstOrNull;
    final bytes = document == null
        ? null
        : ref.watch(documentBytesProvider(document.storagePath));

    Widget body;
    if (documents.isLoading && document == null) {
      body = const CircularProgressIndicator(color: Colors.white);
    } else if (document == null) {
      body = const _Message('Document not found');
    } else {
      body = bytes!.when(
        loading: () => const CircularProgressIndicator(color: Colors.white),
        error: (error, stackTrace) => _Message(
          documentErrorMessage(
            error,
            fallback: 'Could not open the document. Please try again.',
          ),
        ),
        data: (imageBytes) => InteractiveViewer(
          minScale: 1,
          maxScale: 6,
          child: Image.memory(imageBytes, fit: BoxFit.contain),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          document?.name ?? 'Document',
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Center(child: body),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
