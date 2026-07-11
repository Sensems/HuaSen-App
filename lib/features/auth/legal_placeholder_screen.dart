import 'package:flutter/material.dart';

import '../../core/constants/ui_strings.dart';

/// Minimal placeholder for user agreement / privacy policy.
class LegalPlaceholderScreen extends StatelessWidget {
  const LegalPlaceholderScreen({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          UiStrings.legalPlaceholderBody,
          style: theme.textTheme.bodyLarge,
        ),
      ),
    );
  }
}
