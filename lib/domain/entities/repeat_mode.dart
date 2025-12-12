/// Repeat mode for playback
///
/// This enum is shared between playback state and focus session settings
/// to avoid duplication and type conversion issues.
enum RepeatMode {
  /// No repeat - stop after playlist ends
  off,

  /// Repeat the entire context (playlist/album)
  context,

  /// Repeat the current track
  track,
}
