import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

/// Model for a note entry
class Note {
  final String id; // Unique identifier
  final DateTime date; // day-only date
  final String content; // encrypted or plain depending on isEncrypted
  final bool isEncrypted;
  final String title;

  Note({
    String? id,
    required this.date,
    required this.content,
    this.isEncrypted = false,
    this.title = '',
  }) : id = id ?? _generateId();

  static String _generateId() =>
      DateTime.now().microsecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'content': content,
        'isEncrypted': isEncrypted,
        'title': title,
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'] as String?,
        date: DateTime.parse(json['date'] as String),
        content: json['content'] as String,
        isEncrypted: json['isEncrypted'] as bool? ?? false,
        title: json['title'] as String? ?? '',
      );
}

/// Notes service with PIN + simple encryption.
///
/// CRITICAL FIXES:
/// - Updates notes IN-PLACE (no remove+add reorder bug)
/// - Stable sort: date DESC, id DESC (keeps list stable for same-day notes)
/// - saveNote supports optional date (so UI can save to picked day)
class NotesService {
  static const String _notesPrefsKey = 'grm_notes';
  static const String _pinPrefsKey = 'grm_notes_pin';
  static const String _encryptionEnabledKey = 'grm_notes_encryption_enabled';

  SharedPreferences? _prefs;
  final List<Note> _notes = [];

  String _pin = ''; // hashed PIN
  bool _isEncryptionEnabled = false;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _loadPin();
    _loadEncryptionStatus();
    _loadNotes();
    _initialized = true;
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) await initialize();
  }

  DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  int _indexOfNote(String id) => _notes.indexWhere((n) => n.id == id);

  void _loadPin() {
    if (_prefs == null) return;
    _pin = _prefs!.getString(_pinPrefsKey) ?? '';
  }

  void _loadEncryptionStatus() {
    if (_prefs == null) return;
    _isEncryptionEnabled = _prefs!.getBool(_encryptionEnabledKey) ?? false;
  }

  void _loadNotes() {
    if (_prefs == null) return;
    final list = _prefs!.getStringList(_notesPrefsKey) ?? [];
    _notes
      ..clear()
      ..addAll(list.map((s) => Note.fromJson(jsonDecode(s))));
  }

  Future<void> _saveNotesToPrefs() async {
    await _ensureInitialized();
    if (_prefs == null) return;
    final list = _notes.map((n) => jsonEncode(n.toJson())).toList();
    await _prefs!.setStringList(_notesPrefsKey, list);
  }

  // ---------- PIN ----------
  Future<void> setPin(String newPin) async {
    await _ensureInitialized();
    if (_prefs == null) return;
    _pin = _hashPin(newPin);
    await _prefs!.setString(_pinPrefsKey, _pin);
  }

  bool verifyPin(String pin) => _pin.isEmpty || _pin == _hashPin(pin);

  bool isPinSet() => _pin.isNotEmpty;

  // ---------- Global encryption toggle ----------
  Future<void> setEncryption(bool enabled) async {
    await _ensureInitialized();
    if (_prefs == null) return;

    // Do not allow "enabled" without a PIN
    if (enabled && _pin.isEmpty) {
      _isEncryptionEnabled = false;
      await _prefs!.setBool(_encryptionEnabledKey, false);
      return;
    }

    _isEncryptionEnabled = enabled;
    await _prefs!.setBool(_encryptionEnabledKey, enabled);
  }

  bool isEncryptionEnabled() => _isEncryptionEnabled;

  // ---------- Save ----------
  /// Save a note.
  /// - If noteId exists -> update in-place
  /// - If date provided -> save for that day
  /// - Uses global encryption flag by default
  Future<void> saveNote(
    String content, {
    String title = '',
    String? noteId,
    DateTime? date,
  }) async {
    await _ensureInitialized();

    final d = _dayOnly(date ?? DateTime.now());
    final canEncrypt = _isEncryptionEnabled && _pin.isNotEmpty;
    final stored = canEncrypt ? _encryptContent(content) : content;

    if (noteId != null) {
      final idx = _indexOfNote(noteId);
      if (idx != -1) {
        final old = _notes[idx];
        _notes[idx] = Note(
          id: old.id,
          date: d,
          content: stored,
          isEncrypted: canEncrypt,
          title: title,
        );
        await _saveNotesToPrefs();
        return;
      }
    }

    _notes.add(Note(
      id: noteId,
      date: d,
      content: stored,
      isEncrypted: canEncrypt,
      title: title,
    ));

    await _saveNotesToPrefs();
  }

  /// Save a note with explicit encryption choice (used by lock/unlock).
  /// CRITICAL: updates in-place to avoid list reorder bugs.
  Future<void> saveNoteWithEncryption(
    DateTime date,
    String content,
    bool encrypt, {
    String title = '',
    String? noteId,
  }) async {
    await _ensureInitialized();

    final d = _dayOnly(date);
    final canEncrypt = encrypt && _pin.isNotEmpty;
    final stored = canEncrypt ? _encryptContent(content) : content;

    if (noteId != null) {
      final idx = _indexOfNote(noteId);
      if (idx != -1) {
        final old = _notes[idx];
        _notes[idx] = Note(
          id: old.id,
          date: d,
          content: stored,
          isEncrypted: canEncrypt,
          title: title,
        );
        await _saveNotesToPrefs();
        return;
      }
    }

    _notes.add(Note(
      id: noteId,
      date: d,
      content: stored,
      isEncrypted: canEncrypt,
      title: title,
    ));

    await _saveNotesToPrefs();
  }

  // ---------- Get ----------
  List<Note> getAllNotes() {
    final copy = List<Note>.from(_notes);
    copy.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      if (byDate != 0) return byDate;
      // For same-day notes, keep stable order by id desc
      return b.id.compareTo(a.id);
    });
    return copy;
  }

  List<Note> getTodayNotes() => getNotesByDate(DateTime.now());

  Note? getNoteByDate(DateTime date) {
    final target = _dayOnly(date);
    for (final n in _notes) {
      if (_dayOnly(n.date) == target) return n;
    }
    return null;
  }

  List<Note> getNotesByDate(DateTime date) {
    final target = _dayOnly(date);
    final list = _notes.where((n) => _dayOnly(n.date) == target).toList();
    list.sort((a, b) => b.id.compareTo(a.id));
    return list;
  }

  Note? getNoteById(String id) {
    for (final n in _notes) {
      if (n.id == id) return n;
    }
    return null;
  }

  // ---------- Delete ----------
  Future<void> deleteNote(String noteId) async {
    await _ensureInitialized();
    _notes.removeWhere((n) => n.id == noteId);
    await _saveNotesToPrefs();
  }

  Future<void> deleteNotesForDate(DateTime date) async {
    await _ensureInitialized();
    final target = _dayOnly(date);
    _notes.removeWhere((n) => _dayOnly(n.date) == target);
    await _saveNotesToPrefs();
  }

  // ---------- Decrypt ----------
  String decryptNoteContent(Note note) {
    if (!note.isEncrypted) return note.content;
    return _decryptContent(note.content);
  }

  // ---------- Crypto ----------
  String _encryptContent(String content) {
    if (_pin.isEmpty) return content;
    final keyBytes = _pin.codeUnits; // hashed pin as key
    final bytes = utf8.encode(content);
    final out = <int>[];
    for (int i = 0; i < bytes.length; i++) {
      out.add(bytes[i] ^ keyBytes[i % keyBytes.length]);
    }
    return base64Encode(out);
  }

  String _decryptContent(String encryptedContent) {
    if (_pin.isEmpty) return encryptedContent;
    try {
      final keyBytes = _pin.codeUnits;
      final bytes = base64Decode(encryptedContent);
      final out = <int>[];
      for (int i = 0; i < bytes.length; i++) {
        out.add(bytes[i] ^ keyBytes[i % keyBytes.length]);
      }
      return utf8.decode(out);
    } catch (_) {
      return encryptedContent;
    }
  }

  String _hashPin(String pin) => sha256.convert(utf8.encode(pin)).toString();
}
