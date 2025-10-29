import 'package:fixpot/domain/entities/network_info_entity.dart';

abstract class NetworkInfoRepository {
  Future<NetworkInfoEntity> fetchNetworkInfo();
}