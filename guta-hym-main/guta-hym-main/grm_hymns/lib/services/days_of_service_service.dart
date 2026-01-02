import 'dart:convert';
import 'package:flutter/services.dart';

/// Service for loading Days of Service content
/// Content is stored offline in assets/data/days_of_service.json
class DaysOfServiceService {
  late Map<String, dynamic> _daysData = {};

  /// Load Days of Service content from JSON asset
  Future<void> loadDaysOfService() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/days_of_service.json');
      _daysData = jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      _daysData = {};
    }
  }

  /// Get Days of Service content in specified language
  String getDaysOfService(String language) {
    final lang = language.toLowerCase();
    return _daysData[lang] as String? ?? '';
  }
}
