import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';

/// Progress callback for BPM fetching
typedef BpmProgressCallback = void Function(int current, int total);

/// Repository for fetching BPM data from external services
abstract class BpmRepository {
  /// Get BPM for a song by title and artist name
  /// Returns the BPM value or a failure
  Future<Either<Failure, int>> getBpmForSong(String title, String artistName);

  /// Get BPM for multiple songs
  /// Returns a map of "title|artistName" -> BPM
  /// [onProgress] is called with the current and total number of songs processed
  Future<Either<Failure, Map<String, int>>> getBpmForSongs(
    List<({String title, String artistName})> songs, {
    BpmProgressCallback? onProgress,
  });
}
