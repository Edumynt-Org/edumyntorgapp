import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'network/auth_repository.dart';
import 'network/catalog_repository.dart';
import 'theme/theme_provider.dart';

// Provides the SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

// Provides the FlutterSecureStorage instance
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  throw UnimplementedError('secureStorageProvider must be overridden');
});

// Provides the initial token read from secure storage
final initialTokenProvider = Provider<String?>((ref) {
  throw UnimplementedError('initialTokenProvider must be overridden');
});

// Provides the AuthRepository
final authRepositoryProvider = ChangeNotifierProvider<AuthRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  final initialToken = ref.watch(initialTokenProvider);
  return AuthRepository(prefs, secureStorage, initialToken);
});

// Provides the CatalogRepository
final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository();
});

// Provides the ThemeProvider
final themeProvider = ChangeNotifierProvider<ThemeProvider>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeProvider(prefs);
});
