import 'dart:convert';
import 'package:flutter/services.dart';

/// Service for loading Zvimiso (Important Conferences) content
/// Content is stored offline in assets/data/zvimiso.json
class ZvimsoService {
  late Map<String, dynamic> _zvimsoData = {};

  /// Load Zvimiso content from JSON asset
  Future<void> loadZvimso() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/zvimiso.json');
      _zvimsoData = jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      _zvimsoData = {};
    }
  }

  /// Get Zvimso content in specified language
  String getZvimso(String language) {
    final lang = language.toLowerCase();
    return _zvimsoData[lang] as String? ?? '';
  }
}
