import 'package:flutter/material.dart';
import '../main.dart';
import 'hymn_detail_screen.dart';

/// Hymn list screen - displays all hymns in the hymnbook.
/// Features:
/// - Numbered list of hymns with titles in selected language
/// - Real-time search by hymn number or title
/// - Tap to view hymn details
class HymnListScreen extends StatefulWidget {
  const HymnListScreen({super.key});

  @override
  State<HymnListScreen> createState() => _HymnListScreenState();
}

class _HymnListScreenState extends State<HymnListScreen> {
  late TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = languageService.getCurrentLanguage();
    final allHymns = hymnService.getAllHymns();
    final filteredHymns = hymnService.searchHymns(_searchQuery, language);

    return Scaffold(
      appBar: AppBar(title: const Text('Hymns'), elevation: 0),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by hymn number or title',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Hymn count info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Total hymns: ${allHymns.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),

          // Hymn list
          Expanded(
            child: filteredHymns.isEmpty
                ? Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'No hymns found'
                          : 'No hymns match your search',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredHymns.length,
                    itemBuilder: (context, index) {
                      final hymn = filteredHymns[index];
                      final title = hymn.getTitle(language);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              const Color.fromARGB(255, 231, 50, 47),
                          foregroundColor: Colors.white,
                          child: Text('${hymn.number}'),
                        ),
                        title: Text(title),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HymnDetailScreen(hymn: hymn),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
