import 'package:fixpot/data/data_source/captive_portal_checker.dart';
import 'package:fixpot/data/data_source/time_sync_service.dart';
import 'package:fixpot/domain/entities/network_info_entity.dart';
import 'package:fixpot/domain/use_cases/network_info_use_cases.dart';
import 'package:fixpot/presentation/pages/webview_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

import '../../core/dependency_injector.dart';

class NetworkInfoPage extends StatefulWidget {
  const NetworkInfoPage({super.key});

  @override
  State<NetworkInfoPage> createState() => _NetworkInfoPageState();
}

class _NetworkInfoPageState extends State<NetworkInfoPage> {
  late Future<NetworkInfoEntity> _networkInfoFuture;
  late Future<String?> _paymentGatewayUrl;
  Future<DateTime?> _fetchedDateTime = Future.value(DateTime.now());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _networkInfoFuture = sl<FetchNetworkInfoUseCase>().fetchNetworkInfo();
    _paymentGatewayUrl = PortalDetector().checkForPortal();
    //_fetchedDateTime = Future.value(DateTime.now()) ;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context,constraints) {
          if(constraints.maxWidth > 600){
            return Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Network Info",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
                  SizedBox(height: 10,),

                  Expanded(
                    child: FutureBuilder<NetworkInfoEntity>(
                        future: _networkInfoFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          } else {
                            final networkInfo = snapshot.data!;
                            _fetchedDateTime = TimeSyncService.fetchDateFromHttp(networkInfo.gateway ?? "192.168.1.1");
                            if(networkInfo.connectionType == "null"){
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("No Network Connection !",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
                                    SizedBox(height: 20,),
                                    Text("Please check your internet connection and try again.",style: TextStyle(fontSize: 20),),
                                    SizedBox(height: 30,),
                                    MaterialButton(
                                      autofocus: true,
                                      focusColor: Theme.of(context).colorScheme.primary,
                                      padding: EdgeInsets.symmetric(vertical: 15,horizontal: 50),
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(color: Theme.of(context).colorScheme.primary),
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                      elevation: 0,
                                      onPressed: (){
                                        setState(() {
                                          _networkInfoFuture = sl<FetchNetworkInfoUseCase>().fetchNetworkInfo();
                                        });
                                      },
                                      child: Text("Refresh"),
                                    )
                                  ],
                                ),
                              );
                            }
                            return FutureBuilder(
                              future: _fetchedDateTime,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(child: Text('Error: ${snapshot.error}'));
                                }
                                DateTime dateTime = snapshot.data ?? DateTime.now();
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text("Date ${dateTime.day}/${dateTime.month}/${dateTime.year}",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Theme.of(context).colorScheme.primary),),
                                    Text("Last Updated at => ${dateTime.hour}:${dateTime.minute}:${dateTime.second}"),
                                    Expanded(
                                      child: Lottie.asset(
                                        "lib/core/assets/Wifi Signal - Zortex.json",
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        //reverse: true
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              networkInfoGridTile(context: context, title: 'Connection Type', value: networkInfo.connectionType.toUpperCase()),
                                              networkInfoGridTile(context: context, title: 'Subnet Mask', value: "${networkInfo.subnet}")
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              networkInfoGridTile(context: context, title: 'Network Name', value: "${networkInfo.ssid}"),
                                              networkInfoGridTile(context: context, title: 'Gateway', value: "${networkInfo.gateway}"),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              networkInfoGridTile(context: context, title: 'IP Address', value: "${networkInfo.ip}"),
                                              networkInfoGridTile(context: context, title: 'BSSID', value: "${networkInfo.bssid}"),
                                            ]
                                          ),
                                        )
                                      ],
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          MaterialButton(
                                            focusColor: Theme.of(context).colorScheme.primary,
                                            padding: EdgeInsets.symmetric(vertical: 15,horizontal: 50),
                                            elevation: 0,
                                            onPressed: (){
                                              setState(() {
                                                _networkInfoFuture = sl<FetchNetworkInfoUseCase>().fetchNetworkInfo();
                                                _fetchedDateTime = TimeSyncService.fetchDateFromHttp(networkInfo.gateway ?? "192.168.1.1");
                                              });
                                            },
                                            //color: Theme.of(context).colorScheme.primary,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(color: Theme.of(context).colorScheme.primary.withAlpha(100)),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text("Refresh"),
                                          ),
                                          SizedBox(width: 10,),
                                          MaterialButton(
                                            focusColor: Theme.of(context).colorScheme.primary,
                                            padding: EdgeInsets.symmetric(vertical: 15,horizontal: 50),
                                            elevation: 0,
                                            autofocus: true,
                                            onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>WebviewPage(testPage: "testPage",gateway: networkInfo.gateway,fetchedDate: dateTime,))),
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(color: Theme.of(context).colorScheme.primary.withAlpha(100)),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text("Check"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }
                            );
                          }
                        }
                    ),
                  ),
                ],
              ),
            );
          }
          return Column(
            children: [
              Text("Network Info",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
              Expanded(
                child: FutureBuilder<NetworkInfoEntity>(
                  future: _networkInfoFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      final networkInfo = snapshot.data!;
                      if(networkInfo.connectionType == "null"){
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("No Network Connection !",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
                              SizedBox(height: 20,),
                              Text("Please check your WIFI connection and try again.",textAlign: TextAlign.center,style: TextStyle(fontSize: 15),),
                              SizedBox(height: 30,),
                              MaterialButton(
                                autofocus: true,
                                focusColor: Theme.of(context).colorScheme.primary,
                                padding: EdgeInsets.symmetric(vertical: 15,horizontal: 50),
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(color: Theme.of(context).colorScheme.primary),
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                elevation: 0,
                                onPressed: (){
                                  setState(() {
                                    _networkInfoFuture = sl<FetchNetworkInfoUseCase>().fetchNetworkInfo();
                                  });
                                },
                                child: Text("Refresh"),
                              )
                            ],
                          ),
                        );
                      }
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              networkInfo.connectionType != "null" ? Lottie.asset(
                                "lib/core/assets/Wifi Signal - Zortex.json",
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                                //reverse: true
                              ) : Icon(Icons.wifi_off_rounded,size: 200,),
                              networkInfoTile(context: context, title: 'Connection Type', value: networkInfo.connectionType.toUpperCase()),
                              networkInfoTile(context: context, title: 'Network Name', value: "${networkInfo.ssid}"),
                              networkInfoTile(context: context, title: 'IP Address', value: "${networkInfo.ip}"),
                              networkInfoTile(context: context, title: 'Gateway', value: "${networkInfo.gateway}"),
                              networkInfoTile(context: context, title: 'Subnet Mask', value: "${networkInfo.subnet}"),
                              networkInfoTile(context: context, title: 'BSSID', value: "${networkInfo.bssid}"),
                              SizedBox(height: 20,),
                              Row(
                                children: [
                                  Expanded(
                                    child: MaterialButton(
                                      onPressed: (){
                                        setState(() {
                                          _networkInfoFuture = sl<FetchNetworkInfoUseCase>().fetchNetworkInfo();
                                        });
                                      },
                                      //color: Theme.of(context).colorScheme.primary,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(color: Theme.of(context).colorScheme.primary.withAlpha(100)),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text("Refresh"),
                                    ),
                                  ),
                                  SizedBox(width: 10,),
                                  Expanded(
                                    child: MaterialButton(
                                      focusColor: Theme.of(context).colorScheme.primary,
                                      onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>WebviewPage(testPage: "testPage",gateway: snapshot.data!.gateway,))),
                                      color: Theme.of(context).colorScheme.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text("Check"),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  }
                ),
              ),
            ],
          );
        }
      )
    );
  }
}

Widget networkInfoTile({
  required BuildContext context,
  required String title,
  required String value,
  Function()? onTap,
  Function()? onLongPress
}){
  return ListTile(
    title: Text(title,),
    trailing: Text(value),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    onTap: (){
      onTap;
    },
    onLongPress: ()async{
      await Clipboard.setData(ClipboardData(text: value));
    },
  );
}

Widget networkInfoGridTile({
  required BuildContext context,
  required String title,
  required String value,
  Function()? onTap,
  Function()? onLongPress
}){
  return MaterialButton(
    onLongPress: (){
      Clipboard.setData(ClipboardData(text: value));
    },
    onPressed: () {  },
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    elevation: 0,
    padding: EdgeInsets.symmetric(vertical: 15),
    child: SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Text(title,style: TextStyle(color: Theme.of(context).colorScheme.primary),),
          SizedBox(height: 10,),
          Text(value),
          SizedBox(height: 10,),
        ],
      ),
    ),
  );
}
