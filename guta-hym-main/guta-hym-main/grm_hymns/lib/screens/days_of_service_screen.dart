import 'package:flutter/material.dart';
import '../main.dart';

/// Days of Service screen
/// Displays the days and times of service in selected language
class DaysOfServiceScreen extends StatelessWidget {
  const DaysOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = languageService.getCurrentLanguage();
    final daysOfService = daysOfServiceService.getDaysOfService(language);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Days of Service'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Days of Service',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            daysOfService.isEmpty
                ? Text(
                    'Content not available in selected language.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                : Text(
                    daysOfService,
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
