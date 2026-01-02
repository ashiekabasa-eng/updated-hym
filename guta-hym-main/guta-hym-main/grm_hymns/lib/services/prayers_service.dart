import 'dart:convert';
import 'package:flutter/services.dart';

/// Service for loading Important Prayers content
/// Content is stored offline in assets/data/prayers.json
class PrayersService {
  late Map<String, dynamic> _prayersData = {};

  /// Load Prayers content from JSON asset
  Future<void> loadPrayers() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/prayers.json');
      _prayersData = jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      _prayersData = {};
    }
  }

  /// Get Prayers content in specified language
  String getPrayers(String language) {
    final lang = language.toLowerCase();
    final langData = _prayersData[lang];

    // If langData is a Map (multiple prayer sections), combine them
    if (langData is Map<String, dynamic>) {
      final prayersList = <String>[];
      langData.forEach((key, value) {
        if (value is String) {
          prayersList.add(value);
        }
      });
      return prayersList.join('\n\n---\n\n');
    }

    // If it's a String, return it directly
    if (langData is String) {
      return langData;
    }

    return '';
  }
}
