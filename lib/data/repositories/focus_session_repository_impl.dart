import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/focus_session.dart';
import '../../domain/repositories/focus_session_repository.dart';
import '../datasources/focus_session_local_datasource.dart';

class FocusSessionRepositoryImpl implements FocusSessionRepository {
  final FocusSessionLocalDataSource localDataSource;

  FocusSessionRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<FocusSession>>> getAllSessions() async {
    try {
      final sessions = await localDataSource.getAllSessions();
      return Right(sessions);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, FocusSession>> getSession(String sessionId) async {
    try {
      final session = await localDataSource.getSession(sessionId);
      if (session == null) {
        return const Left(CacheFailure(message: 'Session not found'));
      }
      return Right(session);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, FocusSession>> createSession(
    FocusSession session,
  ) async {
    try {
      await localDataSource.saveSession(session);
      return Right(session);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, FocusSession>> updateSession(
    FocusSession session,
  ) async {
    try {
      await localDataSource.saveSession(session);
      return Right(session);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSession(String sessionId) async {
    try {
      await localDataSource.deleteSession(sessionId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<FocusSession>>> getRecentSessions({
    int limit = 5,
  }) async {
    try {
      final sessions = await localDataSource.getRecentSessions(limit: limit);
      return Right(sessions);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateLastPlayed(String sessionId) async {
    try {
      await localDataSource.updateLastPlayed(sessionId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<int> getMaxSortOrder() async {
    return await localDataSource.getMaxSortOrder();
  }

  @override
  Future<int> getMinSortOrder() async {
    return await localDataSource.getMinSortOrder();
  }

  @override
  Future<int> getPinnedCount() async {
    return await localDataSource.getPinnedCount();
  }

  @override
  Future<String?> getActiveSessionId() async {
    return await localDataSource.getActiveSessionId();
  }

  @override
  Future<void> saveActiveSessionId(String? sessionId) async {
    await localDataSource.saveActiveSessionId(sessionId);
  }

  @override
  Future<List<String>?> getActiveSessionTrackUris() async {
    return await localDataSource.getActiveSessionTrackUris();
  }

  @override
  Future<void> saveActiveSessionTrackUris(List<String> trackUris) async {
    await localDataSource.saveActiveSessionTrackUris(trackUris);
  }
}
