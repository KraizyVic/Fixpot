import 'package:fixpot/data/models/network_info_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';

class NetworkInfoService {
  final _connectivity = Connectivity();
  final _networkInfo = NetworkInfo();

  Future<NetworkInfoModel> fetchNetworkInfo() async{
    final connectivityResult = await _connectivity.checkConnectivity();

    String type = 'null';
    String? ssid;
    String? bssid;
    String? ip;
    String? gateway;
    String? broadcast;
    String? subnet;

    if(connectivityResult.contains(ConnectivityResult.wifi)){
      type = connectivityResult.first.name;
      ssid = await _networkInfo.getWifiName();
      bssid = await _networkInfo.getWifiBSSID();
      ip = await _networkInfo.getWifiIP();
      gateway = await _networkInfo.getWifiGatewayIP();
      broadcast = await _networkInfo.getWifiBroadcast();
      subnet = await _networkInfo.getWifiSubmask();
    }else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
      type = 'Ethernet';
      ip = await _networkInfo.getWifiIP();
      gateway = await _networkInfo.getWifiGatewayIP();
    }else if (connectivityResult.contains(ConnectivityResult.mobile)) {
      type = 'mobile';
      ip = await _networkInfo.getWifiIP();


    }
    return NetworkInfoModel(
      connectionType: type,
      ssid: ssid,
      bssid: bssid,
      ip: ip,
      gateway: gateway,
      broadcast: broadcast,
      subnet: subnet
    );
  }
}