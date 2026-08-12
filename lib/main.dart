import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const EdumyntApp());
}

class EdumyntApp extends StatelessWidget {
  const EdumyntApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edumynt Library',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Automatically switch based on device settings
      home: const DummyHome(),
    );
  }
}

class DummyHome extends StatelessWidget {
  const DummyHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edumynt Library')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Edumynt!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
