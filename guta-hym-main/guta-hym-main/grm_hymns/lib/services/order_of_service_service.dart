import 'dart:convert';
import 'package:flutter/services.dart';

/// Service for loading Order of Service content
/// Content is stored offline in assets/data/order_of_service.json
class OrderOfServiceService {
  late Map<String, dynamic> _orderData = {};

  /// Load Order of Service content from JSON asset
  Future<void> loadOrderOfService() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/order_of_service.json');
      _orderData = jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      _orderData = {};
    }
  }

  /// Get Order of Service content in specified language
  String getOrderOfService(String language) {
    final lang = language.toLowerCase();
    return _orderData[lang] as String? ?? '';
  }
}
