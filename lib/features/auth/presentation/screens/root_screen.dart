import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:quickcard/core/services/locator.dart';
import 'package:quickcard/core/services/storage_service.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    /// Delay routing until after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = getIt<StorageService>().token;

      if (token != null) {
        context.go('/dashboard');
      } else {
        context.go('/login');
      }

      FlutterNativeSplash.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
