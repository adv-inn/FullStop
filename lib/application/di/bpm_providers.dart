import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/bpm_cache_local_datasource.dart';
import '../../data/datasources/getsongbpm_api_client.dart';
import '../../data/repositories/bpm_repository_impl.dart';
import '../../domain/repositories/bpm_repository.dart';
import 'auth_providers.dart';

/// BPM API related providers (GetSongBPM)

// GetSongBPM API Key provider
final getSongBpmApiKeyProvider = FutureProvider<String?>((ref) async {
  final dataSource = ref.watch(credentialsLocalDataSourceProvider);
  return await dataSource.getGetSongBpmApiKey();
});

// Dedicated Dio for GetSongBPM (no Spotify auth)
final bpmDioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json', 'User-Agent': 'FullStop/1.0'},
    ),
  );
});

// GetSongBPM API Client (nullable - depends on API key)
final getSongBpmApiClientProvider = FutureProvider<GetSongBpmApiClient?>((
  ref,
) async {
  final apiKey = await ref.watch(getSongBpmApiKeyProvider.future);
  if (apiKey == null || apiKey.isEmpty) {
    return null;
  }
  final dio = ref.watch(bpmDioProvider);
  return GetSongBpmApiClient(dio, apiKey);
});

// BPM Cache Local Data Source
final bpmCacheLocalDataSourceProvider = Provider<BpmCacheLocalDataSource>((
  ref,
) {
  return BpmCacheLocalDataSourceImpl();
});

// BPM Repository (nullable - depends on API client)
final bpmRepositoryProvider = FutureProvider<BpmRepository?>((ref) async {
  final apiClient = await ref.watch(getSongBpmApiClientProvider.future);
  if (apiClient == null) {
    return null;
  }
  final cacheDataSource = ref.watch(bpmCacheLocalDataSourceProvider);
  return BpmRepositoryImpl(apiClient, cacheDataSource);
});
