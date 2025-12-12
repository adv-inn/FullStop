import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/datasources/focus_session_local_datasource.dart';
import '../../data/repositories/focus_session_repository_impl.dart';
import '../../domain/repositories/focus_session_repository.dart';

/// Focus Session related providers

// Focus Session Local Data Source
final focusSessionLocalDataSourceProvider =
    FutureProvider<FocusSessionLocalDataSource>((ref) async {
      await Hive.initFlutter();
      return await FocusSessionLocalDataSourceImpl.create();
    });

// Focus Session Repository
final focusSessionRepositoryProvider = FutureProvider<FocusSessionRepository>((
  ref,
) async {
  final localDataSource = await ref.watch(
    focusSessionLocalDataSourceProvider.future,
  );
  return FocusSessionRepositoryImpl(localDataSource: localDataSource);
});
