import 'dart:convert';
import 'package:flutter/services.dart';

/// Service for loading Order of Service (Matakurirwo eBasa) content.
/// Content is stored offline in assets/data/matakurirwo_ebasa.json
/// Content changes based on selected hymn language.
class MatakurirwoService {
  late Map<String, dynamic> _matakurirwoData = {};

  /// Load Matakurirwo eBasa content from JSON asset
  Future<void> loadMatakurirwo() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/matakurirwo_ebasa.json',
      );
      _matakurirwoData = jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      // Fallback: return empty map if asset not found
      _matakurirwoData = {};
    }
  }

  /// Get Matakurirwo content in specified language
  /// language: 'shona', 'ndebele', or 'tswana'
  String getMatakurirwo(String language) {
    final lang = language.toLowerCase();
    return _matakurirwoData[lang] as String? ?? '';
  }

  /// Get all available language keys
  List<String> getAvailableLanguages() {
    return _matakurirwoData.keys.toList();
  }
}
