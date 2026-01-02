import 'package:flutter/material.dart';
import '../main.dart';

/// Important Conferences screen (Zvimiso)
/// Displays important church conferences in selected language
class ZvimsoScreen extends StatelessWidget {
  const ZvimsoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = languageService.getCurrentLanguage();
    final zvimso = zvimsoService.getZvimso(language);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Important Conferences'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Important Conferences in Guta ra Mwari',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            zvimso.isEmpty
                ? Text(
                    'Content not available in selected language.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                : Text(
                    zvimso,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.8,
                        ),
                  ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
