import 'package:fixpot/core/dependency_injector.dart';
import 'package:fixpot/presentation/downloading_dialog.dart';
import 'package:fixpot/presentation/pages/network_info_page.dart';
import 'package:fixpot/presentation/pages/settings_page.dart';
import 'package:fixpot/presentation/update_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/method_channel.dart';
import 'core/version_helper.dart';
import 'data/data_source/update/download_service.dart';
import 'data/data_source/update/update_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Configure your GitHub repo here
  final updateService = UpdateService(repoOwner: 'KraizyVic', repoName: 'Fixpot');
  final update = await updateService.checkForUpdate();

  // If update exists and is newer than installed, pass it to the app to show modal.
  bool showUpdate = false;
  if (update != null && await VersionHelper.isUpdateAvailable(update['version'] ?? '0.0.0')) {
    showUpdate = true;
  }
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await initializeDependencies();
  runApp(MyApp(update: showUpdate ? update : null));
}

class MyApp extends StatelessWidget {
  final Map<String, dynamic>? update;

  const MyApp({super.key, this.update});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fixpot',
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
          surface: Colors.white
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF005945F),
          primary: Color(0xFF005945F),
          brightness: Brightness.dark
        ),
      ),
      home: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent
        ),
        child: MainPage(update: update,),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainPage extends StatefulWidget {
  final Map<String, dynamic>? update;
  const MainPage({super.key, this.update});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  double _progress = 0.0;
  bool _isDownloading = false;
  bool _cancelRequested = false;
  final PageController _pageController = PageController();
  int page = 0;




  // Start download and auto-install after completion.
  Future<void> _startUpdate(String url) async {
    setState(() {
      _isDownloading = true;
      _cancelRequested = false;
      _progress = 0.0;
    });

    // Show downloading dialog; user can cancel.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => DownloadingDialog(
        onCancel: () {
          setState(() => _cancelRequested = true);
        },
        progressProvider: () => _progress,
      ),
    );

    final downloader = DownloadService();
    try {
      final path = await downloader.downloadApk(url, (p) {
        if (_cancelRequested) {
          // DownloadService checks this flag and will throw to stop download.
          return;
        }
        setState(() => _progress = p);
      }, () => _cancelRequested);

      // If user cancelled, just close dialogs and return.
      if (_cancelRequested) {
        setState(() => _isDownloading = false);
        Navigator.of(context, rootNavigator: true).pop(); // close dialog
        return;
      }

      // Auto-install APK via MethodChannel to native side.
      await ApkInstaller.installApk(path);

    } catch (e) {
      // If download failed or was cancelled, show a simple snackbar
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    } finally {
      setState(() {
        _isDownloading = false;
        _progress = 0.0;
      });
      Navigator.of(context, rootNavigator: true).pop(); // close dialog if still open
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.update != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showModalBottomSheet(
          context: context,
          builder: (_) => UpdateModal(
            version: widget.update!['version'] ?? '',
            changelog: widget.update!['changelog'] ?? '',
            onUpdate: () {
              Navigator.of(context).pop(); // close bottom sheet
              if (widget.update!['apkUrl'] != null) {
                _startUpdate(widget.update!['apkUrl']);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No APK attached to release.')));
              }
            },
          ),
        );
      });
    }
  }

  @override@override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context,constraints) {
        if(constraints.maxWidth > 600){
          return Scaffold(
            body: Row(
              children: [
                Drawer(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                    child: Column(
                        children: [
                          DrawerHeader(
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary
                            ),
                            child: Center(child: Text("Fixpot",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold))),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Icon(Icons.wifi),
                                  title: Text("Network Info"),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  trailing: Icon(page == 0 ? Icons.check : null),
                                  onTap: (){
                                    _pageController.animateToPage(
                                      0,
                                      duration: Duration(milliseconds: 300), curve: Curves.easeInOut,
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: Icon(Icons.settings),
                                  title: Text("Settings"),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  trailing: Icon(page == 1 ? Icons.check : null),
                                  onTap: (){
                                    _pageController.animateToPage(
                                      1,
                                      duration: Duration(milliseconds: 300), curve: Curves.easeInOut,
                                    );
                                  },
                                ),
                              ],
                            ),
                          )
                        ]
                    )
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: NeverScrollableScrollPhysics(),
                    onPageChanged: (pageInt){
                      setState(() {
                        page = pageInt;
                      });
                    },
                    children: [
                      NetworkInfoPage(),
                      SettingsPage()
                    ],
                  ),
                )
              ],
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(),
          drawer:  Drawer(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            child: Column(
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary
                    ),
                    child: Center(child: Text("Fixpot",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold))),
                  ),
                  ListTile(
                    leading: Icon(Icons.wifi),
                    title: Text("Network Info"),
                    onTap: (){},
                  ),
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text("Settings"),
                    onTap: (){},
                  )
                ]
              )
          ),
          body: NetworkInfoPage()
        );
      }
    );
  }
}
