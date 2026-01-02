import 'package:flutter/material.dart';
import '../main.dart';

/// Important Prayers screen
/// Displays important prayers in selected language
class PrayersScreen extends StatelessWidget {
  const PrayersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = languageService.getCurrentLanguage();
    final prayers = prayersService.getPrayers(language);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Important Prayers'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Important Prayers',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            prayers.isEmpty
                ? Text(
                    'Content not available in selected language.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                : Text(
                    prayers,
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
