import 'package:flutter/material.dart';
import '../main.dart';
import 'home_screen.dart';

/// Welcome screen shown only on first app launch.
/// Prompts user to select their preferred hymn language
/// (Shona, Ndebele, or Tswana).
/// This choice is saved locally and affects all hymn content.
class WelcomeScreen extends StatelessWidget {
  final VoidCallback onLanguageSelected;

  const WelcomeScreen({super.key, required this.onLanguageSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo
              Image.asset(
                'assets/images/icon.png',
                height: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 32),

              // Instruction text
              Text(
                'Choose Hymn Language',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Select the language for hymn titles and lyrics',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Language selection buttons
              _LanguageButton(
                language: 'shona',
                displayName: 'Shona',
                onTap: () => _selectLanguage(context, 'shona'),
              ),
              const SizedBox(height: 16),
              _LanguageButton(
                language: 'ndebele',
                displayName: 'Ndebele',
                onTap: () => _selectLanguage(context, 'ndebele'),
              ),
              const SizedBox(height: 16),
              _LanguageButton(
                language: 'tswana',
                displayName: 'Tswana',
                onTap: () => _selectLanguage(context, 'tswana'),
              ),
              const SizedBox(height: 48),

              // Info text
              Text(
                'You can change this language later in Settings',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handle language selection
  void _selectLanguage(BuildContext context, String language) async {
    await languageService.setLanguage(language);
    await languageService.markFirstLaunchComplete();

    // Navigate to home screen
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => HomeScreen(onThemeChanged: () {}),
        ),
        (route) => false,
      );
    }
  }
}

/// Language selection button widget
class _LanguageButton extends StatelessWidget {
  final String language;
  final String displayName;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.language,
    required this.displayName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE53935), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.language, color: Colors.black),
            const SizedBox(width: 12),
            Text(
              displayName,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
