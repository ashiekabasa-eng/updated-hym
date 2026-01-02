import 'package:shared_preferences/shared_preferences.dart';

/// Manages language selection and persistence across app sessions.
/// On first launch, prompts user to select hymn language (Shona, Ndebele, Tswana).
/// User can change language later from Settings.
class LanguageService {
  static const String _languageKey = 'hymn_language';
  static const String _firstLaunchKey = 'app_first_launch';
  static const String defaultLanguage = 'shona';

  late SharedPreferences _prefs;
  String _currentLanguage = defaultLanguage;
  bool _isFirstLaunch = true;

  /// Initialize the language service with SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _isFirstLaunch = _prefs.getBool(_firstLaunchKey) ?? true;
    _currentLanguage = _prefs.getString(_languageKey) ?? defaultLanguage;
  }

  /// Get current selected hymn language
  String getCurrentLanguage() => _currentLanguage;

  /// Check if this is the first app launch
  bool isFirstLaunch() => _isFirstLaunch;

  /// Set hymn language and persist it
  Future<void> setLanguage(String language) async {
    _currentLanguage = language;
    await _prefs.setString(_languageKey, language);
  }

  /// Mark first launch as complete
  Future<void> markFirstLaunchComplete() async {
    _isFirstLaunch = false;
    await _prefs.setBool(_firstLaunchKey, false);
  }

  /// Get all available languages
  List<String> getAvailableLanguages() => ['shona', 'ndebele', 'tswana'];

  /// Get display name for a language code
  String getLanguageDisplayName(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'ndebele':
        return 'Ndebele';
      case 'tswana':
        return 'Tswana';
      case 'shona':
      default:
        return 'Shona';
    }
  }
}
