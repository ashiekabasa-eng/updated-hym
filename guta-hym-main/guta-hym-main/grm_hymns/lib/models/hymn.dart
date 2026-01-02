/// Hymn model representing a single hymn in the hymnbook.
/// Each hymn contains translations in multiple languages (Shona, Ndebele, Tswana)
/// and can have multiple verses.
class Hymn {
  final int number;
  final String titleShona;
  final String titleNdebele;
  final String titleTswana;
  final String lyricsShona;
  final String lyricsNdebele;
  final String lyricsTswana;

  const Hymn({
    required this.number,
    required this.titleShona,
    required this.titleNdebele,
    required this.titleTswana,
    required this.lyricsShona,
    required this.lyricsNdebele,
    required this.lyricsTswana,
  });

  /// Get the title in the specified language
  /// language: 'shona', 'ndebele', or 'tswana'
  String getTitle(String language) {
    switch (language.toLowerCase()) {
      case 'ndebele':
        return titleNdebele;
      case 'tswana':
        return titleTswana;
      default:
        return titleShona;
    }
  }

  /// Get the lyrics in the specified language
  /// language: 'shona', 'ndebele', or 'tswana'
  String getLyrics(String language) {
    switch (language.toLowerCase()) {
      case 'ndebele':
        return lyricsNdebele;
      case 'tswana':
        return lyricsTswana;
      default:
        return lyricsShona;
    }
  }

  /// Factory constructor to create Hymn from JSON
  factory Hymn.fromJson(Map<String, dynamic> json) {
    return Hymn(
      number: json['number'] as int,
      titleShona: json['titleShona'] as String,
      titleNdebele: json['titleNdebele'] as String,
      titleTswana: json['titleTswana'] as String,
      lyricsShona: json['lyricsShona'] as String,
      lyricsNdebele: json['lyricsNdebele'] as String,
      lyricsTswana: json['lyricsTswana'] as String,
    );
  }

  /// Convert Hymn to JSON
  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'titleShona': titleShona,
      'titleNdebele': titleNdebele,
      'titleTswana': titleTswana,
      'lyricsShona': lyricsShona,
      'lyricsNdebele': lyricsNdebele,
      'lyricsTswana': lyricsTswana,
    };
  }
}
