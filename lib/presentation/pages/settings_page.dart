import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Settings Page', style: TextStyle(fontSize: 24,color: Theme.of(context).colorScheme.primary)),
            SizedBox(height: 20),
            Text('COMING SOON', style: TextStyle(fontSize: 16,fontStyle: FontStyle.italic)),
          ]
        ),
      )
    );
  }
}
