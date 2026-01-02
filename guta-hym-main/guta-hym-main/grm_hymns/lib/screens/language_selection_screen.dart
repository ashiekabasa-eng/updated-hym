import 'package:flutter/material.dart';
import '../main.dart';

/// Language selection screen - allows user to change hymn language.
/// User can switch between Shona, Ndebele, and Tswana at any time.
/// Selection is saved locally and affects hymn titles and lyrics.
class LanguageSelectionScreen extends StatefulWidget {
  final VoidCallback onLanguageChanged;

  const LanguageSelectionScreen({super.key, required this.onLanguageChanged});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = languageService.getCurrentLanguage();
  }

  @override
  Widget build(BuildContext context) {
    final availableLanguages = languageService.getAvailableLanguages();

    return Scaffold(
      appBar: AppBar(title: const Text('Change Hymn Language'), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select language for hymn titles and lyrics',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ...availableLanguages.map((language) {
              final displayName = languageService.getLanguageDisplayName(
                language,
              );
              final isSelected = _selectedLanguage == language;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: GestureDetector(
                  onTap: () async {
                    setState(() {
                      _selectedLanguage = language;
                    });
                    await languageService.setLanguage(language);
                    widget.onLanguageChanged();

                    // Show confirmation
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Language changed to $displayName'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFE53935)
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected
                          ? const Color(0xFFE53935).withValues(alpha: 0.1)
                          : Colors.transparent,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.language),
                            const SizedBox(width: 12),
                            Text(
                              displayName,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.black,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
