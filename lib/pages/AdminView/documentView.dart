import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart'; // Ensure you have this dependency in your pubspec.yaml

class DocumentViewerScreen extends StatelessWidget {
  final String fileUrl;

  const DocumentViewerScreen({super.key, required this.fileUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ดูเอกสาร'),
      ),
      body: fileUrl.isNotEmpty
          ? SfPdfViewer.network(fileUrl) // Use the syncfusion PDF viewer
          : const Center(child: Text('ไม่สามารถแสดงเอกสารได้')),
    );
  }
}
