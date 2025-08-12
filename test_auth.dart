import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'lib/auth/provider/auth_provider.dart';
import 'lib/auth/provider/storage_service.dart';
import 'lib/auth/provider/user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  print('Testing Firebase Authentication...');

  // Test UserService
  final userService = UserService();
  print('UserService initialized successfully');

  // Test StorageService
  final storageService = StorageService();
  print('StorageService initialized successfully');

  // Test AuthProvider
  final authProvider = FirebaseAuthProvider();
  print('AuthProvider initialized successfully');

  print('All services initialized successfully!');
  print('Ready to test authentication features...');
}
