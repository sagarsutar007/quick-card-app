import 'package:flutter/material.dart';
import 'package:quickcard/shared/widgets/app_bottom_nav.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final String location;

  const AppShell({super.key, required this.location, required this.child});

  int _currentIndex() {
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/schools')) return 1;
    if (location.startsWith('/students')) return 2;
    if (location.startsWith('/profile')) return 3;

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: AppBottomNav(currentIndex: _currentIndex()),
    );
  }
}
