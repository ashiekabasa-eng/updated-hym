import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/hymn.dart';

/// Service for loading and managing hymns from local JSON asset.
/// All hymns are stored offline in assets/data/hymns.json
class HymnService {
  late List<Hymn> _hymns = [];

  /// Load all hymns from JSON asset file
  Future<void> loadHymns() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/hymns.json');
      final jsonData = jsonDecode(jsonString) as List<dynamic>;
      _hymns = jsonData
          .map((item) => Hymn.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Fallback: return empty list if asset not found
      _hymns = [];
    }
  }

  /// Get all hymns
  List<Hymn> getAllHymns() => _hymns;

  /// Get a single hymn by number
  Hymn? getHymnByNumber(int number) {
    try {
      return _hymns.firstWhere((hymn) => hymn.number == number);
    } catch (e) {
      return null;
    }
  }

  /// Search hymns by title or number in specified language
  /// Searches are case-insensitive
  List<Hymn> searchHymns(String query, String language) {
    if (query.isEmpty) return _hymns;

    final lowerQuery = query.toLowerCase();

    return _hymns.where((hymn) {
      final title = hymn.getTitle(language).toLowerCase();
      final numberStr = hymn.number.toString();
      return title.contains(lowerQuery) || numberStr.contains(lowerQuery);
    }).toList();
  }

  /// Get total number of hymns
  int getHymnCount() => _hymns.length;
}
