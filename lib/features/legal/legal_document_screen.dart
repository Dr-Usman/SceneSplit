import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'legal_document_type.dart';

class LegalDocumentScreen extends StatefulWidget {
  const LegalDocumentScreen({super.key, required this.type});

  final LegalDocumentType type;

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  late Future<String> _content;

  @override
  void initState() {
    super.initState();
    _content = rootBundle.loadString(widget.type.assetPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.type.title)),
      body: FutureBuilder<String>(
        future: _content,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Could not load document: ${snapshot.error}'),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: SelectableText(
              snapshot.data ?? '',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.55),
            ),
          );
        },
      ),
    );
  }
}
