import 'package:flutter/material.dart';
import '../main.dart';
import 'hymn_list_screen.dart';
import 'zvimiso_screen.dart';
import 'order_of_service_screen.dart';
import 'days_of_service_screen.dart';
import 'prayers_screen.dart';
import 'settings_screen.dart';
import 'about_screen.dart';
import 'language_selection_screen.dart';
import 'notes_screen.dart';

/// Home screen - displays the current hymn with swipe navigation.
/// User can swipe left/right to navigate between hymns.
/// Also contains main navigation drawer with access to:
/// - Hymns (list view)
/// - Important Conferences (Zvimiso)
/// - Order of Service
/// - Days of Service
/// - Important Prayers
/// - Change Hymn Language
/// - Settings
/// - About
class HomeScreen extends StatefulWidget {
  final VoidCallback onThemeChanged;

  const HomeScreen({super.key, required this.onThemeChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentHymnNumber;

  @override
  void initState() {
    super.initState();
    _currentHymnNumber = 1;
  }

  @override
  Widget build(BuildContext context) {
    final language = languageService.getCurrentLanguage();
    final hymn = hymnService.getHymnByNumber(_currentHymnNumber);

    // Show empty state with hymn number placeholder if no hymns yet
    if (hymn == null && hymnService.getHymnCount() == 0) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.note_add),
              tooltip: 'Daily Notes',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        NotesScreen(notesService: notesService),
                  ),
                );
              },
            ),
          ],
        ),
        drawer: _buildDrawer(context),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.note_add),
            tooltip: 'Daily Notes',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotesScreen(notesService: notesService),
                ),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: hymn == null
          ? Center(
              child: Text(
                'Hymn not found',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          : GestureDetector(
              onHorizontalDragEnd: (details) {
                // Swipe left - next hymn
                if (details.primaryVelocity! < 0) {
                  _nextHymn();
                }
                // Swipe right - previous hymn
                else if (details.primaryVelocity! > 0) {
                  _previousHymn();
                }
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hymn number and swipe hint
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${hymn.number}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          'Swipe next',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Hymn title
                    Text(
                      hymn.getTitle(language),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 32),

                    // Hymn lyrics
                    Text(
                      hymn.getLyrics(language),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 18,
                            height: 2.0,
                          ),
                    ),
                    const SizedBox(height: 32),

                    // Navigation indicators
                    Center(
                      child: Text(
                        '$_currentHymnNumber / ${hymnService.getHymnCount()}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _nextHymn() {
    setState(() {
      if (_currentHymnNumber < hymnService.getHymnCount()) {
        _currentHymnNumber++;
      } else {
        // Loop back to first hymn
        _currentHymnNumber = 1;
      }
    });
  }

  void _previousHymn() {
    setState(() {
      if (_currentHymnNumber > 1) {
        _currentHymnNumber--;
      } else {
        // Loop back to last hymn
        _currentHymnNumber = hymnService.getHymnCount();
      }
    });
  }

  /// Build navigation drawer with menu items
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer header with app logo prominently displayed
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.white),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Hymns
          ListTile(
            leading: const Icon(Icons.library_books),
            title: const Text('Hymns'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HymnListScreen()),
              );
            },
          ),

          const Divider(),

          // Important Conferences (Zvimiso)
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Important Conferences'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ZvimsoScreen()),
              );
            },
          ),

          const Divider(),

          // Order of Service
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Order of Service'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrderOfServiceScreen()),
              );
            },
          ),

          const Divider(),

          // Days of Service
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Days of Service'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DaysOfServiceScreen()),
              );
            },
          ),

          const Divider(),

          // Important Prayers
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Important Prayers'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrayersScreen()),
              );
            },
          ),

          const Divider(),

          // Change Hymn Language
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Change Hymn Language'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LanguageSelectionScreen(
                    onLanguageChanged: () {
                      setState(() {});
                    },
                  ),
                ),
              );
            },
          ),

          const Divider(),

          // Settings
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      SettingsScreen(onThemeChanged: widget.onThemeChanged),
                ),
              );
            },
          ),

          const Divider(),

          // About
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
