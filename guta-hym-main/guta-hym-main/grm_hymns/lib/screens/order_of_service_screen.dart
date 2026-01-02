import 'package:flutter/material.dart';
import '../main.dart';

/// Order of Service screen
/// Displays the order of service content in selected language
class OrderOfServiceScreen extends StatelessWidget {
  const OrderOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = languageService.getCurrentLanguage();
    final orderOfService = orderOfServiceService.getOrderOfService(language);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order of Service'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order of Service',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            orderOfService.isEmpty
                ? Text(
                    'Content not available in selected language.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                : Text(
                    orderOfService,
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
