import 'package:flutter/material.dart';

/// About screen - displays app information.
/// Shows:
/// - App name
/// - Version
/// - Offline notice
/// - General church hymnal information
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App header
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'GUTA RA MWARI',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'HYM Book',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.black,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // App information
            _InfoSection(
              title: 'Version',
              content: '1.0.0',
              icon: Icons.info_outline,
              context: context,
            ),
            const SizedBox(height: 24),

            _InfoSection(
              title: 'Languages',
              content: 'Hymns available in Shona, Ndebele, and Tswana.',
              icon: Icons.language,
              context: context,
            ),
            const SizedBox(height: 24),

            _InfoSection(
              title: 'Purpose',
              content:
                  'GUTA RA MWARI HYM Book is designed to provide church members with convenient access to hymns and service materials. Built for simplicity, elegance, and ease of use for the whole church community.',
              icon: Icons.church,
              context: context,
            ),
            const SizedBox(height: 32),

            // Footer
            Center(
              child: Column(
                children: [
                  Text(
                    '© 2026 GUTA RA MWARI\nAll rights reserved',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Developed by Bismark Nyota',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable info section widget
class _InfoSection extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final BuildContext context;

  const _InfoSection({
    required this.title,
    required this.content,
    required this.icon,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.black),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 36.0),
          child: Text(
            content,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
        ),
      ],
    );
  }
}
