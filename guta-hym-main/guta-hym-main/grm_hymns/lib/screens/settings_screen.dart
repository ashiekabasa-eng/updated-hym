import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';

/// Settings screen - allows user to customize app experience.
/// Currently supports:
/// - Dark mode / Light mode toggle
class SettingsScreen extends StatefulWidget {
  final VoidCallback onThemeChanged;

  const SettingsScreen({super.key, required this.onThemeChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = themeService.isDarkMode();

    Future<void> _sendFeedback() async {
      final uri = Uri(
        scheme: 'mailto',
        path: 'nyotabis@gmail.com',
        queryParameters: {
          'subject': 'Feedback for GUTA RA MWARI',
        },
      );
      if (!await launchUrl(uri)) {
        // Fallback to opening Gmail web compose as last resort
        final web = Uri.parse(
            'https://mail.google.com/mail/?view=cm&fs=1&to=nyotabis%40gmail.com&su=${Uri.encodeComponent('Feedback for GUTA RA MWARI')}');
        if (!await launchUrl(web, mode: LaunchMode.externalApplication)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open email app')),
            );
          }
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Theme', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: isDarkMode,
                onChanged: (_) async {
                  await themeService.toggleTheme();
                  widget.onThemeChanged();
                  setState(() {});
                },
              ),
            ),
            const Divider(),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Send feedback'),
              subtitle: const Text('Send app feedback via email'),
              onTap: _sendFeedback,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
