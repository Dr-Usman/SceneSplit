import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/app_link_launcher.dart';
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

  MarkdownStyleSheet _styleSheet(ThemeData theme) {
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return MarkdownStyleSheet.fromTheme(theme).copyWith(
      h1: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
      h2: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      h3: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      p: textTheme.bodyMedium?.copyWith(height: 1.55),
      listBullet: textTheme.bodyMedium,
      blockquote: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontStyle: FontStyle.italic,
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.primary, width: 3)),
      ),
      blockquotePadding: const EdgeInsets.fromLTRB(12, 4, 0, 4),
      tableHead: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      tableBody: textTheme.bodyMedium,
      tableBorder: TableBorder.all(color: colorScheme.outlineVariant),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      a: textTheme.bodyMedium?.copyWith(
        color: AppColors.primary,
        decoration: TextDecoration.underline,
      ),
      strong: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
      em: textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Could not load document: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return Markdown(
            data: snapshot.data ?? '',
            selectable: true,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            styleSheet: _styleSheet(theme),
            onTapLink: (text, href, title) {
              if (href != null) {
                launchExternalUrl(href);
              }
            },
          );
        },
      ),
    );
  }
}
