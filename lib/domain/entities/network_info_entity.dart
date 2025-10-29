class NetworkInfoEntity {
  final String connectionType; // wifi, ethernet, mobile, none
  final String? ssid;          // Wi-Fi name
  final String? bssid;         // Router MAC
  final String? ip;            // Device IP
  final String? gateway;       // Gateway IP (e.g., 192.168.1.1)
  final String? broadcast;     // Broadcast IP
  final String? subnet;        // Subnet mask

  NetworkInfoEntity({
    required this.connectionType,
    this.ssid,
    this.bssid,
    this.ip,
    this.gateway,
    this.broadcast,
    this.subnet,
  });
}