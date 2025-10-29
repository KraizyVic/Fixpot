

import 'package:fixpot/domain/entities/network_info_entity.dart';

class NetworkInfoModel {
  final String connectionType; // wifi, ethernet, mobile, none
  final String? ssid;          // Wi-Fi name
  final String? bssid;         // Router MAC
  final String? ip;            // Device IP
  final String? gateway;       // Gateway IP (e.g., 192.168.1.1)
  final String? broadcast;     // Broadcast IP
  final String? subnet;        // Subnet mask

  NetworkInfoModel({
    required this.connectionType,
    this.ssid,
    this.bssid,
    this.ip,
    this.gateway,
    this.broadcast,
    this.subnet,
  });

  NetworkInfoEntity toNetworkInfoEntity(){
    return NetworkInfoEntity(
      connectionType: connectionType,
      ssid: ssid,
      bssid: bssid,
      ip: ip,
      gateway: gateway,
      broadcast: broadcast,
      subnet: subnet,
    );
  }

  static NetworkInfoModel toNetworkInfoModel(NetworkInfoEntity entity){
    return NetworkInfoModel(
      connectionType: entity.connectionType,
      ssid: entity.ssid,
      bssid: entity.bssid,
      ip: entity.ip,
      gateway: entity.gateway,
      broadcast: entity.broadcast,
      subnet: entity.subnet
    );
  }
}