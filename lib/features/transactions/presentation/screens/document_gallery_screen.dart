import 'package:flutter/material.dart';

class DocumentGalleryScreen extends StatelessWidget {
  final String title;

  const DocumentGalleryScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Browsing documents by category is coming soon. '
            'Open a transaction to see its documents.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      ),
    );
  }
}
