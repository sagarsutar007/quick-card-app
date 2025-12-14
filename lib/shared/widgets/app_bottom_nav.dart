import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(31, 207, 207, 207),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            context,
            index: 0,
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: "HOME",
            route: "/dashboard",
          ),
          _navItem(
            context,
            index: 1,
            icon: Icons.school_outlined,
            activeIcon: Icons.school,
            label: "SCHOOLS",
            route: "/schools",
          ),
          _navItem(
            context,
            index: 2,
            icon: Icons.group_outlined,
            activeIcon: Icons.group,
            label: "STUDENTS",
            route: "/students",
          ),
          _navItem(
            context,
            index: 3,
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: "PROFILE",
            route: "/profile",
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String route,
  }) {
    final bool selected = index == currentIndex;

    return GestureDetector(
      onTap: () => context.go(route),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            selected ? activeIcon : icon,
            size: selected ? 26 : 24,
            color: selected ? Colors.black : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: selected ? Colors.black : Colors.grey,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
