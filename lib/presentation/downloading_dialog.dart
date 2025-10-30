
import 'package:flutter/material.dart';

/// A simple dialog that shows download progress and a Cancel button.
class DownloadingDialog extends StatefulWidget {
  final VoidCallback onCancel;
  final double Function() progressProvider;

  const DownloadingDialog({super.key, required this.onCancel, required this.progressProvider});

  @override
  State<DownloadingDialog> createState() => _DownloadingDialogState();
}

class _DownloadingDialogState extends State<DownloadingDialog> {
  @override
  void initState() {
    super.initState();
    // We update progress every 200ms while open.
    WidgetsBinding.instance.addPostFrameCallback((_) => _tick());
  }

  void _tick() async {
    while (mounted) {
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (widget.progressProvider() * 100).toStringAsFixed(0);
    return AlertDialog(
      title: const Text('Downloading update'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Downloading update — please do not exit the app.'),
        const SizedBox(height: 12),
        Row(
          children: [
            //Text('Progress: ',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
            Spacer(),
            SizedBox(
              //color: Colors.blueAccent,
              height: 50,
              width: 50,
              child: Stack(
                children: [
                  //Positioned.fill(child: Center(child: CircularProgressIndicator(value: widget.progressProvider()))),
                  Center(child: Text('$progress%',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),)),
                ],
              ),
            ),
          ],
        ),
        LinearProgressIndicator(value: widget.progressProvider()),
        ]
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onCancel();
            // keep dialog open; download flow handles closing
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
