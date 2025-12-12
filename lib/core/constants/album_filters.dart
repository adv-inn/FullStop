/// Album name filters for removing Live/Concert/Compilation albums
/// Supports multiple languages: English, Spanish, Chinese, Japanese, Korean
class AlbumFilters {
  const AlbumFilters._();

  /// Combined regex for detecting "dirty" albums (Live, Concert, Best Of, etc.)
  ///
  /// Uses word boundaries (\b) for English/Spanish to avoid false positives
  /// (e.g., "Alive" should not match "live")
  ///
  /// CJK characters don't use word boundaries as they don't have spaces
  static final RegExp _dirtyRegex = RegExp(
    // English patterns (with word boundaries)
    r'(\b(live|concert|in\s+concert|tour|best\s+of|greatest\s+hits|collection|anthology|compilation|unplugged|mtv\s+unplugged|the\s+essential|acoustic\s+live)\b)'
    // Spanish patterns (with word boundaries)
    r'|(\b(en\s+vivo|concierto|exitos|lo\s+mejor|colección|antología)\b)'
    // Chinese patterns (no word boundaries needed)
    r'|(现场|演唱会|精选|全记录|演唱會|精選)'
    // Japanese patterns (no word boundaries needed)
    r'|(ライブ|コンサート|ベスト|コレクション|アンソロジー)'
    // Korean patterns (no word boundaries needed)
    r'|(라이브|콘서트|베스트|컬렉션|히트|앤솔로지)',
    caseSensitive: false,
    unicode: true,
  );

  /// Check if an album name indicates it's a Live/Concert/Compilation album
  ///
  /// Returns true if the album should be filtered out (is "dirty")
  /// Returns false if the album is likely a studio album (is "clean")
  static bool isDirty(String albumName) {
    return _dirtyRegex.hasMatch(albumName);
  }

  /// Check if an album is a clean studio album
  ///
  /// Returns true if the album is likely a studio album
  /// Returns false if the album should be filtered out
  static bool isClean(String albumName) {
    return !isDirty(albumName);
  }

  /// Get list of all filter keywords (for debugging/display)
  static List<String> get filterKeywords => const [
    // English
    'Live', 'Concert', 'In Concert', 'Tour', 'Best Of', 'Greatest Hits',
    'Collection', 'Anthology', 'Compilation', 'Unplugged', 'MTV Unplugged',
    'The Essential', 'Acoustic Live',
    // Spanish
    'En Vivo', 'Concierto', 'Exitos', 'Lo Mejor', 'Colección', 'Antología',
    // Chinese (Simplified)
    '现场', '演唱会', '精选', '全记录',
    // Chinese (Traditional)
    '演唱會', '精選',
    // Japanese
    'ライブ', 'コンサート', 'ベスト', 'コレクション', 'アンソロジー',
    // Korean
    '라이브', '콘서트', '베스트', '컬렉션', '히트', '앤솔로지',
  ];
}
