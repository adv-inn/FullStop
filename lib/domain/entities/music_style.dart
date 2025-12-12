/// Represents a music style based on BPM range
enum MusicStyle {
  slow, // 60-80 BPM: 慢板，抒情、悲伤、慵懒
  midTempo, // 90-110 BPM: 中速，轻松、律动、R&B
  upTempo, // 120-140 BPM: 快板，活力、流行、House
  fast, // 150+ BPM: 极速，摇滚、金属、Drum&Bass
}

extension MusicStyleExtension on MusicStyle {
  /// Get the BPM range for this style
  (int min, int max) get bpmRange {
    switch (this) {
      case MusicStyle.slow:
        return (60, 80);
      case MusicStyle.midTempo:
        return (90, 110);
      case MusicStyle.upTempo:
        return (120, 140);
      case MusicStyle.fast:
        return (150, 200);
    }
  }

  /// Check if a given BPM matches this style (with some tolerance)
  bool matchesBpm(double bpm) {
    final range = bpmRange;
    // Allow 5 BPM tolerance on each side
    return bpm >= (range.$1 - 5) && bpm <= (range.$2 + 5);
  }

  /// Get the icon for this style
  String get icon {
    switch (this) {
      case MusicStyle.slow:
        return '🌙';
      case MusicStyle.midTempo:
        return '☕';
      case MusicStyle.upTempo:
        return '🎉';
      case MusicStyle.fast:
        return '🔥';
    }
  }
}
