import 'package:flutter/material.dart';
import '../models/hymn.dart';
import '../main.dart';

/// Hymn detail screen - displays full hymn with all verses.
/// Features:
/// - Hymn number and title in header
/// - Scrollable lyrics with large, readable font (church-friendly)
/// - Proper verse separation
/// - Comfortable reading spacing
class HymnDetailScreen extends StatelessWidget {
  final Hymn hymn;

  const HymnDetailScreen({super.key, required this.hymn});

  @override
  Widget build(BuildContext context) {
    final language = languageService.getCurrentLanguage();
    final title = hymn.getTitle(language);
    final lyrics = hymn.getLyrics(language);

    return Scaffold(
      appBar: AppBar(title: Text('#${hymn.number} $title'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hymn header
            Text(
              '${hymn.number}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 32),

            // Hymn lyrics
            // Verses are separated by blank lines for readability
            Text(
              lyrics,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontSize: 18, height: 2.0),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
