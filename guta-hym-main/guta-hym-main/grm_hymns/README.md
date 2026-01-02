# GUTA RA MWARI HYM Book
**Offline Android Hymnbook Application**

A production-ready Flutter application designed for church use, providing offline access to hymns in multiple languages (Shona, Ndebele, Tswana) with an elegant, user-friendly interface.

---

## ✨ Features

- **Offline-First**: All hymns and content stored locally — no internet required
- **Multilingual**: Hymns available in Shona, Ndebele, and Tswana
- **Language Selection**: User selects preferred hymn language on first launch
- **Hymn Search**: Search by hymn number or title in real-time
- **Order of Service**: Matakurirwo eBasa content in selected language
- **Material 3 Design**: Modern, clean, church-appropriate UI
- **Dark Mode**: Full dark/light theme support
- **Local Persistence**: Language and theme preferences saved across sessions

---

## 📱 App Structure

```
grm_hymns/
├── lib/
│   ├── main.dart                          # App entry point & theme setup
│   ├── models/
│   │   └── hymn.dart                      # Hymn data model
│   ├── services/
│   │   ├── language_service.dart          # Language selection & persistence
│   │   ├── theme_service.dart             # Dark/light mode management
│   │   ├── hymn_service.dart              # Hymn loading & searching
│   │   └── matakurirwo_service.dart       # Order of service management
│   └── screens/
│       ├── welcome_screen.dart            # First launch language selection
│       ├── home_screen.dart               # Main navigation hub
│       ├── hymn_list_screen.dart          # Hymn list with search
│       ├── hymn_detail_screen.dart        # Full hymn display
│       ├── matakurirwo_screen.dart        # Order of service
│       ├── language_selection_screen.dart # Change hymn language
│       ├── settings_screen.dart           # App settings
│       └── about_screen.dart              # App information
├── assets/
│   └── data/
│       ├── hymns.json                     # All hymn data (11 hymns)
│       └── matakurirwo_ebasa.json         # Order of service content
├── pubspec.yaml                           # Dependencies
└── analysis_options.yaml                  # Linting rules
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter 3.0.0 or higher
- Android SDK (for Android build)
- A terminal/command line

### Installation

1. **Clone/Open the project**
   ```bash
   cd grm_hymns
   ```

2. **Get dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

---

## 📝 Navigation Structure

### Home Screen
- Welcome message
- Drawer navigation

### Drawer Menu (in order)
1. **Hymns** → Browse and search all hymns
2. **Matakurirwo eBasa** → View order of service
3. **Change Hymn Language** → Switch between Shona/Ndebele/Tswana
4. **Settings** → Dark mode toggle
5. **About** → App info and offline notice

---

## 🔧 Customization

### Adding Hymn Content

Edit [assets/data/hymns.json](assets/data/hymns.json):

```json
{
  "number": 1,
  "titleShona": "Hymn Title in Shona",
  "titleNdebele": "Hymn Title in Ndebele",
  "titleTswana": "Hymn Title in Tswana",
  "lyricsShona": "Full lyrics in Shona...",
  "lyricsNdebele": "Full lyrics in Ndebele...",
  "lyricsTswana": "Full lyrics in Tswana..."
}
```

### Adding Order of Service Content

Edit [assets/data/matakurirwo_ebasa.json](assets/data/matakurirwo_ebasa.json):

```json
{
  "shona": "Order of service content in Shona...",
  "ndebele": "Order of service content in Ndebele...",
  "tswana": "Order of service content in Tswana..."
}
```

### Changing App Branding

Edit [lib/main.dart](lib/main.dart):
- `title`: App display name
- `colorScheme`: Primary color (currently `#6C5CE7`)
- Theme colors in `_buildLightTheme()` and `_buildDarkTheme()`

---

## 🎨 Theme Customization

Light theme uses `#6C5CE7` (purple) as the primary color.
Dark theme uses a darker shade for consistency.

All theme colors are defined in [lib/main.dart](lib/main.dart) `_buildLightTheme()` and `_buildDarkTheme()`.

---

## 📦 Dependencies

- **shared_preferences**: Local data persistence (language, theme)
- **flutter_localizations**: Material Design 3 localization support

---

## 🏗️ Build for APK

```bash
# Build release APK
flutter build apk --release

# APK location: build/app/outputs/flutter-apk/app-release.apk
```

---

## 🔐 Data Persistence

The app uses `shared_preferences` for offline storage:
- **Hymn Language**: Saved on first launch, changeable anytime
- **Theme Mode**: Toggled in Settings, persisted across sessions
- **All hymns & content**: Loaded from JSON assets (offline)

---

## ✅ Quality Standards

✓ Production-ready code  
✓ No demo features or placeholders  
✓ Clean Material 3 design  
✓ Church-appropriate UX  
✓ Comprehensive offline support  
✓ Full dark/light theme support  

---

## 📜 Version

**1.0.0** — Initial release for church distribution

---

## 📞 Support

For technical issues or feature requests, please contact the development team.

---

**Built with ❤️ for the church community.**
