import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/focus_session.dart';

abstract class FocusSessionRepository {
  /// Get all saved focus sessions
  Future<Either<Failure, List<FocusSession>>> getAllSessions();

  /// Get a focus session by ID
  Future<Either<Failure, FocusSession>> getSession(String sessionId);

  /// Create a new focus session
  Future<Either<Failure, FocusSession>> createSession(FocusSession session);

  /// Update an existing focus session
  Future<Either<Failure, FocusSession>> updateSession(FocusSession session);

  /// Delete a focus session
  Future<Either<Failure, void>> deleteSession(String sessionId);

  /// Get recent sessions
  Future<Either<Failure, List<FocusSession>>> getRecentSessions({
    int limit = 5,
  });

  /// Update last played timestamp
  Future<Either<Failure, void>> updateLastPlayed(String sessionId);

  /// Get the maximum sortOrder value among all sessions
  Future<int> getMaxSortOrder();

  /// Get the minimum sortOrder value among all sessions
  Future<int> getMinSortOrder();

  /// Get the count of pinned sessions
  Future<int> getPinnedCount();

  /// Get the persisted active session ID
  Future<String?> getActiveSessionId();

  /// Save the active session ID (persists across app restarts)
  Future<void> saveActiveSessionId(String? sessionId);

  /// Get the track URIs of the active session for queue validation
  Future<List<String>?> getActiveSessionTrackUris();

  /// Save the track URIs of the active session
  Future<void> saveActiveSessionTrackUris(List<String> trackUris);
}
