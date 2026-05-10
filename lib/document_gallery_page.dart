import 'package:flutter/material.dart';

class DocumentGalleryPage extends StatelessWidget {
  final String title;
  final List<String> imageUrls;

  const DocumentGalleryPage({
    super.key,
    required this.title,
    required this.imageUrls,
  });
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(title),
    ),
    body: GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrls[index],
            fit: BoxFit.cover,
          ),
        );
      },
    ),
  );
}
}