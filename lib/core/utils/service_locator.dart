import 'package:get_it/get_it.dart';
import 'package:movie_test_app/core/utils/cache_service.dart';
import 'package:movie_test_app/core/utils/connectivity_service.dart';
import 'package:movie_test_app/features/movies/data/repositories/movie_repository.dart';

final GetIt locator = GetIt.instance;

Future<void> setupServiceLocator() async {
  locator.registerLazySingleton<ConnectivityService>(
    () => ConnectivityService(),
  );

  final cacheService = await CacheService.getInstance();
  locator.registerSingleton<CacheService>(cacheService);

  await cacheService.purgeExpiredCache();

  locator.registerLazySingleton<MovieRepository>(() => MovieRepository());

  await Future.wait([]);
}
