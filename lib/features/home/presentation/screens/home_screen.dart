import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/network/auth_repository.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = Provider.of<AuthRepository>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edumynt Library'),
        actions: [
          if (authRepo.isAuthenticated)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await authRepo.logout();
                if (context.mounted) context.go('/login');
              },
            )
          else
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Log In'),
            )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.library_books, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              authRepo.isAuthenticated ? 'Welcome back!' : 'Browsing as Guest',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Book catalog goes here.'),
          ],
        ),
      ),
    );
  }
}
