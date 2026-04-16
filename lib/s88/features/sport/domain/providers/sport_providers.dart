import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/network/sb_http_manager.dart';
import 'package:co_caro_flame/s88/core/services/storage/sport_storage.dart';
import 'package:co_caro_flame/s88/features/sport/data/datasources/sport_remote_datasource.dart';
import 'package:co_caro_flame/s88/features/sport/data/repositories/sport_repository_impl.dart';
import 'package:co_caro_flame/s88/features/sport/domain/repositories/sport_repository.dart';
import 'package:co_caro_flame/s88/features/sport/domain/usecases/change_sport_usecase.dart';
import 'package:co_caro_flame/s88/features/sport/domain/usecases/fetch_leagues_usecase.dart';

// ============================================================================
// Data Layer Providers
// ============================================================================

/// Sport Remote Data Source Provider
final sportRemoteDataSourceProvider = Provider<SportRemoteDataSource>((ref) {
  final httpManager = SbHttpManager.instance;
  final storage = SportStorage.instance;
  return SportRemoteDataSourceImpl(httpManager, storage);
});

/// Sport Repository Provider
final sportRepositoryProvider = Provider<SportRepository>((ref) {
  final remoteDataSource = ref.read(sportRemoteDataSourceProvider);
  return SportRepositoryImpl(remoteDataSource);
});

// ============================================================================
// Domain Layer Providers (Use Cases)
// ============================================================================

/// Fetch Leagues Use Case Provider
final fetchLeaguesUseCaseProvider = Provider<FetchLeaguesUseCase>((ref) {
  final repository = ref.read(sportRepositoryProvider);
  return FetchLeaguesUseCase(repository);
});

/// Fetch Live Leagues Use Case Provider
final fetchLiveLeaguesUseCaseProvider = Provider<FetchLiveLeaguesUseCase>((
  ref,
) {
  final repository = ref.read(sportRepositoryProvider);
  return FetchLiveLeaguesUseCase(repository);
});

/// Fetch Today Leagues Use Case Provider
final fetchTodayLeaguesUseCaseProvider = Provider<FetchTodayLeaguesUseCase>((
  ref,
) {
  final repository = ref.read(sportRepositoryProvider);
  return FetchTodayLeaguesUseCase(repository);
});

/// Fetch Hot Leagues Use Case Provider
final fetchHotLeaguesUseCaseProvider = Provider<FetchHotLeaguesUseCase>((ref) {
  final repository = ref.read(sportRepositoryProvider);
  return FetchHotLeaguesUseCase(repository);
});

/// Fetch Outright Leagues Use Case Provider
final fetchOutrightLeaguesUseCaseProvider =
    Provider<FetchOutrightLeaguesUseCase>((ref) {
      final repository = ref.read(sportRepositoryProvider);
      return FetchOutrightLeaguesUseCase(repository);
    });

/// Fetch Special Outright Use Case Provider
final fetchSpecialOutrightUseCaseProvider =
    Provider<FetchSpecialOutrightUseCase>((ref) {
      final repository = ref.read(sportRepositoryProvider);
      return FetchSpecialOutrightUseCase(repository);
    });

/// Change Sport Use Case Provider
final changeSportUseCaseProvider = Provider<ChangeSportUseCase>((ref) {
  final repository = ref.read(sportRepositoryProvider);
  return ChangeSportUseCase(repository);
});
