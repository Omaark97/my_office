import 'package:flutter/material.dart';

class TransactionDetailPage extends StatefulWidget {
  final String clientName;
  final String transactionType;
  final String status;
  final String dateReceived;
  final String dateCompleted;
  final List<String> imageUrls;

  const TransactionDetailPage({
    super.key,
    required this.clientName,
    required this.transactionType,
    required this.status,
    required this.dateReceived,
    required this.dateCompleted,
    required this.imageUrls,
  });

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}
class _TransactionDetailPageState extends State<TransactionDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clientName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Transaction Type: ${widget.transactionType}"),
            const SizedBox(height: 8),
            Text("Status: ${widget.status}"),
            const SizedBox(height: 8),
            Text("Date Received: ${widget.dateReceived}"),
            const SizedBox(height: 8),
            if (widget.dateCompleted.isNotEmpty)
            Text("Date Completed: ${widget.dateCompleted}"),
            const SizedBox(height: 16),
            const Text("Documents:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemCount: widget.imageUrls.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.imageUrls[index],
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}