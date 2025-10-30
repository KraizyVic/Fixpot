
import 'package:flutter/material.dart';

/// Simple bottom sheet that shows version and changelog with a single Update button.
class UpdateModal extends StatelessWidget {
  final String version;
  final String changelog;
  final VoidCallback onUpdate;

  const UpdateModal({super.key, required this.version, required this.changelog, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New Update Available • $version', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(changelog.isNotEmpty ? changelog : 'No changelog provided.'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Later')),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: onUpdate, child: const Text('Download')),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
