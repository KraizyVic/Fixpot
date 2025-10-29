import 'package:fixpot/data/data_source/network_info_service.dart';
import 'package:fixpot/domain/entities/network_info_entity.dart';
import 'package:fixpot/domain/repositories/network_info_repository.dart';

class NetworkInfoRepositoryImpl extends NetworkInfoRepository {
  final NetworkInfoService networkInfoLocalDataSource;
  NetworkInfoRepositoryImpl({required this.networkInfoLocalDataSource});
  @override
  Future<NetworkInfoEntity> fetchNetworkInfo() {
    return networkInfoLocalDataSource.fetchNetworkInfo().then((model) => model.toNetworkInfoEntity());
  }
}