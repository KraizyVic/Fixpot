

import 'package:fixpot/data/data_source/network_info_service.dart';
import 'package:fixpot/data/repository_impls/network_info_repository_impl.dart';
import 'package:fixpot/domain/repositories/network_info_repository.dart';
import 'package:fixpot/domain/use_cases/network_info_use_cases.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {

  // DATA SOURCES
  sl.registerLazySingleton<NetworkInfoService>(() => NetworkInfoService());

  // REPOSITORIES
  sl.registerLazySingleton<NetworkInfoRepository>(() => NetworkInfoRepositoryImpl(networkInfoLocalDataSource: sl<NetworkInfoService>()));

  // USE CASES
  sl.registerLazySingleton<FetchNetworkInfoUseCase>(() => FetchNetworkInfoUseCase(networkInfoRepository: sl<NetworkInfoRepository>()));

}