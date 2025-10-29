import 'package:fixpot/data/data_source/captive_portal_checker.dart';
import 'package:fixpot/domain/entities/network_info_entity.dart';
import 'package:fixpot/domain/use_cases/network_info_use_cases.dart';
import 'package:fixpot/presentation/pages/webview_page.dart';
import 'package:flutter/material.dart';

import '../../core/dependency_injector.dart';

class NetworkInfoPage extends StatefulWidget {
  const NetworkInfoPage({super.key});

  @override
  State<NetworkInfoPage> createState() => _NetworkInfoPageState();
}

class _NetworkInfoPageState extends State<NetworkInfoPage> {
  late Future<NetworkInfoEntity> _networkInfoFuture;
  late Future<String?> _patymentGatewayUrl;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _networkInfoFuture = sl<FetchNetworkInfoUseCase>().fetchNetworkInfo();
    _patymentGatewayUrl = PortalDetector().checkForPortal();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Info'),
      ),
      body: FutureBuilder<NetworkInfoEntity>(
        future: _networkInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Network Type: ${snapshot.data!.connectionType.toUpperCase()}'),
                  Text('SSID: ${snapshot.data!.ssid}'),
                  Text('IP Address: ${snapshot.data!.ip}'),
                  Text('Gateway: ${snapshot.data!.gateway}'),
                  Text('Subnet Mask: ${snapshot.data!.subnet}'),
                  Text('BSSID: ${snapshot.data!.bssid}'),

                  SizedBox(height: 20,),

                  TextButton(onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>WebviewPage(ipAddress: snapshot.data!.ip,gateway: snapshot.data!.gateway!,))), child: Text("To Webview Page"))

                ],
              ),
            );
          }
        }
      )
    );
  }
}
