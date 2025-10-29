import 'package:fixpot/domain/entities/network_info_entity.dart';
import 'package:fixpot/domain/repositories/network_info_repository.dart';

class FetchNetworkInfoUseCase{
  final NetworkInfoRepository networkInfoRepository;
  FetchNetworkInfoUseCase({required this.networkInfoRepository});

  Future<NetworkInfoEntity> fetchNetworkInfo() async{
    return await networkInfoRepository.fetchNetworkInfo();
  }
}