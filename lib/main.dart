import 'dart:io';

import 'package:fixpot/core/dependency_injector.dart';
import 'package:fixpot/core/http_override.dart';
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
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  final bool isTv = await isAndroidTv();
  if (isTv) {
    HttpOverrides.global = MyHttpOverrides();
  }
  await initializeDependencies();
  runApp(MyApp(isTv: isTv));
}

class MyApp extends StatelessWidget {
  final bool isTv;

  const MyApp({super.key, required this.isTv,});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fixpot',
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Color(0xff005945f),
            primary: Color(0xff005945f),
          brightness: Brightness.light,
          surface: Colors.white
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF005945F),
          primary: Color(0xFF005945F),
          surface: Colors.black,
          brightness: Brightness.dark
        ),
      ),
      home: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent
        ),
        child: MainPage(isTv: isTv),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainPage extends StatefulWidget {
  final bool isTv;
  const MainPage({super.key, required this.isTv});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  double _progress = 0.0;
  bool _isDownloading = false;
  bool _cancelRequested = false;
  final PageController _pageController = PageController();
  int page = 0;

  @override
  void initState() {
    super.initState();
    // check for updates after UI builds (non-blocking)
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdate());
  }

  /// 🧠 Async update check running after first frame
  Future<void> _checkForUpdate() async {
    try {
      final updateService = UpdateService(
        repoOwner: 'KraizyVic',
        repoName: 'Fixpot',
      );

      final update = await updateService.checkForUpdate().timeout(const Duration(seconds: 5), onTimeout: () => null);

      if (update != null &&
          await VersionHelper.isUpdateAvailable(update['version'] ?? '0.0.0')) {
        // Show update modal
        if (mounted) {
          showModalBottomSheet(
            context: context,
            builder: (_) => UpdateModal(
              version: update['version'] ?? '',
              changelog: update['changelog'] ?? '',
              onUpdate: () {
                Navigator.of(context).pop(); // close bottom sheet
                if (update['apkUrl'] != null) {
                  _startUpdate(update['apkUrl']);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('No APK attached to release.')),
                  );
                }
              },
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('⚠️ Update check failed: $e');
    }
  }

  /// ⬇️ Handles the update download + install process
  Future<void> _startUpdate(String url) async {
    setState(() {
      _isDownloading = true;
      _cancelRequested = false;
      _progress = 0.0;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => DownloadingDialog(
        onCancel: () => setState(() => _cancelRequested = true),
        progressProvider: () => _progress,
      ),
    );

    final downloader = DownloadService();
    try {
      final path = await downloader.downloadApk(url, (p) {
        if (_cancelRequested) return;
        setState(() => _progress = p);
      }, () => _cancelRequested);

      if (_cancelRequested) {
        setState(() => _isDownloading = false);
        Navigator.of(context, rootNavigator: true).pop();
        return;
      }

      await ApkInstaller.installApk(path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _progress = 0.0;
        });
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600) {
        // 📺 TV / Wide layout
        return Scaffold(
          body: Row(
            children: [
              Drawer(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero),
                child: _buildNavList(isLargeScreen: true, isTv: widget.isTv),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => page = i),
                  children: const [
                    NetworkInfoPage(),
                    SettingsPage(),
                  ],
                ),
              ),
            ],
          ),
        );
      }
      // 📱 Phone layout
      return Scaffold(
        appBar: AppBar(),
        drawer: Drawer(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: _buildNavList(isLargeScreen: false, isTv: widget.isTv),
        ),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (i) => setState(() => page = i),
          children: [
            const NetworkInfoPage(),
            const SettingsPage(),
          ]
        ),
      );
    });
  }

  Widget _buildNavList({
    required bool isLargeScreen,
    required bool isTv,
  }) {
    return Column(
      children: [
        DrawerHeader(
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
          child: Center(
            child: Text(
              "Fixpot ${isTv ? "(TV)" : ""}",
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            )
          )
        ),
        Padding(
          padding: EdgeInsets.all(isLargeScreen ? 0.0 : 10.0),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.wifi),
                title: const Text("Network Info"),
                  contentPadding: isLargeScreen ? const EdgeInsets.only(left: 20.0) : const EdgeInsets.symmetric(horizontal: 20.0) ,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isLargeScreen ? 0 : 10)),
                  trailing: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.bounceInOut,
                    width: 5,
                    height: double.maxFinite,
                    color: page == 0 ? Theme.of(context).colorScheme.primary : Colors.transparent,
                  ),
                onTap: () {
                  _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  isLargeScreen ? null : Navigator.of(context).pop();
                }
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("Settings"),
                contentPadding: isLargeScreen ? const EdgeInsets.only(left: 20.0) : const EdgeInsets.symmetric(horizontal: 20.0) ,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isLargeScreen ? 0 : 10)),
                trailing: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.bounceInOut,
                  width: 5,
                  height: double.maxFinite,
                  color: page == 1 ? Theme.of(context).colorScheme.primary : Colors.transparent,
                ),
                onTap: () {
                  _pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  isLargeScreen ? null : Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

