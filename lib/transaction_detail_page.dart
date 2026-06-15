import 'package:flutter/material.dart';

class TransactionDetailPage extends StatefulWidget {
  final String clientName;
  final String transactionType;
  final String status;
  final String dateReceived;
  final String dateCompleted;
  final List<String> imageUrls;
  final List<Map<String, dynamic>> documents;

  const TransactionDetailPage({
    super.key,
    required this.clientName,
    required this.transactionType,
    required this.status,
    required this.dateReceived,
    required this.dateCompleted,
    required this.imageUrls,
    required this.documents,
  });

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            


            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TRANSACTION DETAILS',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.status == 'Completed'
                              ? Colors.green.shade50
                              : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: widget.status == 'Completed'
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.transactionType,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text('Received: ${widget.dateReceived}'),
                    ],
                  ),
                  if (widget.dateCompleted.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.check_circle, size: 16, color: Colors.green),
                        const SizedBox(width: 8),
                        Text('Completed: ${widget.dateCompleted}'),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'APPLICANT',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.clientName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

// ═══════════════════════════════════
// SECTION 3: DOCUMENTS CARD
// ═══════════════════════════════════
Container(
  width: double.infinity,
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'DOCUMENTS',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
          Text(
            '${widget.documents.length} ${widget.documents.length == 1 ? "file" : "files"}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),

      // Conditional: show list OR empty state
      if (widget.documents.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.folder_open, size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 8),
                Text(
                  'No documents uploaded yet',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        )
      else
        Column(
          children: widget.documents.map((doc) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      doc['name'].toString().endsWith('.pdf')
                          ? Icons.picture_as_pdf
                          : Icons.image,
                      color: Colors.teal,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc['name'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Uploaded ${doc['dateUploaded']} • ${doc['size']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.download, color: Colors.grey.shade600),
                    onPressed: () {
                      // TODO: download functionality (future)
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        ),

      // 👇 NEW: upload zone — INSIDE the Documents card now
      const SizedBox(height: 8),
      GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Upload feature coming soon'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.file_upload_outlined,
                size: 28,
                color: Colors.grey.shade600,
              ),
              const SizedBox(height: 8),
              Text(
                'Add Supporting Documents',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'PDF, JPG, or PNG up to 10MB',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
),

const SizedBox(height: 24),

// ═══════════════════════════════════
// SECTION 4: ACTION BUTTONS
// ═══════════════════════════════════

// Complete Transaction button (primary)
SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: () {
      // TODO: Phase 2 will wire this up to mark as completed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complete Transaction tapped (Phase 2 will wire this up)'),
          duration: Duration(seconds: 2),
        ),
      );
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
    ),
    child: const Text(
      'Complete Transaction',
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
),

const SizedBox(height: 12),

// Cancel Transaction button (secondary)
SizedBox(
  width: double.infinity,
  child: OutlinedButton(
    onPressed: () {
      // TODO: Phase 2 will wire this up to mark as cancelled
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cancel Transaction tapped'),
          duration: Duration(seconds: 2),
        ),
      );
    },
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.grey.shade800,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      side: BorderSide(color: Colors.grey.shade300),
    ),
    child: const Text(
      'Cancel Transaction',
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
),

const SizedBox(height: 24),  // bottom breathing room when scrolled

          ],
        ),
      ),
    );
  }
}