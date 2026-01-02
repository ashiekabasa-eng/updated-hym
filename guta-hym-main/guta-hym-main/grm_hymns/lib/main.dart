import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'services/language_service.dart';
import 'services/theme_service.dart';
import 'services/hymn_service.dart';
import 'services/zvimso_service.dart';
import 'services/order_of_service_service.dart';
import 'services/days_of_service_service.dart';
import 'services/prayers_service.dart';
import 'services/notes_service.dart';

final languageService = LanguageService();
final themeService = ThemeService();
final hymnService = HymnService();
final zvimsoService = ZvimsoService();
final orderOfServiceService = OrderOfServiceService();
final daysOfServiceService = DaysOfServiceService();
final prayersService = PrayersService();
final notesService = NotesService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize only critical services (language & theme are instant)
  await languageService.init();
  await themeService.init();

  // Load hymns first (blocking but necessary)
  try {
    await hymnService.loadHymns();
  } catch (e) {
    print('Error loading hymns: $e');
  }

  // Load all other services in background (non-blocking)
  _loadAllServices();

  runApp(const GutaRaMwariApp());
}

/// Load all services in the background (non-blocking)
void _loadAllServices() {
  // Load in parallel to maximize speed
  zvimsoService.loadZvimso();
  orderOfServiceService.loadOrderOfService();
  daysOfServiceService.loadDaysOfService();
  prayersService.loadPrayers();
  notesService.initialize();
}

class GutaRaMwariApp extends StatefulWidget {
  const GutaRaMwariApp({super.key});

  @override
  State<GutaRaMwariApp> createState() => _GutaRaMwariAppState();
}

class _GutaRaMwariAppState extends State<GutaRaMwariApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = themeService.getThemeMode();
  }

  /// Update theme when changed from Settings
  void _onThemeChanged() {
    setState(() {
      _themeMode = themeService.getThemeMode();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GUTA RA MWARI HYM Book',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      home: languageService.isFirstLaunch()
          ? WelcomeScreen(
              onLanguageSelected: () {
                setState(() {});
              },
            )
          : HomeScreen(onThemeChanged: _onThemeChanged),
    );
  }

  /// Build Material 3 light theme
  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFE53935),
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFE53935),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      scaffoldBackgroundColor: Colors.white,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.black87, height: 1.6),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
      ),
    );
  }

  /// Build Material 3 dark theme
  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFE53935),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFD32F2F),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.white70, height: 1.6),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.white54),
      ),
    );
  }
}
